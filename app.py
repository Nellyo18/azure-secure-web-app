import os
import struct

import pyodbc
from azure.identity import DefaultAzureCredential
from flask import Flask, request
from azure.keyvault.secrets import SecretClient
from azure.monitor.opentelemetry import configure_azure_monitor
app = Flask(__name__)

SQL_SERVER = os.environ["SQL_SERVER"]
SQL_DATABASE = os.environ["SQL_DATABASE"]
KEY_VAULT_URL = os.environ["KEY_VAULT_URL"]

configure_azure_monitor()

credential = DefaultAzureCredential()

secret_client = SecretClient(
    vault_url=KEY_VAULT_URL,
    credential=credential
)
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

    <p><a href="/messages">View Messages</a></p>
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


@app.route("/messages")
def messages():
    try:
        conn = get_db_connection()
        cursor = conn.cursor()

        cursor.execute("""
            SELECT Id, MessageText, CreatedAt
            FROM Messages
            ORDER BY CreatedAt DESC
        """)

        rows = cursor.fetchall()

        cursor.close()
        conn.close()

        message_html = ""

        for row in rows:
            message_html += f"""
            <li>
                {row.MessageText}
                <small>({row.CreatedAt})</small>
            </li>
            """

        return f"""
        <h1>Messages Stored in Azure SQL</h1>

        <form action="/add-message" method="post">
            <input
                type="text"
                name="message"
                maxlength="255"
                required
                placeholder="Enter a message"
            >
            <button type="submit">Add Message</button>
        </form>

        <ul>
            {message_html}
        </ul>

        <p><a href="/">Back Home</a></p>
        """

    except Exception as error:
        return f"""
        <h1>Failed to Read Messages</h1>
        <pre>{str(error)}</pre>
        """, 500


@app.route("/add-message", methods=["POST"])
def add_message():
    try:
        message = request.form.get("message", "").strip()

        if not message:
            return "Message cannot be empty.", 400

        conn = get_db_connection()
        cursor = conn.cursor()

        cursor.execute(
            "INSERT INTO Messages (MessageText) VALUES (?)",
            message
        )

        conn.commit()

        cursor.close()
        conn.close()

        return """
        <h1>Message Added Successfully</h1>
        <p><a href="/messages">Return to Messages</a></p>
        """

    except Exception as error:
        return f"""
        <h1>Failed to Add Message</h1>
        <pre>{str(error)}</pre>
        """, 500

@app.route("/keyvault")
def keyvault_test():
    try:
        secret = secret_client.get_secret("portfolio-banner")

        return f"""
        <h1>Azure Key Vault Connection Successful</h1>
        <p>Secret retrieved:</p>
        <p>{secret.value}</p>
        <p><a href="/">Back Home</a></p>
        """

    except Exception as error:
        return f"""
        <h1>Key Vault Connection Failed</h1>
        <pre>{str(error)}</pre>
        """, 500
if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8000)

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8000)
