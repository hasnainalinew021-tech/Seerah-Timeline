import dotenv from 'dotenv';
dotenv.config();

const API_KEY = process.env.GEMINI_API_KEY;

async function checkModels() {
    if (!API_KEY) {
        console.error('❌ No API Key found in .env');
        return;
    }

    const url = `https://generativelanguage.googleapis.com/v1beta/models?key=${API_KEY}`;

    console.log('🔍 Fetching available models from Gemini API...');

    try {
        const response = await fetch(url);
        const data = await response.json();

        if (data.error) {
            console.error('❌ API Error:', data.error);
            return;
        }

        if (!data.models) {
            console.log('⚠️ No models returned. Response:', data);
            return;
        }

        console.log('\n✅ Available Models for your key:');
        const generateModels = data.models
            .filter(m => m.supportedGenerationMethods && m.supportedGenerationMethods.includes('generateContent'))
            .map(m => m.name.replace('models/', ''));

        console.log(generateModels.join('\n'));

    } catch (error) {
        console.error('❌ Network/Fetch Error:', error.message);
    }
}

checkModels();
