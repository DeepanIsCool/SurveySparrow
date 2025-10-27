const fs = require('fs');
const path = require('path');

const envPath = path.join(__dirname, '..', '.env');
if (fs.existsSync(envPath)) {
  const envContent = fs.readFileSync(envPath, 'utf-8');
  envContent.split('\n').forEach(line => {
    const [key, value] = line.split('=');
    if (key && value) {
      process.env[key.trim()] = value.trim();
    }
  });
}

async function initDb() {
  console.log('🔧 Database Initialization Script');
  console.log('==================================\n');

  try {
    let mysql;
    try {
      mysql = require('mysql2/promise');
    } catch (err) {
      console.log('❌ mysql2 package not found');
      console.log('📦 Install it with: npm install mysql2');
      console.log('ℹ️  Or run the app normally - it will use localStorage in browser mode\n');
      process.exit(1);
    }

    const config = {
      host: process.env.DB_HOST || 'localhost',
      port: parseInt(process.env.DB_PORT || '3306'),
      user: process.env.DB_USER || 'root',
      password: process.env.DB_PASSWORD || '',
      multipleStatements: true
    };

    console.log('📋 Configuration:');
    console.log(`   Host: ${config.host}`);
    console.log(`   Port: ${config.port}`);
    console.log(`   User: ${config.user}`);
    console.log(`   Password: ${config.password ? '***' : '(empty)'}\n`);

    const schemaPath = path.join(__dirname, '..', 'schema.sql');
    console.log(`📄 Reading schema from: ${schemaPath}`);
    
    if (!fs.existsSync(schemaPath)) {
      console.error('❌ schema.sql file not found!');
      process.exit(1);
    }

    const schema = fs.readFileSync(schemaPath, 'utf-8');
    console.log('✅ Schema file loaded\n');

    console.log('🔌 Connecting to MySQL server...');
    const connection = await mysql.createConnection({
      host: config.host,
      port: config.port,
      user: config.user,
      password: config.password,
      multipleStatements: true
    });
    console.log('✅ Connected to MySQL\n');

    console.log('⚙️  Executing schema...');
    await connection.query(schema);
    console.log('✅ Schema executed successfully\n');

    const [databases] = await connection.query('SHOW DATABASES LIKE "survey_sparrow"');
    if (databases.length > 0) {
      console.log('✅ Database "survey_sparrow" created\n');
      
      await connection.query('USE survey_sparrow');
      const [tables] = await connection.query('SHOW TABLES');
      console.log(`📊 Tables created (${tables.length} total):`);
      tables.forEach(table => {
        console.log(`   ✓ ${Object.values(table)[0]}`);
      });
      console.log('');
    }

    await connection.end();
    console.log('✅ Database initialization complete!\n');
    console.log('🚀 You can now start your application');

  } catch (error) {
    console.error('\n❌ Error:', error.message);
    console.error('\n💡 Troubleshooting:');
    console.error('   1. Check if MySQL is running');
    console.error('   2. Verify database credentials');
    console.error('   3. Ensure user has CREATE DATABASE privileges');
    console.error('   4. Check connection settings in .env file\n');
    process.exit(1);
  }
}
initDb();
