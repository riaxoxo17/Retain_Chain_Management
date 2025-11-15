Online Job Recommendation System — DBMS Mini Project
Overview

The system stores job listings, user details, and job applications. It generates vector embeddings for job descriptions and matches them to user queries using similarity search. The project includes SQL scripts for schema creation, sample data, embedding generation, and Python scripts to run recommendations.

Features
- PostgreSQL database with normalized schema
- ER diagram for reference
- CRUD operations on all major tables
- pgvector-based vector search
- Python scripts for:
1. generating embeddings
2. running similarity-based recommendations
3. Screenshots included for database setup and output results
4. Tech Stack
5. PostgreSQL
6. pgvector extension
7. Python (NumPy, psycopg2)
8. pgAdmin4
9. VS Code / Terminal


Database Setup
Step 1: Create the database and enable pgvector
Step 2: Run schema.sql to generate tables
Step 3: Run insert_data.sql to insert sample values
Step 4: Use embedder.py to generate and store vector embeddings


Recommendation System

The recommendation engine takes a user query, converts it into a vector using the embedder script, and finds the most similar job descriptions using cosine similarity through pgvector.
Running the script displays the top job recommendations ranked by relevance.

CRUD Operations

The project includes CRUD operations for:
-jobs
-applicants
-job applications



How to Run

Clone the repository
Install required Python dependencies
Set up PostgreSQL and execute all SQL scripts
Generate embeddings using the embedder
Run the recommendation script

This will return job recommendations based on the user's input.
