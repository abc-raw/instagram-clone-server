import '../config/dotenv.config.js'
import postgres from "postgres";
import fs from 'fs';
import path from 'path';

const sql = postgres(process.env.DATABASE_URL);


async function runMigrations() {
    console.log('Running database migrations...');

    await sql`
    CREATE TABLE IF NOT EXISTS migrations (
        id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
        filename VARCHAR(255) UNIQUE NOT NULL,
        run_at TIMESTAMP DEFAULT NOW()
    )
    `;

    const migrationsDir = path.join(process.cwd(), 'db/migrations');
    const files = fs.readdirSync(migrationsDir)
    .filter(f => f.endsWith('.sql'))
    .sort();

    for (const filename of files) {
        const [existing] = await sql`
            SELECT id FROM migrations WHERE filename = ${filename}
        `;
        if (existing) {
            console.log(`Skipping ${filename} (already applied)`);
            continue;
        }

        const filepath = path.join(migrationsDir, filename);
        const sqlContent = fs.readFileSync(filepath, 'utf8');

        try {
            await sql.begin(async sql=> {
                await sql.unsafe(sqlContent);
                await sql`INSERT INTO migrations (filename) values (${filename})`;
            });
            console.log('Applied ' + filename);
        } catch (err) {
            console.error(`Failed to apply ${filename}: `, err.message);
            process.exit(1);
        }
    }
    console.log('Migrations complete!');
    await sql.end();
}

runMigrations().catch(console.error);