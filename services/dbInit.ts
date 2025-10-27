import { promises as fs } from 'fs';
import path from 'path';

export interface DbConfig {
  host: string;
  port: number;
  user: string;
  password: string;
  database: string;
}

export const getDbConfig = (): DbConfig => ({
  host: process.env.DB_HOST || 'localhost',
  port: parseInt(process.env.DB_PORT || '3306'),
  user: process.env.DB_USER || 'root',
  password: process.env.DB_PASSWORD || '',
  database: process.env.DB_NAME || 'survey_sparrow',
});

export async function initializeDatabase(): Promise<void> {
  try {
    console.log('🔧 Initializing database...');
    
    const schemaPath = path.join(__dirname, '..', 'schema.sql');
    const schema = await fs.readFile(schemaPath, 'utf-8');
    
    if (typeof window !== 'undefined') {
      console.log('📦 Running in browser mode - using localStorage');
      console.log('ℹ️  MySQL schema is available for server-side deployment');
      return;
    }
    
    const mysql = require('mysql2/promise');
    const config = getDbConfig();
    
    const connection = await mysql.createConnection({
      host: config.host,
      port: config.port,
      user: config.user,
      password: config.password,
      multipleStatements: true
    });
    
    console.log('✅ Connected to MySQL server');
    
    await connection.query(schema);
    
    console.log('✅ Database and tables created successfully');
    
    await connection.end();
    
    console.log('✅ Database initialization complete');
  } catch (error) {
    console.error('❌ Error initializing database:', error);
    throw error;
  }
}

export async function checkDatabaseConnection(): Promise<boolean> {
  try {
    if (typeof window !== 'undefined') {
      return true;
    }
    
    
    return true;
  } catch (error) {
    console.error('Database connection check failed:', error);
    return false;
  }
}
