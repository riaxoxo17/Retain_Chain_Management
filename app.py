from flask import Flask, render_template, request, jsonify
import mysql.connector
from mysql.connector import Error

app = Flask(__name__)

# DB connection
def get_db_connection():
    try:
        conn = mysql.connector.connect(
            host='localhost',
            user='root',
            password='clover007',
            database='RetailChainDB',
            port=3306
        )
        return conn
    except Error as e:
        print(f"Database connection error: {e}")
        return None

@app.route('/')
def index():
    return render_template('index.html')

# ============ DROPDOWN DATA ============

@app.route('/get_suppliers')
def get_suppliers():
    try:
        conn = get_db_connection()
        if not conn:
            return jsonify({"error": "Database connection failed"}), 500
        cursor = conn.cursor(dictionary=True)
        cursor.execute("SELECT supplier_id, supplier_name FROM Supplier")
        result = cursor.fetchall()
        cursor.close()
        conn.close()
        return jsonify(result)
    except Exception as e:
        print(f"Error in get_suppliers: {e}")
        return jsonify({"error": str(e)}), 500

@app.route('/get_stores')
def get_stores():
    try:
        conn = get_db_connection()
        if not conn:
            return jsonify({"error": "Database connection failed"}), 500
        cursor = conn.cursor(dictionary=True)
        cursor.execute("SELECT store_id, store_name FROM Store")
        result = cursor.fetchall()
        cursor.close()
        conn.close()
        return jsonify(result)
    except Exception as e:
        print(f"Error in get_stores: {e}")
        return jsonify({"error": str(e)}), 500

@app.route('/get_products')
def get_products():
    try:
        conn = get_db_connection()
        if not conn:
            return jsonify({"error": "Database connection failed"}), 500
        cursor = conn.cursor(dictionary=True)
        cursor.execute("SELECT product_id, product_name FROM Product")
        result = cursor.fetchall()
        cursor.close()
        conn.close()
        return jsonify(result)
    except Exception as e:
        print(f"Error in get_products: {e}")
        return jsonify({"error": str(e)}), 500

@app.route('/get_customers')
def get_customers():
    try:
        conn = get_db_connection()
        if not conn:
            return jsonify({"error": "Database connection failed"}), 500
        cursor = conn.cursor(dictionary=True)
        cursor.execute("SELECT customer_id, customer_name FROM Customer")
        result = cursor.fetchall()
        cursor.close()
        conn.close()
        return jsonify(result)
    except Exception as e:
        print(f"Error in get_customers: {e}")
        return jsonify({"error": str(e)}), 500

@app.route('/get_staff')
def get_staff():
    try:
        conn = get_db_connection()
        if not conn:
            return jsonify({"error": "Database connection failed"}), 500
        cursor = conn.cursor(dictionary=True)
        cursor.execute("SELECT staff_id, staff_name FROM Staff")
        result = cursor.fetchall()
        cursor.close()
        conn.close()
        return jsonify(result)
    except Exception as e:
        print(f"Error in get_staff: {e}")
        return jsonify({"error": str(e)}), 500

@app.route('/get_discounts')
def get_discounts():
    try:
        conn = get_db_connection()
        if not conn:
            return jsonify({"error": "Database connection failed"}), 500
        cursor = conn.cursor(dictionary=True)
        cursor.execute("""
            SELECT discount_id, discount_name, discount_percent 
            FROM Discount 
            WHERE CURDATE() BETWEEN start_date AND end_date
        """)
        result = cursor.fetchall()
        cursor.close()
        conn.close()
        return jsonify(result)
    except Exception as e:
        print(f"Error in get_discounts: {e}")
        return jsonify({"error": str(e)}), 500

# ============ DELIVERY ============
@app.route('/add_delivery', methods=['POST'])
def add_delivery():
    try:
        data = request.get_json()
        supplier_id = data.get('supplier_id')
        store_id = data.get('store_id')
        product_id = data.get('product_id')
        quantity_delivered = int(data.get('quantity_delivered'))
        delivery_date = data.get('delivery_date')

        # ✅ Step 1: Connect to DB
        conn = get_db_connection()
        if not conn:
            return jsonify({"error": "Database connection failed"}), 500

        cursor = conn.cursor()

        # ✅ Step 2: Insert into Delivery table
        # (The trigger automatically updates the Inventory)
        cursor.execute("""
            INSERT INTO Delivery (supplier_id, store_id, product_id, quantity_delivered, delivery_date)
            VALUES (%s, %s, %s, %s, %s)
        """, (supplier_id, store_id, product_id, quantity_delivered, delivery_date))

        # ✅ Step 3: Commit and close connection
        conn.commit()
        cursor.close()
        conn.close()

        return jsonify({
            "message": "✅ Delivery recorded successfully. Inventory updated automatically via trigger.",
            "details": {
                "supplier_id": supplier_id,
                "store_id": store_id,
                "product_id": product_id,
                "quantity_delivered": quantity_delivered,
                "delivery_date": delivery_date
            }
        }), 200

    except Exception as e:
        print(f"Error in add_delivery: {e}")
        return jsonify({"error": str(e)}), 500




# ============ INVENTORY ============

@app.route('/check_inventory')
def check_inventory():
    try:
        store_id = request.args.get('store_id')
        product_id = request.args.get('product_id')
        threshold = int(request.args.get('threshold', 20))

        conn = get_db_connection()
        if not conn:
            return jsonify({"error": "Database connection failed"}), 500
        
        cursor = conn.cursor(dictionary=True)

        # Get current inventory
        cursor.execute("""
            SELECT quantity_in_stock FROM Inventory
            WHERE store_id=%s AND product_id=%s
        """, (store_id, product_id))
        inv = cursor.fetchone()
        current_stock = inv['quantity_in_stock'] if inv else 0

        # Get last delivery
        cursor.execute("""
            SELECT quantity_delivered, delivery_date
            FROM Delivery
            WHERE store_id=%s AND product_id=%s
            ORDER BY delivery_date DESC LIMIT 1
        """, (store_id, product_id))
        last_delivery = cursor.fetchone()
        last_delivery_info = last_delivery if last_delivery else "No delivery yet"

        # Check if reorder needed
        reorder_needed = current_stock < threshold

        cursor.close()
        conn.close()

        return jsonify({
            "current_stock": current_stock,
            "last_delivery": last_delivery_info,
            "reorder_needed": reorder_needed
        })
    except Exception as e:
        print(f"Error in check_inventory: {e}")
        return jsonify({"error": str(e)}), 500

@app.route('/inventory_table')
def inventory_table():
    try:
        conn = get_db_connection()
        if not conn:
            return jsonify({"error": "Database connection failed"}), 500
        
        cursor = conn.cursor(dictionary=True)
        cursor.execute("""
            SELECT s.store_name, p.product_name, sup.supplier_name, i.quantity_in_stock
            FROM Inventory i
            JOIN Store s ON i.store_id = s.store_id
            JOIN Product p ON i.product_id = p.product_id
            JOIN Supplier sup ON p.supplier_id = sup.supplier_id
            ORDER BY s.store_name, p.product_name
        """)
        
        data = cursor.fetchall()
        cursor.close()
        conn.close()
        
        return jsonify(data)
    except Exception as e:
        print(f"Error in inventory_table: {e}")
        return jsonify({"error": str(e)}), 500

# ============ REORDER ============

@app.route('/reorder_product', methods=['POST'])
def reorder_product():
    try:
        data = request.get_json()
        store_id = data.get('store_id')
        product_id = data.get('product_id')
        threshold = int(data.get('threshold'))
        restock_qty = int(data.get('restock_qty', 0))

        conn = get_db_connection()
        if not conn:
            return jsonify({"error": "Database connection failed"}), 500
        
        cursor = conn.cursor(dictionary=True)

        # Get current inventory
        cursor.execute("""
            SELECT quantity_in_stock FROM Inventory
            WHERE store_id=%s AND product_id=%s
        """, (store_id, product_id))
        inv = cursor.fetchone()
        current_stock = inv['quantity_in_stock'] if inv else 0

        # Check if reorder needed
        reorder_needed = current_stock < threshold

        # Restock if restock_qty > 0
        if restock_qty > 0:
            if inv:
                cursor.execute("""
                    UPDATE Inventory SET quantity_in_stock=quantity_in_stock + %s
                    WHERE store_id=%s AND product_id=%s
                """, (restock_qty, store_id, product_id))
            else:
                cursor.execute("""
                    INSERT INTO Inventory (store_id, product_id, quantity_in_stock)
                    VALUES (%s, %s, %s)
                """, (store_id, product_id, restock_qty))
            conn.commit()
            current_stock += restock_qty
            reorder_needed = False

        cursor.close()
        conn.close()

        return jsonify({
            "reorder_needed": reorder_needed,
            "current_stock": current_stock,
            "message": "✓ Reorder executed" if restock_qty > 0 else "✓ Checked reorder threshold"
        })
    except Exception as e:
        print(f"Error in reorder_product: {e}")
        return jsonify({"error": str(e)}), 500

# ============ SALES ============

@app.route('/record_sale', methods=['POST'])
def record_sale():
    try:
        data = request.get_json()
        store_id = data.get('store_id')
        customer_id = data.get('customer_id')
        staff_id = data.get('staff_id')
        product_id = data.get('product_id')
        quantity = int(data.get('quantity'))
        discount_id = data.get('discount_id')
        sale_date = data.get('sale_date')

        conn = get_db_connection()
        if not conn:
            return jsonify({"error": "Database connection failed"}), 500
        
        cursor = conn.cursor(dictionary=True)

        # Get product price
        cursor.execute("SELECT price FROM Product WHERE product_id=%s", (product_id,))
        product = cursor.fetchone()
        if not product:
            cursor.close()
            conn.close()
            return jsonify({"error": "Product not found"}), 400
        
        price = float(product['price'])
        
        # Get discount if applicable
        discount_percent = 0
        if discount_id:
            cursor.execute("SELECT discount_percent FROM Discount WHERE discount_id=%s", (discount_id,))
            discount = cursor.fetchone()
            if discount:
                discount_percent = float(discount['discount_percent'])
        
        # Calculate effective price
        effective_price = price * (1 - discount_percent / 100)
        total_amount = effective_price * quantity

        # Insert into Sales
        cursor.execute("""
            INSERT INTO Sales (store_id, customer_id, staff_id, sale_date, total_amount)
            VALUES (%s, %s, %s, %s, %s)
        """, (store_id, customer_id, staff_id, sale_date, total_amount))
        
        sale_id = cursor.lastrowid

        # Insert into SalesDetails (triggers will update inventory and loyalty points)
        cursor.execute("""
            INSERT INTO SalesDetails (sale_id, product_id, quantity, discount_id, effective_price)
            VALUES (%s, %s, %s, %s, %s)
        """, (sale_id, product_id, quantity, discount_id if discount_id else None, effective_price))

        conn.commit()
        cursor.close()
        conn.close()

        return jsonify({
            "message": f"✓ Sale recorded! Total: ₹{total_amount:.2f}. Loyalty points added automatically.",
            "sale_id": sale_id,
            "total_amount": total_amount
        })
    except Exception as e:
        print(f"Error in record_sale: {e}")
        return jsonify({"error": str(e)}), 500

# ============ LOYALTY ============

@app.route('/get_loyalty_points')
def get_loyalty_points():
    try:
        customer_id = request.args.get('customer_id')
        
        conn = get_db_connection()
        if not conn:
            return jsonify({"error": "Database connection failed"}), 500
        
        cursor = conn.cursor(dictionary=True)
        cursor.execute("""
            SELECT customer_name, email, phone, loyalty_points 
            FROM Customer 
            WHERE customer_id=%s
        """, (customer_id,))
        result = cursor.fetchone()
        cursor.close()
        conn.close()
        
        if not result:
            return jsonify({"error": "Customer not found"}), 404
        
        return jsonify(result)
    except Exception as e:
        print(f"Error in get_loyalty_points: {e}")
        return jsonify({"error": str(e)}), 500

@app.route('/get_top_customers')
def get_top_customers():
    try:
        conn = get_db_connection()
        if not conn:
            return jsonify({"error": "Database connection failed"}), 500
        
        cursor = conn.cursor(dictionary=True)
        cursor.execute("""
            SELECT customer_name, email, phone, loyalty_points 
            FROM Customer 
            ORDER BY loyalty_points DESC 
            LIMIT 10
        """)
        result = cursor.fetchall()
        cursor.close()
        conn.close()
        return jsonify(result)
    except Exception as e:
        print(f"Error in get_top_customers: {e}")
        return jsonify({"error": str(e)}), 500

# ============ REPORTS ============

@app.route('/daily_sales_report')
def daily_sales_report():
    try:
        date = request.args.get('date')
        
        conn = get_db_connection()
        if not conn:
            return jsonify({"error": "Database connection failed"}), 500
        
        cursor = conn.cursor(dictionary=True)
        # Call stored procedure
        cursor.callproc('sp_GetDailySalesReport', [date])
        
        # Fetch results from stored procedure
        result = []
        for r in cursor.stored_results():
            result = r.fetchall()
        
        cursor.close()
        conn.close()
        return jsonify(result)
    except Exception as e:
        print(f"Error in daily_sales_report: {e}")
        return jsonify({"error": str(e)}), 500

@app.route('/low_stock_alert')
def low_stock_alert():
    try:
        conn = get_db_connection()
        if not conn:
            return jsonify({"error": "Database connection failed"}), 500
        
        cursor = conn.cursor(dictionary=True)
        cursor.execute("""
            SELECT l.product_id, p.product_name, l.store_id, s.store_name, 
                   l.quantity_left, l.alert_date
            FROM LowStockLog l
            JOIN Product p ON l.product_id = p.product_id
            JOIN Store s ON l.store_id = s.store_id
            ORDER BY l.alert_date DESC
            LIMIT 50
        """)
        result = cursor.fetchall()
        cursor.close()
        conn.close()
        return jsonify(result)
    except Exception as e:
        print(f"Error in low_stock_alert: {e}")
        return jsonify({"error": str(e)}), 500

@app.route('/check_product_inventory')
def check_product_inventory():
    try:
        product_id = request.args.get('product_id')
        
        conn = get_db_connection()
        if not conn:
            return jsonify({"error": "Database connection failed"}), 500
        
        cursor = conn.cursor(dictionary=True)
        # Call stored procedure
        cursor.callproc('sp_CheckInventory', [product_id])
        
        # Fetch results from stored procedure
        result = []
        for r in cursor.stored_results():
            result = r.fetchall()
        
        cursor.close()
        conn.close()
        return jsonify(result)
    except Exception as e:
        print(f"Error in check_product_inventory: {e}")
        return jsonify({"error": str(e)}), 500

# ============ ERROR HANDLERS ============

@app.errorhandler(404)
def not_found(error):
    return jsonify({"error": "Endpoint not found"}), 404

@app.errorhandler(500)
def internal_error(error):
    return jsonify({"error": "Internal server error"}), 500

if __name__ == '__main__':
    print("=" * 70)
    print("🚀 Retail Chain Management System - Flask Server")
    print("=" * 70)
    print("📡 Server: http://localhost:5000")
    print("\n📋 Available Endpoints:")
    print("   DROPDOWNS:")
    print("   - GET  /get_suppliers")
    print("   - GET  /get_stores")
    print("   - GET  /get_products")
    print("   - GET  /get_customers")
    print("   - GET  /get_staff")
    print("   - GET  /get_discounts")
    print("\n   DELIVERY:")
    print("   - POST /add_delivery")
    print("\n   INVENTORY:")
    print("   - GET  /check_inventory")
    print("   - GET  /inventory_table")
    print("\n   REORDER:")
    print("   - POST /reorder_product")
    print("\n   SALES:")
    print("   - POST /record_sale")
    print("\n   LOYALTY:")
    print("   - GET  /get_loyalty_points")
    print("   - GET  /get_top_customers")
    print("\n   REPORTS:")
    print("   - GET  /daily_sales_report (uses sp_GetDailySalesReport)")
    print("   - GET  /low_stock_alert")
    print("   - GET  /check_product_inventory (uses sp_CheckInventory)")
    print("=" * 70)
    print("⚠️  Make sure MySQL is running and RetailChainDB exists!")
    print("=" * 70)
    app.run(debug=True)