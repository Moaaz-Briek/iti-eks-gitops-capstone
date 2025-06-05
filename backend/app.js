var express = require('express');
var path = require('path');
var logger = require('morgan');
const sequelize = require('./db/sequelize-instance');
const redis = require('./db/redis');
const cors = require('cors');

var postsRouter = require('./routes/posts');
var indexRouter = require('./routes/index');
var metricsRouter = require('./routes/metrics');

var app = express();

sequelize
  .authenticate()
  .then(() => {
    return sequelize.sync({ alter: true });
  })
  .then(() => {
    console.log('Database synchronized.');
  })
  .catch((err) => {
    console.error('Unable to connect to the database:', err);
    throw new Error('Database Connection Failed');
  });

redis.on('connect', () => {
  console.log('Connected to Redis');
});

redis.on('ready', () => {
  console.log('Redis is ready to use');
});

redis.on('error', (err) => {
  console.error('Redis connection failed:', err);
  throw new Error('Redis Connection Failed');
});


app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: false }));


app.use('/', indexRouter);
app.use('/posts', postsRouter);
app.use('/metrics', metricsRouter);

module.exports = app;
