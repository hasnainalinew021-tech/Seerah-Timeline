import { createClient } from '@supabase/supabase-js';
import { GoogleGenerativeAI } from '@google/generative-ai';
import dotenv from 'dotenv';
dotenv.config();

const supabase = createClient(process.env.SUPABASE_URL, process.env.SUPABASE_ANON_KEY);
const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY);
const model = genAI.getGenerativeModel({ model: "gemini-embedding-001" });

async function testSearch() {
    const query = "سیرت کیا ہے؟";
    console.log(`🔎 Testing Search for: "${query}"`);

    // 1. Generate Embedding
    const result = await model.embedContent({
        content: { parts: [{ text: query }] },
        outputDimensionality: 768
    });
    const queryEmbedding = result.embedding.values;

    // 2. Manual Search: Get ALL chunks and calculate similarity manually to see what's happening
    const { data: allChunks, error } = await supabase
        .from('seerah_chunks')
        .select('id, text, embedding, metadata');

    if (error) {
        console.error('❌ DB Error:', error);
        return;
    }

    console.log(`📊 Comparing against ${allChunks.length} chunks...`);

    // Calculate cosine similarity manually
    const scores = allChunks.map(chunk => {
        const similarity = cosineSimilarity(queryEmbedding, chunk.embedding);
        // Extract heading from text or metadata for display
        const heading = chunk.metadata?.heading || chunk.text.substring(0, 50);
        return { heading, similarity, text: chunk.text.substring(0, 100) };
    });

    // Sort by similarity descending
    scores.sort((a, b) => b.similarity - a.similarity);

    // Print Top 10
    console.log('\n🏆 Top 10 Matches (Manual Calculation):');
    scores.slice(0, 10).forEach((s, i) => {
        console.log(`${i + 1}. [${s.similarity.toFixed(4)}] ${s.heading}`);
    });

    // Check specifically for the "Seerah" chunk
    const seerahChunk = scores.find(s => s.heading.includes('سیرت کیا ہے') || s.text.includes('سیرت کیا ہے'));
    if (seerahChunk) {
        console.log(`\n🎯 Specific "Seerah" Chunk Rank:`);
        console.log(`Score: ${seerahChunk.similarity.toFixed(4)}`);
        console.log(`Text Preview: ${seerahChunk.text}`);
    } else {
        console.log('\n❌ Could not identify the specific Seerah chunk in the keys.');
    }
}

function cosineSimilarity(vecA, vecB) {
    const toArray = (v) => {
        if (Array.isArray(v)) return v;
        if (typeof v === 'string') return JSON.parse(v);
        return [];
    };

    const a = toArray(vecA);
    const b = toArray(vecB);

    let dotProduct = 0;
    let magnitudeA = 0;
    let magnitudeB = 0;

    for (let i = 0; i < a.length; i++) {
        dotProduct += a[i] * b[i];
        magnitudeA += a[i] * a[i];
        magnitudeB += b[i] * b[i];
    }

    if (magnitudeA === 0 || magnitudeB === 0) return 0;
    return dotProduct / (Math.sqrt(magnitudeA) * Math.sqrt(magnitudeB));
}

testSearch().catch(err => console.error("FATAL ERROR:", err));
