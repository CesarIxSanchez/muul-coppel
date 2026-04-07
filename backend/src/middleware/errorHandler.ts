import type { Request, Response, NextFunction } from 'express';

export interface ApiError extends Error {
  statusCode?: number;
  code?: string;
}

export function errorHandler(
  err: ApiError,
  _req: Request,
  res: Response,
  _next: NextFunction
): void {
  const statusCode = err.statusCode ?? 500;
  const message = err.message ?? 'Internal server error';

  console.error(`[${new Date().toISOString()}] ${statusCode} — ${message}`, err.stack);

  res.status(statusCode).json({
    error: {
      message,
      code: err.code ?? 'INTERNAL_ERROR',
      ...(process.env.NODE_ENV === 'development' && { stack: err.stack }),
    },
  });
}

export function notFound(_req: Request, res: Response): void {
  res.status(404).json({ error: { message: 'Route not found', code: 'NOT_FOUND' } });
}

// Wrap async route handlers to forward errors to errorHandler
export const asyncHandler =
  (fn: (req: Request, res: Response, next: NextFunction) => Promise<unknown>) =>
  (req: Request, res: Response, next: NextFunction): void => {
    fn(req, res, next).catch(next);
  };

export function createError(message: string, statusCode: number, code?: string): ApiError {
  const err: ApiError = new Error(message);
  err.statusCode = statusCode;
  err.code = code;
  return err;
}
