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

  /// Soru üretim prompt'unun sürümü. Prompt'ta kalite düzeltmesi yapıldığında
  /// artırılır; havuzdaki eski sürümle üretilmiş sorular (ör. alakasız
  /// çeldiricili olanlar) okuma sırasında elenir ve arka planda silinir,
  /// böylece havuz kendini yeni sürümle yeniden doldurur.
  static const int promptVersion = 2;

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

      // Eski prompt sürümüyle üretilmiş veya çeldiricisi eksik kayıtlar
      // havuzdan sayılmaz: kullanılmazlar ve arka planda silinirler ki
      // ekranda "başka sorulardan rastgele şık toplama" fallback'ini
      // tetikleyip alakasız şıklara yol açmasınlar.
      final validDocs = <QueryDocumentSnapshot<Map<String, dynamic>>>[];
      for (final doc in snapshot.docs) {
        if (_isCurrentQuality(doc.data())) {
          validDocs.add(doc);
        } else {
          unawaited(_deleteStale(doc.reference));
        }
      }

      if (validDocs.length < poolThreshold) {
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
        if (validDocs.isEmpty) return [];
        final docs = validDocs.toList()..shuffle(Random());
        return _docsToQuestions(docs.take(count).toList());
      }

      // Havuz yeterli — rastgele count kadar soru seç.
      final docs = validDocs.toList()..shuffle(Random());
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

  /// Havuzdaki bir kaydın güncel kalite standardını karşılayıp
  /// karşılamadığını kontrol eder: güncel prompt sürümüyle üretilmiş olmalı
  /// ve her iki dil için de en az 3 çeldirici içermeli.
  bool _isCurrentQuality(Map<String, dynamic> data) {
    if ((data['promptVersion'] as num?)?.toInt() != promptVersion) return false;

    final distractors = data['distractors'];
    if (distractors is! Map) return false;
    for (final lang in const ['en', 'tr']) {
      final list = distractors[lang];
      if (list is! List || list.length < 3) return false;
    }
    return true;
  }

  Future<void> _deleteStale(DocumentReference<Map<String, dynamic>> ref) async {
    try {
      await ref.delete();
    } catch (_) {
      // Silinemedi (izin/ağ) — kritik değil, okuma tarafında zaten elenmişti.
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
        'promptVersion': promptVersion,
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
