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

async function ingestData() {
    try {
        const filePath = path.join(process.cwd(), 'dummy.txt'); // Use process.cwd() from root backand folder

        console.log(`📖 Reading data from ${filePath}...`);
        if (!fs.existsSync(filePath)) {
            console.error(`❌ File not found at ${filePath}.`);
            return;
        }

        const fileContent = fs.readFileSync(filePath, 'utf-8');
        const data = JSON.parse(fileContent);

        // console.log(`🧹 Clearing existing data from BOTH tables...`);

        // // Clear timeline_events
        // // const { error: delTimelineError } = await supabase
        // //     .from('timeline_events')
        // //     .delete()
        // //     .neq('id', '00000000-0000-0000-0000-000000000000');

        // // Clear seerah_chunks
        // // const { error: delChunksError } = await supabase
        // //     .from('seerah_chunks')
        // //     .delete()
        // //     .neq('id', '00000000-0000-0000-0000-000000000000');

        // // if (delTimelineError) console.warn('⚠️ Error clearing timeline_events:', delTimelineError.message);
        // // if (delChunksError) console.warn('⚠️ Error clearing seerah_chunks:', delChunksError.message);

        console.log(`🔹 Found ${data.length} records. Processing...`);

        for (let i = 0; i < data.length; i++) {
            const item = data[i];

            // 1. Prepare Rich Text for RAG (seerah_chunks)
            const richText = `
Heading: ${item.heading}
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

            // 2. Insert into seerah_chunks (RAG Loopup)
            const chunkRecord = {
                chunk_id: `chunk_${i}_${Date.now()}`,
                text: richText,
                page_number: item.page,
                embedding: embedding,
                metadata: {
                    book: item.book,
                    heading: item.heading,
                    references: item.references,
                    original_content: item.content
                }
            };

            const { error: chunkError } = await supabase
                .from('seerah_chunks')
                .insert(chunkRecord);

            if (chunkError) console.error('❌ Error inserting chunk:', chunkError);

            // 3. Insert into timeline_events (Frontend Display)
            // Ensure references/lessons are arrays
            const timelineRecord = {
                title: item.heading,
                short_description: item.short_description || item.content.substring(0, 100) + '...',
                full_description: item.content,
                category: item.category || 'General',
                order_index: item.order_index || i,
                year: item.year,
                references: item.references || [],
                lessons: item.lessons_wisdom || []
            };

            const { error: timelineError } = await supabase
                .from('timeline_events')
                .insert(timelineRecord);

            if (timelineError) {
                console.error('❌ Error inserting timeline event:', timelineError);
            } else {
                console.log('✅ Saved to Supabase (Chunks + Timeline)');
            }

            // Delay to respect rate limits
            await new Promise(resolve => setTimeout(resolve, 500));
        }

        console.log('\n🎉 Update complete!');

    } catch (error) {
        console.error('❌ Critical Error:', error);
    }
}

ingestData();
