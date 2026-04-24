import '../../domain/entities/question.dart';
import '../../domain/repositories/question_repository.dart';
import '../models/question_model.dart';

class QuestionRepositoryImpl implements QuestionRepository {
  // Mock data for initial development without Firebase setup
  // We generate exactly 5 categories, each with 5 difficulty levels to fully test the UI.
  final List<Map<String, dynamic>> _mockQuestionsJson = _generateMockQuestions();

  static List<Map<String, dynamic>> _generateMockQuestions() {
    final List<Map<String, dynamic>> questions = [];
    final categories = ['Science', 'History', 'Geography', 'Sports', 'Entertainment'];
    
    int idCounter = 1;
    for (final category in categories) {
      for (int level = 1; level <= 5; level++) {
        // Generate 5 questions per level so it doesn't get disabled after just 1 play
        for (int qNum = 1; qNum <= 5; qNum++) {
          questions.add({
            "id": "q${idCounter++}",
            "category": category,
            "difficulty": level,
            "question": "Mock Question $qNum for $category - Level $level. (Type 'answer' to win)",
            "answers": ["answer"],
            "keywords": ["answer"]
          });
        }
      }
    }
    
    // Replace some of them with actual questions for better testing experience
    questions[0] = {
      "id": "q_sci_1",
      "category": "Science",
      "difficulty": 1,
      "question": "What is the chemical symbol for water?",
      "answers": ["h2o", "water"],
      "keywords": ["h2o"]
    };
    
    questions[1] = {
      "id": "q_sci_2",
      "category": "Science",
      "difficulty": 2,
      "question": "What planet is known as the Red Planet?",
      "answers": ["mars", "planet mars"],
      "keywords": ["mars"]
    };

    return questions;
  }

  @override
  Future<List<Question>> getQuestions() async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    
    return _mockQuestionsJson.map((json) {
      return QuestionModel.fromJson(json, json['id'] as String);
    }).toList();
  }
}
