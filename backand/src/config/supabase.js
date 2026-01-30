import { createClient } from '@supabase/supabase-js';
import { config } from './env.js';

if (!config.supabase.url || !config.supabase.anonKey) {
    console.error('Error: Supabase credentials missing in .env');
}

export const supabase = createClient(
    config.supabase.url,
    config.supabase.anonKey
);
