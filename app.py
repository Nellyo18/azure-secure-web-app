import os
import struct

import pyodbc
from azure.identity import DefaultAzureCredential
from flask import Flask

app = Flask(__name__)

SQL_SERVER = os.environ["SQL_SERVER"]
SQL_DATABASE = os.environ["SQL_DATABASE"]


def get_db_connection():
    credential = DefaultAzureCredential()

    token = credential.get_token(
        "https://database.windows.net/.default"
    ).token

    token_bytes = token.encode("utf-16-le")
    token_struct = struct.pack(
        f"<I{len(token_bytes)}s",
        len(token_bytes),
        token_bytes,
    )

    connection_string = (
        "Driver={ODBC Driver 18 for SQL Server};"
        f"Server=tcp:{SQL_SERVER},1433;"
        f"Database={SQL_DATABASE};"
        "Encrypt=yes;"
        "TrustServerCertificate=no;"
        "Connection Timeout=30;"
    )

    SQL_COPT_SS_ACCESS_TOKEN = 1256

    return pyodbc.connect(
        connection_string,
        attrs_before={SQL_COPT_SS_ACCESS_TOKEN: token_struct},
    )


@app.route("/")
def home():
    return """
    <h1>Nelson's Secure Azure Web App</h1>
    <p>Deployed from GitHub to Microsoft Azure.</p>
    <p>Cloud Security Portfolio Project</p>
    """


@app.route("/database")
def database_test():
    try:
        conn = get_db_connection()
        cursor = conn.cursor()

        cursor.execute("SELECT DB_NAME(), SYSTEM_USER")
        row = cursor.fetchone()

        cursor.close()
        conn.close()

        return f"""
        <h1>Azure SQL Connection Successful</h1>
        <p>Database: {row[0]}</p>
        <p>Authenticated identity: {row[1]}</p>
        """

    except Exception as error:
        return f"""
        <h1>Database Connection Failed</h1>
        <pre>{str(error)}</pre>
        """, 500


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8000)
