import pkg from 'pg';
const { Pool } = pkg;
import dotenv from 'dotenv';
dotenv.config();

// ============================================
// DEVICE-TIME FIX: Override pg TIMESTAMP parser for correct timezone handling
// All database sessions are forced to UTC via pool.on('connect') below.
// Raw TIMESTAMP WITHOUT TIMEZONE values from PostgreSQL are therefore in UTC.
// This parser appends 'Z' suffix to produce proper UTC ISO 8601 strings.
// No hardcoded timezone offsets — the mobile client converts UTC to device
// local time using DateTime.toLocal() for correct display.
// ============================================
const pgTypes = pkg.types;

// OID 1114 = TIMESTAMP WITHOUT TIMEZONE
pgTypes.setTypeParser(1114, function parseTimestampAsUTC(val) {
  if (!val) return null;
  // Raw value is in UTC (session timezone forced to UTC via pool.on('connect'))
  // Append 'Z' suffix so clients know this is a UTC ISO 8601 string
  return val.replace(' ', 'T') + 'Z';
});

// Configure the PostgreSQL connection pool
// Optimized for serverless environments
const pool = new Pool({
  ...(process.env.DATABASE_PUBLIC_URL
    ? { connectionString: process.env.DATABASE_PUBLIC_URL }
    : {
        host: process.env.DB_HOST,
        port: process.env.DB_PORT || 5432,
        user: process.env.DB_USER,
        password: process.env.DB_PASSWORD,
        database: process.env.DB_NAME
      }),
  ssl: {
    rejectUnauthorized: false // Required for AWS RDS/managed Postgres
  },
  max: 5, // Reduced for serverless - each function instance gets its own pool
  idleTimeoutMillis: 10000, // Close idle connections faster in serverless
  connectionTimeoutMillis: 10000,
  // DEVICE-TIME FIX: Removed hardcoded timezone: 'Asia/Kolkata' — session
  // timezone is set to UTC via pool.on('connect') below for consistency.
});

// DEVICE-TIME FIX: Force all database sessions to UTC so CURRENT_TIMESTAMP
// always stores UTC values. This prevents timezone ambiguity with
// TIMESTAMP WITHOUT TIMEZONE columns regardless of server location.
pool.on('connect', (client) => {
  client.query("SET timezone = 'UTC'");
});

// Test the database connection
async function testConnection(retries = 3) {
  for (let attempt = 1; attempt <= retries; attempt++) {
    try {
      const client = await pool.connect();
      console.log('✓ Successfully connected to AWS RDS PostgreSQL database');
      
      // Test query
      const result = await client.query('SELECT NOW()');
      console.log('Current database time:', result.rows[0].now);
      
      client.release();
      return true;
    } catch (error) {
      console.error(`✗ Error connecting to the database (attempt ${attempt}/${retries}):`, error.message);
      if (attempt === retries) {
        return false;
      }
      // Wait 2 seconds before retrying
      await new Promise(resolve => setTimeout(resolve, 2000));
    }
  }
}

// Ensure required columns exist on startup (non-destructive)
async function ensureSchema() {
  try {
    // Ensure UUID function is available
    await pool.query('CREATE EXTENSION IF NOT EXISTS pgcrypto;');

    // Create admins table if it doesn't exist
    const createAdminsSql = `
      CREATE TABLE IF NOT EXISTS admins (
        admin_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
        email VARCHAR(255) UNIQUE NOT NULL,
        password_hash VARCHAR(255) NOT NULL,
        full_name VARCHAR(100),
        is_active BOOLEAN DEFAULT TRUE,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        last_login TIMESTAMP
      );
    `;
    await pool.query(createAdminsSql);
    console.log('✓ Ensured admins table exists');

    // Add commonly used social auth columns if they don't exist yet
    const alterSql = `
      ALTER TABLE users ADD COLUMN IF NOT EXISTS auth_provider VARCHAR(20) DEFAULT 'phone';
      ALTER TABLE users ADD COLUMN IF NOT EXISTS google_id VARCHAR(255);
      ALTER TABLE users ADD COLUMN IF NOT EXISTS facebook_id VARCHAR(255);
      ALTER TABLE users ADD COLUMN IF NOT EXISTS account_type VARCHAR(20) DEFAULT 'user';
      ALTER TABLE users ADD COLUMN IF NOT EXISTS languages TEXT[];
      ALTER TABLE users ADD COLUMN IF NOT EXISTS last_seen TIMESTAMP;
      
      -- Add listener table columns if they don't exist
      ALTER TABLE listeners ADD COLUMN IF NOT EXISTS original_name VARCHAR(100);
      ALTER TABLE listeners ADD COLUMN IF NOT EXISTS experiences TEXT[];
      ALTER TABLE listeners ADD COLUMN IF NOT EXISTS voice_verified BOOLEAN DEFAULT FALSE;
      ALTER TABLE listeners ADD COLUMN IF NOT EXISTS voice_verification_url TEXT;
      ALTER TABLE listeners ADD COLUMN IF NOT EXISTS last_active_at TIMESTAMP;
    `;
    await pool.query(alterSql);
    console.log('✓ Ensured users and listeners table schema');
    
    // If phone_number is marked NOT NULL in the existing DB, allow nulls for social accounts
    const dropNotNullSql = `
      DO $$
      BEGIN
        IF EXISTS (
          SELECT 1 FROM information_schema.columns
          WHERE table_name = 'users' AND column_name = 'phone_number' AND is_nullable = 'NO'
        ) THEN
          EXECUTE 'ALTER TABLE users ALTER COLUMN phone_number DROP NOT NULL';
        END IF;
      END$$;
    `;
    await pool.query(dropNotNullSql);
    console.log('✓ Ensured phone_number is nullable if previously NOT NULL');
  } catch (error) {
    console.error('Error ensuring schema:', error.message);
    throw error;
  }
}

// Generic query execution function
async function executeQuery(query, params = []) {
  try {
    const result = await pool.query(query, params);
    return result.rows;
  } catch (error) {
    console.error('Query error:', error.message);
    throw error;
  }
}

// Close the connection pool
async function closePool() {
  await pool.end();
  console.log('Database connection pool closed');
}

export { pool, testConnection, executeQuery, closePool };
export { ensureSchema };



















// // aws //



// import pkg from 'pg';
// const { Pool } = pkg;
// import dotenv from 'dotenv';
// dotenv.config();

// // Configure the PostgreSQL connection pool
// // Optimized for serverless environments
// const pool = new Pool({
//   host: process.env.DB_HOST,
//   port: process.env.DB_PORT || 5432,
//   user: process.env.DB_USER,
//   password: process.env.DB_PASSWORD,
//   database: process.env.DB_NAME,
//   ssl: {
//     rejectUnauthorized: false // Required for AWS RDS
//   },
//   max: 5, // Reduced for serverless - each function instance gets its own pool
//   idleTimeoutMillis: 10000, // Close idle connections faster in serverless
//   connectionTimeoutMillis: 10000,
//   timezone: 'Asia/Kolkata' // Set timezone to IST for proper timestamp handling
// });

// // Test the database connection
// async function testConnection(retries = 3) {
//   for (let attempt = 1; attempt <= retries; attempt++) {
//     try {
//       const client = await pool.connect();
//       console.log('✓ Successfully connected to AWS RDS PostgreSQL database');
      
//       // Test query
//       const result = await client.query('SELECT NOW()');
//       console.log('Current database time:', result.rows[0].now);
      
//       client.release();
//       return true;
//     } catch (error) {
//       console.error(`✗ Error connecting to the database (attempt ${attempt}/${retries}):`, error.message);
//       if (attempt === retries) {
//         return false;
//       }
//       // Wait 2 seconds before retrying
//       await new Promise(resolve => setTimeout(resolve, 2000));
//     }
//   }
// }

// // Ensure required columns exist on startup (non-destructive)
// async function ensureSchema() {
//   try {
//     // Create admins table if it doesn't exist
//     const createAdminsSql = `
//       CREATE TABLE IF NOT EXISTS admins (
//         admin_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
//         email VARCHAR(255) UNIQUE NOT NULL,
//         password_hash VARCHAR(255) NOT NULL,
//         full_name VARCHAR(100),
//         is_active BOOLEAN DEFAULT TRUE,
//         created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
//         updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
//         last_login TIMESTAMP
//       );
//     `;
//     await pool.query(createAdminsSql);
//     console.log('✓ Ensured admins table exists');

//     // Add commonly used social auth columns if they don't exist yet
//     const alterSql = `
//       ALTER TABLE users ADD COLUMN IF NOT EXISTS auth_provider VARCHAR(20) DEFAULT 'phone';
//       ALTER TABLE users ADD COLUMN IF NOT EXISTS google_id VARCHAR(255);
//       ALTER TABLE users ADD COLUMN IF NOT EXISTS facebook_id VARCHAR(255);
//       ALTER TABLE users ADD COLUMN IF NOT EXISTS account_type VARCHAR(20) DEFAULT 'user';
//       ALTER TABLE users ADD COLUMN IF NOT EXISTS languages TEXT[];
//       ALTER TABLE users ADD COLUMN IF NOT EXISTS last_seen TIMESTAMP;
      
//       -- Add listener table columns if they don't exist
//       ALTER TABLE listeners ADD COLUMN IF NOT EXISTS original_name VARCHAR(100);
//       ALTER TABLE listeners ADD COLUMN IF NOT EXISTS experiences TEXT[];
//       ALTER TABLE listeners ADD COLUMN IF NOT EXISTS voice_verified BOOLEAN DEFAULT FALSE;
//       ALTER TABLE listeners ADD COLUMN IF NOT EXISTS voice_verification_url TEXT;
//       ALTER TABLE listeners ADD COLUMN IF NOT EXISTS last_active_at TIMESTAMP;
//     `;
//     await pool.query(alterSql);
//     console.log('✓ Ensured users and listeners table schema');
    
//     // If phone_number is marked NOT NULL in the existing DB, allow nulls for social accounts
//     const dropNotNullSql = `
//       DO $$
//       BEGIN
//         IF EXISTS (
//           SELECT 1 FROM information_schema.columns
//           WHERE table_name = 'users' AND column_name = 'phone_number' AND is_nullable = 'NO'
//         ) THEN
//           EXECUTE 'ALTER TABLE users ALTER COLUMN phone_number DROP NOT NULL';
//         END IF;
//       END$$;
//     `;
//     await pool.query(dropNotNullSql);
//     console.log('✓ Ensured phone_number is nullable if previously NOT NULL');
//   } catch (error) {
//     console.error('Error ensuring schema:', error.message);
//     throw error;
//   }
// }

// // Generic query execution function
// async function executeQuery(query, params = []) {
//   try {
//     const result = await pool.query(query, params);
//     return result.rows;
//   } catch (error) {
//     console.error('Query error:', error.message);
//     throw error;
//   }
// }

// // Close the connection pool
// async function closePool() {
//   await pool.end();
//   console.log('Database connection pool closed');
// }

// export { pool, testConnection, executeQuery, closePool };
// export { ensureSchema };
