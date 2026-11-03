import os
import requests
from flask import Flask, jsonify
from prometheus_flask_exporter import PrometheusMetrics

app = Flask(__name__)
PrometheusMetrics(app, group_by='url_rule')


@app.route('/')
def call_b():
    service_b_url = os.environ['SERVICE_B_URL']
    response = requests.get(service_b_url, timeout=5)
    response.raise_for_status()
    return f"A -> {response.text}"


@app.route('/health')
def health():
    return jsonify(status="ok"), 200


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8080)
