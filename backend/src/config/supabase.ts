import { createClient } from '@supabase/supabase-js';
import { env } from './env.js';

// Admin client — bypasses RLS, use only in server-side controllers
// eslint-disable-next-line @typescript-eslint/no-explicit-any
export const supabase = createClient<any>(
  env.supabase.url,
  env.supabase.serviceRoleKey,
  { auth: { autoRefreshToken: false, persistSession: false } }
);

// Helper: create a client scoped to the requesting user's JWT
export const supabaseForUser = (accessToken: string) =>
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  createClient<any>(env.supabase.url, env.supabase.anonKey, {
    global: { headers: { Authorization: `Bearer ${accessToken}` } },
    auth: { autoRefreshToken: false, persistSession: false },
  });
