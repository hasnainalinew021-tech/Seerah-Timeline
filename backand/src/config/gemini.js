import { GoogleGenerativeAI } from '@google/generative-ai';
import { config } from './env.js';

if (!config.gemini.apiKey) {
    console.error('Error: GEMINI_API_KEY missing in .env');
}

export const genAI = new GoogleGenerativeAI(config.gemini.apiKey);
export const model = genAI.getGenerativeModel({ model: config.gemini.model });
export const embeddingModel = genAI.getGenerativeModel({ model: config.gemini.embeddingModel });
