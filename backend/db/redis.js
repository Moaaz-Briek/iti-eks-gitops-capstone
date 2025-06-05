const Redis = require('ioredis');
const config = require('./config');

const redis = new Redis({
    host: config.redis.host,
    password: config.redis.password,
    db: config.redis.db,
});

module.exports = redis;
