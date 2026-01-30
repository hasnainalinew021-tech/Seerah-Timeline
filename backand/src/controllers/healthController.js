import { config } from '../config/env.js';

export const checkHealth = (req, res) => {
    console.log('✅ Health check called');
    res.json({
        status: 'ok',
        message: 'Server is running',
        gemini: config.gemini.apiKey ? 'configured ✅' : 'missing ❌',
        timestamp: new Date().toISOString()
    });
};
