import { generateQuizService } from '../services/quizService.js';

export const generateQuiz = async (req, res) => {
    try {
        const { title, content } = req.body;

        if (!title || !content) {
            return res.status(400).json({ error: 'Title and content are required' });
        }

        const quiz = await generateQuizService(content, title);

        res.json({
            success: true,
            title: title,
            questions: quiz
        });

    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

// Placeholder for saving results (User did not explicitly ask for backend DB logic yet, but good to have controller stub)
export const saveQuizResult = async (req, res) => {
    // Will implement when Supabase table structure is confirmed
    res.json({ message: "Result saved (Mock)" });
};
