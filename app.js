import "./config/dotenv.config.js";
import express from "express";
import cors from "cors";
import helmet from "helmet";
import morgan from "morgan";
import path from "path";
import { error } from "console";

const app = express();

app.use(
  helmet({
    contentSecurityPolicy: false,
  }),
);

app.use(
  cors({
    origin: process.env.ALLOWED_ORIGINS?.split(",") || "http://localhost:3000",
    credentials: true,
  }),
);

app.use(express.json({ limit: "10mb" }));

app.use(express.urlencoded({ extended: true, limit: "10mb" }));

if (process.env.NODE_ENV === "devlopment") {
  app.use(morgan("dev"));
}

app.use(express.static(path.join(process.cwd(), "../public")));

app.use("/uploads", express.static(path.join(process.cwd(), "../uploads")));

app.get("/api/health", (req, res) => {
  res.json({
    status: "ok",
    timestamp: new Date().toISOString(),
    environment: process.env.NODE_ENV,
  });
});

app.use((req, res) => {
  if (res.path.startsWith("/api/")) {
    return res.status(404).json({
      error: "API endpoint not found",
    });
  }
  
  res.sendFile(path.join(process.cwd(), "../public/index.html"));
});

app.use((err, req, res, next) => {
  console.error("Unhandled error:", err);

  const message =
    process.env.NODE_ENV === "production"
      ? "Internal server error"
      : err.message;

  res.status(err.status || 500).json({
    error: message,
    ...(process.env.NODE_ENV === "development" && { stack: err.stack }),
  });
});

export default app;
