const express = require('express');
const fs = require('fs');
const path = require('path');
const client = require('prom-client');

const app = express();
const PORT = process.env.PORT || 3000;
const DATA_DIR = process.env.DATA_DIR || '/data';
const DATA_FILE = path.join(DATA_DIR, 'counter.txt');

client.collectDefaultMetrics();

const httpCounter = new client.Counter({
  name: 'http_requests_total',
  help: 'Total des requêtes HTTP',
  labelNames: ['method', 'route', 'status'],
});

const httpDuration = new client.Histogram({
  name: 'http_request_duration_seconds',
  help: 'Durée des requêtes HTTP en secondes',
  labelNames: ['method', 'route', 'status'],
  buckets: [0.005, 0.01, 0.025, 0.05, 0.1, 0.25, 0.5, 1, 2.5, 5, 10],
});

app.use((req, res, next) => {
  const end = httpDuration.startTimer();
  res.on('finish', () => {
    const labels = { method: req.method, route: req.path, status: res.statusCode };
    httpCounter.inc(labels);
    end(labels);
  });
  next();
});

app.get('/health', (req, res) => res.status(200).json({ status: 'ok' }));

app.get('/metrics', async (req, res) => {
  res.set('Content-Type', client.register.contentType);
  res.end(await client.register.metrics());
});

app.get('/', (req, res) => {
  let count = 0;
  if (fs.existsSync(DATA_FILE)) {
    count = parseInt(fs.readFileSync(DATA_FILE, 'utf8'), 10) || 0;
  }
  count++;
  fs.writeFileSync(DATA_FILE, String(count));
  res.send(`C (Visites: ${count})`);
});

app.listen(PORT, () => console.log(`C listening on ${PORT}, data=${DATA_FILE}`));
