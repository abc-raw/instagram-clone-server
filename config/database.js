import postgres from "postgres";
import dotenv from "dotenv";

dotenv.config();

const sql = postgres(process.env.DATABASE_URL, {
  max: 10,
  idle_timeout: 30,
  debug: process.env.NODE_ENV === "development",
});

try {
  await sql`select 1`;
  console.log("Database connected successfully");
} catch (err) {
  console.error("Database connection failed:", err.message);
  process.exit(1);
}
