import './config/env.js'; // Load & validate env vars first
import express from 'express';
import cors from 'cors';
import { env } from './config/env.js';
import apiRoutes from './routes/index.js';
import { errorHandler, notFound } from './middleware/errorHandler.js';

const app = express();

// ─── Global Middleware ────────────────────────────────────────────────────────
app.use(
  cors({
    origin: env.corsOrigins,
    credentials: true,
    methods: ['GET', 'POST', 'PATCH', 'PUT', 'DELETE', 'OPTIONS'],
    allowedHeaders: ['Content-Type', 'Authorization'],
  })
);
app.use(express.json({ limit: '1mb' }));
app.use(express.urlencoded({ extended: true }));

// ─── Health ───────────────────────────────────────────────────────────────────
app.get('/health', (_req, res) => {
  res.json({ status: 'ok', service: 'muul-backend', env: env.nodeEnv });
});

// ─── API Routes ───────────────────────────────────────────────────────────────
app.use(env.apiPrefix, apiRoutes);

// ─── 404 / Error Handlers ─────────────────────────────────────────────────────
app.use(notFound);
app.use(errorHandler);

// ─── Start ────────────────────────────────────────────────────────────────────
app.listen(env.port, () => {
  console.log(`muul-backend listening on port ${env.port} [${env.nodeEnv}]`);
  console.log(`API prefix: ${env.apiPrefix}`);
});
