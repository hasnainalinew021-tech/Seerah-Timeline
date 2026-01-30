import dotenv from 'dotenv';
dotenv.config();

export const config = {
    port: process.env.PORT || 3000,
    gemini: {
        apiKey: process.env.GEMINI_API_KEY,
        model: 'gemini-flash-latest',
        embeddingModel: 'gemini-embedding-001',
    },
    supabase: {
        url: process.env.SUPABASE_URL,
        anonKey: process.env.SUPABASE_ANON_KEY,
    }
};
