var express = require('express');
var router = express.Router();
const { client, register } = require('../metrics');

const totalRequests = new client.Counter({
  name: 'index_api_requests_total',
  help: 'Total number of requests to /',
  labelNames: ['method', 'route'],
  registers: [register],
});

const successfulResponses = new client.Counter({
  name: 'index_api_success_total',
  help: 'Total number of successful responses from /',
  labelNames: ['method', 'route', 'status'],
  registers: [register],
});

const failedResponses = new client.Counter({
  name: 'index_api_failures_total',
  help: 'Total number of failed responses from /',
  labelNames: ['method', 'route', 'status'],
  registers: [register],
});

router.get('/health', async (req, res) => {
  totalRequests.inc({ method: req.method, route: '/health' });
  try {
    successfulResponses.inc({ method: req.method, route: '/health', status: 200 });
    res.status(200).json({});
  } catch (error) {
    failedResponses.inc({ method: req.method, route: '/health', status: 500 });
    res.status(500).json({ error: 'Health check failed' });
  }
});

router.get('/custom', async (req, res) => {
  totalRequests.inc({ method: req.method, route: '/custom' });
  try {
    successfulResponses.inc({ method: req.method, route: '/custom', status: 200 });
    res.status(200).json({
      res: "message test 2"
    });
  } catch (error) {
    failedResponses.inc({ method: req.method, route: '/custom', status: 500 });
    res.status(500).json({ error: 'Something went wrong' });
  }
});


module.exports = router;
