import express from 'express';
import { generateQuiz, saveQuizResult } from '../controllers/quizController.js';

const router = express.Router();

router.post('/generate', generateQuiz);
router.post('/submit', saveQuizResult);

export default router;
