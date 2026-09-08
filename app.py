from flask import Flask

app = Flask(__name__)

@app.route("/")
def home():
    return """
    <h1>Nelson's Secure Azure Web App</h1>
    <p>Deployed from GitHub to Microsoft Azure.</p>
    <p>Cloud Security Portfolio Project</p>
    """

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8000)
