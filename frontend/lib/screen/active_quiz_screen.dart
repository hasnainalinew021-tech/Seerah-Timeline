import 'package:flutter/material.dart';
import 'package:seerah_timeline/models/quiz_model.dart';
import 'package:seerah_timeline/services/quiz_api_service.dart';
import 'package:seerah_timeline/widget/quiz_background.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:seerah_timeline/screen/quiz_screen.dart'; // For navigation after finishing?

class ActiveQuizScreen extends StatefulWidget {
  final String eventTitle;
  final String eventContent;

  const ActiveQuizScreen({
    super.key,
    required this.eventTitle,
    required this.eventContent,
  });

  @override
  State<ActiveQuizScreen> createState() => _ActiveQuizScreenState();
}

class _ActiveQuizScreenState extends State<ActiveQuizScreen> {
  final QuizApiService _apiService = QuizApiService();
  List<QuizQuestion> _questions = [];
  bool _isLoading = true;
  int _currentIndex = 0;
  String? _selectedOption;
  bool _isAnswerChecked = false;
  int _score = 0;

  @override
  void initState() {
    super.initState();
    _loadQuiz();
  }

  Future<void> _loadQuiz() async {
    try {
      final questions = await _apiService.generateQuiz(widget.eventTitle, widget.eventContent);
      setState(() {
        _questions = questions;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      // Handle error (show snackbar/dialog)
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to load quiz: $e')));
        Navigator.pop(context);
      }
    }
  }

  void _checkAnswer() {
    if (_selectedOption == null) return;
    
    setState(() {
      _isAnswerChecked = true;
      if (_selectedOption == _questions[_currentIndex].correctAnswer) {
        _score++;
      }
    });
  }

  void _nextQuestion() {
    if (_currentIndex < _questions.length - 1) {
      setState(() {
        _currentIndex++;
        _selectedOption = null;
        _isAnswerChecked = false;
      });
    } else {
      _finishQuiz();
    }
  }

  Future<void> _finishQuiz() async {
    await _saveResult();
    if (!mounted) return;
    _showResultDialog();
  }

  Future<void> _saveResult() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<String> history = prefs.getStringList('quiz_history') ?? [];
      
      final result = {
        'title': widget.eventTitle,
        'content': widget.eventContent, // Store content for retaking
        'score': _score,
        'total': _questions.length,
        'date': DateTime.now().toIso8601String(),
        'percentage': _questions.isEmpty ? 0 : (_score / _questions.length * 100).toInt()
      };

      // Check if this quiz was already taken
      int existingIndex = -1;
      for (int i = 0; i < history.length; i++) {
         final item = jsonDecode(history[i]);
         if (item['title'] == widget.eventTitle) {
           existingIndex = i;
           break;
         }
      }

      if (existingIndex != -1) {
        // Update existing entry
        final existingItem = jsonDecode(history[existingIndex]);
        // Preserve original date to maintain sort order ("first solved comes first")
        result['date'] = existingItem['date']; 
        history[existingIndex] = jsonEncode(result);
      } else {
        // Add new entry
        history.add(jsonEncode(result));
      }
      
      await prefs.setStringList('quiz_history', history);
    } catch (e) {
      print("Error saving quiz result: $e");
    }
  }

  void _showResultDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Quiz Completed!', textAlign: TextAlign.center),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.emoji_events, color: Colors.amber, size: 60),
            const SizedBox(height: 16),
            Text(
              'You scored $_score out of ${_questions.length}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
               _score > _questions.length / 2 ? "Great job! MA SHA ALLAH" : "Keep learning!",
               style: TextStyle(color: Colors.grey[600]),
            )
          ],
        ),
        actions: [
          Center(
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Close screen
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0D9488),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
              ),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text('Finish', style: TextStyle(color: Colors.white)),
              ),
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0D9488)),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
            IconButton(
                icon: const Icon(Icons.notifications_none, color: Color(0xFF0D9488)),
                onPressed: () {},
            )
        ]
      ),
      body: QuizBackground(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: Color(0xFF0D9488)))
            : Column(
                children: [
                    // Header Section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Seerah Quiz",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0D9488),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Test your knowledge of ${widget.eventTitle}",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 20),
                        
                        // Progress Bar
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Question ${_currentIndex + 1} of ${_questions.length}",
                              style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black54),
                            ),
                            Text(
                              "${((_currentIndex + 1) / _questions.length * 100).toInt()}%",
                               style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0D9488)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: (_currentIndex + 1) / _questions.length,
                          backgroundColor: Colors.grey[300],
                          color: const Color(0xFF0D9488),
                          minHeight: 8,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Question Card
                  Expanded(
                    child: SingleChildScrollView(
                        child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24.0),
                            child: Column(
                                children: [
                                     Container(
                                        padding: const EdgeInsets.all(24),
                                        decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(20),
                                            boxShadow: [
                                                BoxShadow(
                                                    color: Colors.black.withOpacity(0.05),
                                                    blurRadius: 10,
                                                    offset: const Offset(0, 5),
                                                )
                                            ]
                                        ),
                                        child: Column(
                                            children: [
                                                // Question Number Circle
                                                Container(
                                                     width: 60,
                                                     height: 60,
                                                     decoration: const BoxDecoration(
                                                         color: Color(0xFF0D9488),
                                                         shape: BoxShape.circle,
                                                     ),
                                                     child: Center(
                                                         child: Text(
                                                             "${_currentIndex + 1}",
                                                             style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                                                         ),
                                                     ),
                                                ),
                                                const SizedBox(height: 24),
                                                
                                                // Question Text
                                                Text(
                                                    _questions[_currentIndex].question,
                                                    textAlign: TextAlign.center,
                                                    style: const TextStyle(
                                                        fontSize: 18,
                                                        fontWeight: FontWeight.w600,
                                                        color: Colors.black87,
                                                        fontFamily: 'Noto Nastaliq Urdu', // Urdu font
                                                        height: 1.6
                                                    ),
                                                ),
                                                
                                                const SizedBox(height: 24),
                                                
                                                // Options
                                                ..._questions[_currentIndex].options.map((option) {
                                                    final isSelected = _selectedOption == option;
                                                    final isCorrect = option == _questions[_currentIndex].correctAnswer;
                                                    
                                                    Color borderColor = Colors.grey.shade300;
                                                    Color textColor = Colors.black54;
                                                    Color backgroundColor = Colors.white;

                                                    if (_isAnswerChecked) {
                                                        if (isCorrect) {
                                                            borderColor = Colors.green;
                                                            backgroundColor = Colors.green.shade50;
                                                        } else if (isSelected) {
                                                            borderColor = Colors.red;
                                                            backgroundColor = Colors.red.shade50;
                                                        }
                                                    } else if (isSelected) {
                                                        borderColor = const Color(0xFF0D9488);
                                                        textColor = const Color(0xFF0D9488);
                                                    }

                                                    return Padding(
                                                      padding: const EdgeInsets.only(bottom: 12),
                                                      child: InkWell(
                                                        onTap: _isAnswerChecked ? null : () {
                                                            setState(() {
                                                                _selectedOption = option;
                                                            });
                                                        },
                                                        borderRadius: BorderRadius.circular(12),
                                                        child: Container(
                                                            width: double.infinity,
                                                            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                                                            decoration: BoxDecoration(
                                                                color: backgroundColor,
                                                                borderRadius: BorderRadius.circular(12),
                                                                border: Border.all(color: borderColor, width: 2),
                                                            ),
                                                            child: Text(
                                                                option,
                                                                textAlign: TextAlign.center,
                                                                style: TextStyle(
                                                                    fontSize: 16,
                                                                    color: textColor,
                                                                    fontFamily: 'Noto Nastaliq Urdu',
                                                                    fontWeight: FontWeight.w500,
                                                                ),
                                                            ),
                                                        ),
                                                      ),
                                                    );
                                                }).toList(),
                                            ],
                                        ),
                                     ),
                                ],
                            ),
                        ),
                    ),
                  ),
                  
                  // Bottom Action Area
                  if (_selectedOption != null)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    child: _isAnswerChecked
                    ? Row(
                        children: [
                            Expanded(child: OutlinedButton(
                                onPressed: () => Navigator.pop(context),
                                style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    side: const BorderSide(color: Color(0xFF0D9488)),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                                ),
                                child: const Text("Quit Quiz", style: TextStyle(color: Color(0xFF0D9488))),
                            )),
                            const SizedBox(width: 16),
                            Expanded(child: ElevatedButton(
                                onPressed: _nextQuestion,
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF0D9488),
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                                ),
                                child: Text(_currentIndex == _questions.length - 1 ? "Show Result" : "Next Question"),
                            )),
                        ],
                    )
                    : SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                            onPressed: _checkAnswer,
                             style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF0D9488),
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    elevation: 4
                            ),
                            child: const Text("Check Answer", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                    ),
                  )
                ],
              ),
      ),
    );
  }
}
