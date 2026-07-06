// Tek seferlik/dev amaçlı yardımcı: statik soru bankasını (question_repository_impl.dart
// içindeki _buildQuestions()) Firestore'daki questions_pool koleksiyonuna yazar.
//
// Çalıştırma:
//   flutter run -d chrome -t lib/tools/seed_questions.dart
// (veya bağlı bir Android/iOS cihazda -d <device_id> ile)
//
// Doküman ID'si olarak sorunun kendi id'si (örn. "sci_1") kullanılır ve
// set(merge: true) ile yazılır — script birden fazla kez çalıştırılsa da
// yinelenen kayıt oluşmaz (idempotent).

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import '../core/firebase_options.dart';
import '../data/repositories/question_repository_impl.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: currentPlatform);

  final firestore = FirebaseFirestore.instance;
  final questions = QuestionRepositoryImpl.staticQuestionsJson;

  var success = 0;
  var failed = 0;

  for (final q in questions) {
    final id = q['id'] as String;
    try {
      await firestore.collection('questions_pool').doc(id).set({
        'category': q['category'],
        'difficulty': q['difficulty'],
        'translations': q['translations'],
        'answers': q['answers'],
        'keywords': q['keywords'],
        'distractors': q['distractors'] ?? const {},
        'source': 'static',
        'createdAt': FieldValue.serverTimestamp(),
        'usedCount': 0,
      }, SetOptions(merge: true));
      success++;
      debugPrint('[SEED] OK: $id');
    } catch (e) {
      failed++;
      debugPrint('[SEED] HATA: $id -> $e');
    }
  }

  debugPrint('[SEED] Tamamlandı. Başarılı: $success, Hatalı: $failed, Toplam: ${questions.length}');

  runApp(const _SeedDoneApp());
}

class _SeedDoneApp extends StatelessWidget {
  const _SeedDoneApp();

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text(
            'Seed tamamlandı — konsol logunu kontrol et.',
            style: TextStyle(fontSize: 18),
          ),
        ),
      ),
    );
  }
}
