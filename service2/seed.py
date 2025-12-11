"""
Service 2: Data Service
Connects to database and exposes message endpoint
"""
from fastapi import FastAPI, HTTPException
import os
import psycopg2

app = FastAPI(title="Data Service")


def get_db_conn():
    db_user = os.environ["DB_USER"]
    db_password = os.environ["DB_PASSWORD"]
    
    return psycopg2.connect(
        host=os.getenv("DB_HOST", "db"),
        port=os.getenv("DB_PORT", "5432"),
        dbname=os.getenv("DB_NAME", "messages_db"),
        user=db_user,
        password=db_password,
    )


@app.get("/api/message")
def read_message():
    try:
        conn = get_db_conn()
        with conn:
            with conn.cursor() as cur:
                cur.execute("SELECT content FROM messages ORDER BY id LIMIT 1;")
                row = cur.fetchone()
        conn.close()
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Database error: {e}")

    if not row:
        raise HTTPException(status_code=404, detail="No message found in database")

    return {"message": row[0]}
