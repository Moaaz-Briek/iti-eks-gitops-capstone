module.exports = {
    database: {
        host: process.env.MYSQL_HOST || 'mysql',
        username: process.env.MYSQL_USER || 'root',
        password: process.env.MYSQL_PASSWORD || 'ROOT_PASSWORD',
        name: process.env.MYSQL_DATABASE || 'myDB',
        dialect: 'mysql',
    },
    
    redis: {
        host: process.env.REDIS_HOST || 'redis',
        password: process.env.REDIS_PASSWORD || 'PASSWORD',
        db: process.env.REDIS_DB || 0,
    },
};
