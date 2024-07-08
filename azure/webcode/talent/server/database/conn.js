const mysql = require('mysql')
const dotenv = require('dotenv');
dotenv.config();
const connection = mysql.createConnection({
    host: process.env.DB_HOST || 'localhost',
    user: process.env.DB_USER || 'root',
    password: process.env.DB_PASS || 'password',
    database: process.env.DB_NAME || 'test',
    ssl: {rejectUnauthorized: false}
})

console.log(process.env.DB_HOST);

connection.connect(function(err) {
    if (err) throw err;
});

module.exports = connection;