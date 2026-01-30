
import dotenv from 'dotenv';
import { createClient } from '@supabase/supabase-js';

dotenv.config();

const supabase = createClient(process.env.SUPABASE_URL, process.env.SUPABASE_ANON_KEY);

async function checkData() {
    const { data, error } = await supabase
        .from('timeline_events')
        .select('title, references, lessons')
        .limit(5);

    if (error) {
        console.error('Error fetching data:', error);
        return;
    }

    console.log('Fetched Data Sample:');
    data.forEach((row, i) => {
        console.log(`\nRow ${i + 1}: ${row.title}`);
        console.log('References:', row.references, '(Type:', typeof row.references, ')');
        console.log('Lessons:', row.lessons, '(Type:', typeof row.lessons, ')');
    });
}

checkData();
