from flask import Flask, jsonify, request

app = Flask(__name__)


@app.route(
    "/",
    defaults={"path": ""},
    methods=["GET", "POST", "PUT", "DELETE", "PATCH", "OPTIONS"],
)
@app.route("/<path:path>", methods=["GET", "POST", "PUT", "DELETE", "PATCH", "OPTIONS"])
def echo(path):
    try:
        json_data = request.json
    except Exception:
        json_data = None
    return jsonify(
        {
            "path": path,
            "method": request.method,
            "headers": dict(request.headers),
            "args": request.args.to_dict(),
            "form": request.form.to_dict(),
            "json": json_data,
            "data": request.data.decode("utf-8"),
        }
    )


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
