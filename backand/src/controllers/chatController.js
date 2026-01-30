import { processQuery } from '../services/ragService.js';

export const handleChatQuery = async (req, res) => {
    try {
        const { query } = req.body;

        if (!query || query.trim().length === 0) {
            return res.status(400).json({ error: 'Query is required' });
        }

        console.log(`📝 Query received: ${query}`);

        const { answer, documents } = await processQuery(query);

        res.json({
            answer: answer,
            query: query,
            timestamp: new Date().toISOString(),
            source: documents.length > 0 ? 'rag-seerah-timeline' : 'gemini-general',
            sources: documents.map(d => ({
                id: d.id,
                heading: d.metadata?.heading,
                book: d.metadata?.book,
                page: d.page_number,
                references: d.metadata?.references || [],
                similarity: d.similarity
            }))
        });

    } catch (error) {
        console.error('❌ Error:', error.message);
        if (error.message.includes('429') || error.message.includes('quota')) {
            return res.status(429).json({
                answer: "I am receiving too many questions at once! Please wait 5 seconds and try again. (Rate Limit Exceeded)",
                error: 'Rate Limit Exceeded'
            });
        }
        res.status(500).json({ error: 'Failed to generate response', details: error.message });
    }
};
