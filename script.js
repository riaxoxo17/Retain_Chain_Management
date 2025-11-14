async function loadDropdowns() {
    // Suppliers
    let res = await fetch('/get_suppliers');
    let suppliers = await res.json();
    let supplierSelect = document.getElementById('supplier_id');
    supplierSelect.innerHTML = '<option value="">Please choose a supplier</option>'; // placeholder
    suppliers.forEach(s => {
        let option = document.createElement('option');
        option.value = s.supplier_id;
        option.text = s.supplier_name;
        supplierSelect.add(option);
    });

    // Stores
    res = await fetch('/get_stores');
    let stores = await res.json();
    ['store_id','check_store_id','reorder_store_id'].forEach(id => {
        let select = document.getElementById(id);
        select.innerHTML = '<option value="">Please choose a store</option>'; // placeholder
        stores.forEach(s => {
            let option = document.createElement('option');
            option.value = s.store_id;
            option.text = s.store_name;
            select.add(option);
        });
    });

    // Products
    res = await fetch('/get_products');
    let products = await res.json();
    ['product_id','check_product_id','reorder_product_id'].forEach(id => {
        let select = document.getElementById(id);
        select.innerHTML = '<option value="">Please choose a product</option>'; // placeholder
        products.forEach(p => {
            let option = document.createElement('option');
            option.value = p.product_id;
            option.text = p.product_name;
            select.add(option);
        });
    });
}

window.onload = loadDropdowns;

// Add delivery / restock
async function addDelivery() {
    const data = {
        supplier_id: document.getElementById('supplier_id').value,
        store_id: document.getElementById('store_id').value,
        product_id: document.getElementById('product_id').value,
        quantity_delivered: document.getElementById('quantity').value,
        delivery_date: document.getElementById('delivery_date').value
    };

    const res = await fetch('/add_delivery', {
        method: 'POST',
        headers: {'Content-Type': 'application/json'},
        body: JSON.stringify(data)
    });

    const result = await res.json();
    document.getElementById('deliveryResult').textContent = JSON.stringify(result, null, 2);

    await checkInventory();
}

// Check inventory
async function checkInventory() {
    const store_id = document.getElementById('check_store_id').value;
    const product_id = document.getElementById('check_product_id').value;
    const threshold = document.getElementById('reorder_threshold').value;

    const res = await fetch(`/check_inventory?store_id=${store_id}&product_id=${product_id}&threshold=${threshold}`);
    const result = await res.json();

    let msg = `Current Stock: ${result.current_stock}\n`;
    if(result.last_delivery !== "No delivery yet") {
        msg += `Last Delivery: ${result.last_delivery.quantity_delivered} units on ${result.last_delivery.delivery_date}\n`;
    } else {
        msg += "No deliveries yet for this product/store.\n";
    }

    msg += result.reorder_needed ? "⚠️ Reorder Required!" : "Stock is sufficient.";
    document.getElementById('inventoryResult').textContent = msg;
}


// Check reorder & restock
async function checkReorder() {
    const store_id = document.getElementById('reorder_store_id').value;
    const product_id = document.getElementById('reorder_product_id').value;
    const threshold = document.getElementById('reorder_threshold').value;
    const restock_qty = document.getElementById('restock_qty').value;

    const res = await fetch('/reorder_product', {
        method: 'POST',
        headers: {'Content-Type': 'application/json'},
        body: JSON.stringify({store_id, product_id, threshold, restock_qty})
    });

    const result = await res.json();

    let msg = `Current Stock: ${result.current_stock}\n`;
    msg += result.reorder_needed ? "⚠️ Reorder Required!" : "Stock is sufficient.";
    if(restock_qty > 0) msg += "\nRestock executed!";

    document.getElementById('reorderResult').textContent = msg;

    await checkInventory();
}

async function loadInventoryTable() {
    const res = await fetch('/inventory_table');
    const data = await res.json();

    const tbody = document.querySelector('#inventoryTable tbody');
    tbody.innerHTML = ''; // clear previous rows

    // Group by store for readability
    let currentStore = '';
    data.forEach(item => {
        if(item.store_name !== currentStore){
            // Add a row for store name
            const storeRow = document.createElement('tr');
            storeRow.innerHTML = `<td colspan="4" style="background-color: #d9edf7; font-weight: bold;">${item.store_name}</td>`;
            tbody.appendChild(storeRow);
            currentStore = item.store_name;
        }

        const tr = document.createElement('tr');
        tr.innerHTML = `
            <td></td> <!-- empty cell under store name -->
            <td>${item.product_name}</td>
            <td>${item.supplier_name}</td>
            <td>${item.quantity_in_stock}</td>
        `;
        tbody.appendChild(tr);
    });
}

async function addDelivery() {
    const data = {
        supplier_id: document.getElementById('supplier_id').value,
        store_id: document.getElementById('store_id').value,
        product_id: document.getElementById('product_id').value,
        quantity_delivered: document.getElementById('quantity').value,
        delivery_date: document.getElementById('delivery_date').value
    };

    const res = await fetch('/add_delivery', {
        method: 'POST',
        headers: {'Content-Type': 'application/json'},
        body: JSON.stringify(data)
    });

    const result = await res.json();
    if(res.status === 200){
        document.getElementById('deliveryResult').textContent = JSON.stringify(result, null, 2);
        await checkInventory();
        await loadInventoryTable();
    } else {
        document.getElementById('deliveryResult').textContent = result.error;
    }
}

