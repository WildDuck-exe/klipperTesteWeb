// Supabase Project details
const SUPABASE_URL = 'https://ocsykbqshxitgkpxgvzv.supabase.co';
const SUPABASE_ANON_KEY = 'sb_publishable_ocenpEvX8g_twg1mo0nB6A_JL4ltrV-';

const _supabase = supabase.createClient(SUPABASE_URL, SUPABASE_ANON_KEY);

// Backend Flask URL — usado pelo chat.js para chamadas a /api/public/*
const BACKEND_URL = 'https://danger-habitual-exonerate.ngrok-free.dev'; // ajustar para prod