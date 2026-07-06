import '../entities/question.dart';

/// Kategori + zorluk bazlı soru havuzu: yeterli soru varsa havuzdan çeker,
/// yetersizse yapay zeka ile yeni sorular üretip havuzu büyütür.
abstract class QuestionPoolRepository {
  Future<List<Question>> getQuestionsForSlot({
    required String category,
    required int difficulty,
    int count = 1,
  });
}
