from flask import Flask

app = Flask(__name__)


@app.route("/")
def home():
   return "Azure Cloud Lab V2 - CI/CD deployment works!\n"

@app.route("/health")
def health():
    return {"status": "ok"}


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8080)
