import dotenv from 'dotenv';
import { GoogleGenerativeAI } from '@google/generative-ai';

dotenv.config();

const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY);

async function listModels() {
    try {
        const model = genAI.getGenerativeModel({ model: 'gemini-1.5-flash-001' });
        // There isn't a direct "listModels" method on the client instance easily accessible in all versions without admin SDK or knowing the REST endpoint, 
        // but we can try a simple generation to see if it works, or relying on documentation. 
        // Wait, the new SDK might not have a public listModels helper for API keys (often restricted).
        // Let's just try to run a simple prompt.

        console.log('Testing gemini-1.5-flash-001...');
        const result = await model.generateContent('Hello');
        console.log('Success! Response:', result.response.text());
    } catch (error) {
        console.error('Error with gemini-1.5-flash-001:', error.message);

        console.log('\nTrying gemini-pro...');
        try {
            const modelPro = genAI.getGenerativeModel({ model: 'gemini-pro' });
            const resultPro = await modelPro.generateContent('Hello');
            console.log('Success with gemini-pro! Response:', resultPro.response.text());
        } catch (err2) {
            console.error('Error with gemini-pro:', err2.message);
        }
    }
}

listModels();
