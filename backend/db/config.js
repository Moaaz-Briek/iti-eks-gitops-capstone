module.exports = {
    database: {
        name: process.env.DB_NAME || 'myDB',
        username: process.env.DB_USER || 'root',
        password: process.env.DB_PASSWORD || 'ROOT_PASSWORD',
        host: process.env.DB_HOST || 'mysql',
        dialect: 'mysql',
    },
    redis: {
        host: process.env.REDIS_HOST || 'redis',
        password: process.env.REDIS_PASSWORD || 'PASSWORD',
        db: process.env.REDIS_DB || 0,
    },
};
