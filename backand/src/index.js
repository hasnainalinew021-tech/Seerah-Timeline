import { config } from './config/env.js';
import app from './app.js';

const PORT = config.port;

// Debug: Check if API key is loaded
console.log('\n🔍 Environment Check:');
console.log('GEMINI_API_KEY exists:', !!config.gemini.apiKey);
console.log('GEMINI_API_KEY first 10 chars:', config.gemini.apiKey?.substring(0, 10));
console.log('PORT:', PORT);
console.log('');

app.listen(PORT, () => {
  console.log(`
╔═════════════════════════════════════════╗
║   🚀 Seerah Chatbot API                ║
╠═════════════════════════════════════════╣
║   Port: ${PORT}                            ║
║   Status: ✅ Running                    ║
║   Health: http://localhost:${PORT}/health    ║
║   Chat: POST /api/chat/query           ║
╚═════════════════════════════════════════╝
  `);
});