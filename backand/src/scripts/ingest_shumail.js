import { createClient } from '@supabase/supabase-js';
import { GoogleGenerativeAI } from '@google/generative-ai';
import dotenv from 'dotenv';
import fs from 'fs';
import path from 'path';

dotenv.config();

// Initialize Supabase
const supabaseUrl = process.env.SUPABASE_URL;
const supabaseKey = process.env.SUPABASE_ANON_KEY;
const supabase = createClient(supabaseUrl, supabaseKey);

// Initialize Gemini
const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY);
const model = genAI.getGenerativeModel({ model: "gemini-embedding-001" });

async function ingestShumailData() {
    try {
        const filePath = process.cwd().endsWith('backand') ? path.join(process.cwd(), '../dummy.txt') : path.join(process.cwd(), 'dummy.txt');

        console.log(`📖 Reading data from ${filePath}...`);
        if (!fs.existsSync(filePath)) {
            console.error(`❌ File not found at ${filePath}.`);
            return;
        }

        let fileContent = fs.readFileSync(filePath, 'utf-8');
        fileContent = fileContent.trim();
        if (fileContent.startsWith('{') && fileContent.endsWith('}')) {
            fileContent = `[${fileContent}]`;
        }
        const data = JSON.parse(fileContent);

        console.log(`🔹 Found ${data.length} records. Processing...`);

        for (let i = 0; i < data.length; i++) {
            const item = data[i];

            // 1. Prepare Rich Text for RAG (seerah_chunks)
            const richText = `
Heading: ${item.heading}
Category: ${item.category}
Content: ${item.content}
References: ${item.references ? item.references.join(', ') : 'None'}
Source: ${item.book}, Page ${item.page}
            `.trim();

            console.log(`[${i + 1}/${data.length}] Generating embedding for: "${item.heading}"...`);

            // Generate Embedding
            const result = await model.embedContent({
                content: { parts: [{ text: richText }] },
                outputDimensionality: 768
            });
            const embedding = result.embedding.values;

            // 2. Insert into seerah_chunks (RAG Database for Chatbot)
            const chunkRecord = {
                chunk_id: `shumail_chunk_${i}_${Date.now()}`,
                text: richText,
                page_number: item.page,
                embedding: embedding,
                metadata: {
                    book: item.book,
                    heading: item.heading,
                    category: item.category,
                    references: item.references,
                    original_content: item.content
                }
            };

            const { error: chunkError } = await supabase
                .from('seerah_chunks')
                .insert(chunkRecord);

            if (chunkError) console.error('❌ Error inserting chunk:', chunkError);

            // 3. Insert into shumail_events (Frontend Display Table)
            // Note: Does not insert a 'year' property since it is not used in Shumail.
            const shumailRecord = {
                title: item.heading,
                short_description: item.short_description || item.content.substring(0, 100) + '...',
                full_description: item.content,
                category: item.category || 'General',
                order_index: item.order_index || i,
                references: item.references || [],
                page: item.page,
                book: item.book
            };

            const { error: shumailError } = await supabase
                .from('shumail_events')
                .insert(shumailRecord);

            if (shumailError) {
                console.error('❌ Error inserting shumail event:', shumailError);
            } else {
                console.log('✅ Saved to Supabase (Chunks + Shumail Events)');
            }

            // Delay to respect rate limits on API and Database
            await new Promise(resolve => setTimeout(resolve, 500));
        }

        console.log('\n🎉 Update complete!');

    } catch (error) {
        console.error('❌ Critical Error:', error);
    }
}

ingestShumailData();
