const mysql = require('mysql2');

const pool = mysql.createPool({
    // CORREGIDO: Lee la variable de entorno de Docker Compose. Si no existe, usa 'db' por defecto.
    host: process.env.DB_HOST || 'db',
    
    // CORREGIDO: Lee las credenciales de la app inyectadas en Docker.
    user: process.env.DB_USER || 'sigas_app',
    password: process.env.DB_PASSWORD || 'password123',
    database: process.env.DB_NAME || 'sigas',
    
    waitForConnections: true,
    connectionLimit: 10,
    queueLimit: 0
}).promise();

module.exports = pool;
