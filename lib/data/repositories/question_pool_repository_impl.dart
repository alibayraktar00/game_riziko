import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/question.dart';
import '../../domain/repositories/question_pool_repository.dart';
import '../../services/ai_question_service.dart';

class QuestionPoolRepositoryImpl implements QuestionPoolRepository {
  /// Bir (kategori, zorluk) slotu için havuzda bulunması istenen en az
  /// soru sayısı. Altına düşerse Gemini'den yeni sorular üretilip havuza
  /// eklenir.
  static const int poolThreshold = 20;

  static const String _collectionName = 'questions_pool';

  final FirebaseFirestore _firestore;
  final AiQuestionService _aiQuestionService;

  QuestionPoolRepositoryImpl(
    this._aiQuestionService, {
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<List<Question>> getQuestionsForSlot({
    required String category,
    required int difficulty,
    int count = 1,
  }) async {
    try {
      final snapshot = await _firestore
          .collection(_collectionName)
          .where('category', isEqualTo: category)
          .where('difficulty', isEqualTo: difficulty)
          .get();

      if (snapshot.docs.length < poolThreshold) {
        final generated = await _aiQuestionService.generateForSlot(
          category: category,
          difficulty: difficulty,
          count: count,
        );

        if (generated.isNotEmpty) {
          for (final question in generated) {
            // Firestore'a ekleme best-effort — başarısız olursa üretilen
            // soru yine de bu oyunda kullanılır, sadece havuza kalıcı
            // olarak eklenemez.
            unawaited(_saveToPool(category, difficulty, question));
          }
          return generated;
        }

        // Gemini başarısız oldu — havuzda az da olsa soru varsa onları kullan.
        if (snapshot.docs.isEmpty) return [];
        final docs = snapshot.docs.toList()..shuffle(Random());
        return _docsToQuestions(docs.take(count).toList());
      }

      // Havuz yeterli — rastgele count kadar soru seç.
      final docs = snapshot.docs.toList()..shuffle(Random());
      final selected = docs.take(count).toList();

      for (final doc in selected) {
        unawaited(_incrementUsedCount(doc.reference));
      }

      return _docsToQuestions(selected);
    } catch (_) {
      // Firestore'a erişilemedi (ağ, izin vb.) — boş dön, çağıran taraf
      // statik soru bankasına düşer.
      return [];
    }
  }

  Future<void> _saveToPool(String category, int difficulty, Question question) async {
    try {
      await _firestore.collection(_collectionName).add({
        'category': category,
        'difficulty': difficulty,
        'translations': question.translations,
        'answers': question.answers,
        'keywords': question.keywords,
        'distractors': question.distractors,
        'source': 'ai',
        'createdAt': FieldValue.serverTimestamp(),
        'usedCount': 0,
      });
    } catch (_) {
      // Havuza kalıcı kayıt başarısız oldu, önemli değil — soru zaten
      // bu oyunda kullanılıyor.
    }
  }

  Future<void> _incrementUsedCount(DocumentReference<Map<String, dynamic>> ref) async {
    try {
      await ref.update({'usedCount': FieldValue.increment(1)});
    } catch (_) {
      // Sayaç güncellenemedi, kritik değil.
    }
  }

  List<Question> _docsToQuestions(List<QueryDocumentSnapshot<Map<String, dynamic>>> docs) {
    return docs.map((doc) {
      final data = doc.data();
      return Question(
        id: doc.id,
        category: data['category'] as String,
        difficulty: (data['difficulty'] as num).toInt(),
        translations: Map<String, String>.from(data['translations'] as Map),
        answers: List<String>.from(data['answers'] as List),
        keywords: List<String>.from(data['keywords'] as List),
        distractors: (data['distractors'] as Map?)?.map(
              (key, value) => MapEntry(key as String, List<String>.from(value as List)),
            ) ??
            const {},
        isCustom: true,
      );
    }).toList();
  }
}
