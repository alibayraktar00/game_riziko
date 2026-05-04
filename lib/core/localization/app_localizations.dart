import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      // Home Screen
      'app_subtitle': 'THE ULTIMATE TEAM QUIZ',
      'start_game': 'START GAME',

      // Team Setup Screen
      'setup_teams': 'SETUP TEAMS',
      'enter_team_name': 'Enter Team Name',
      'min_teams_warning': 'At least 2 teams are required to start.',
      'continue_btn': 'CONTINUE',

      // Category Selection Screen
      'categories': 'CATEGORIES',
      'game_over': 'GAME OVER!',
      'view_final_scores': 'VIEW FINAL SCORES',
      'current_turn': 'CURRENT TURN',

      // Difficulty Selection Screen
      'difficulty': 'DIFFICULTY',
      'level': 'LEVEL',

      // Question Screen
      'turn_suffix': "'s Turn",
      'lvl': 'Lvl',
      'time_is_up': 'TIME IS UP!',
      'correct_answer': 'Correct answer',
      'correct': 'CORRECT!',
      'almost_correct': 'ALMOST CORRECT! Check your spelling.',
      'incorrect': 'INCORRECT!',
      'the_correct_answer_was': 'The correct answer was',
      'hint_label': 'HINT',
      'hint_score_reduced': '(Score reduced by 50%)',
      'mic_permission': 'Microphone permission required for this feature.',
      'time_freeze': 'TIME FREEZE! +15 Seconds',
      'double_risk': 'DOUBLE RISK! Correct: x2, Wrong: -x2',
      'passed': 'PASSED! Next team must answer.',
      'type_or_speak': 'TYPE OR SPEAK ANSWER',
      'submit': 'SUBMIT',
      'freeze': 'Freeze',
      'x2_risk': 'x2 Risk',
      'pass': 'Pass',

      // Scoreboard Screen
      'final_scores': 'FINAL SCORES',
      'new_game': 'NEW GAME',
      'continue_game': 'CONTINUE GAME',

      // Language & Settings
      'language': 'Language',
      'settings': 'SETTINGS',

      // Categories
      'science': 'Science',
      'history': 'History',
      'geography': 'Geography',
      'sports': 'Sports',
      'entertainment': 'Entertainment',

      // Custom Question Screen
      'create_question': 'CREATE QUESTION',
      'question_details': 'QUESTION DETAILS',
      'category_hint': 'Category (e.g., Inside Jokes)',
      'question_tr': 'Question (Turkish)',
      'question_en': 'Question (English)',
      'evaluation': 'EVALUATION',
      'accepted_answers': 'Accepted Answers (comma separated)',
      'accepted_answers_hint': 'e.g., ali, ahmet, john doe',
      'required_keywords': 'Required Keywords (comma separated, optional)',
      'required_keywords_hint': 'e.g., ali',
      'save_question': 'SAVE QUESTION',
      'required': 'Required',
      'question_saved': 'Custom question saved!',
    },
    'tr': {
      // Home Screen
      'app_subtitle': 'TAKIMLAR ARASI BİLGİ YARIŞMASI',
      'start_game': 'OYUNA BAŞLA',

      // Team Setup Screen
      'setup_teams': 'TAKIMLARI KUR',
      'enter_team_name': 'Takım Adı Girin',
      'min_teams_warning': 'Başlamak için en az 2 takım gerekli.',
      'continue_btn': 'DEVAM ET',

      // Category Selection Screen
      'categories': 'KATEGORİLER',
      'game_over': 'OYUN BİTTİ!',
      'view_final_scores': 'SONUÇLARI GÖR',
      'current_turn': 'SIRA',

      // Difficulty Selection Screen
      'difficulty': 'ZORLUK',
      'level': 'SEVİYE',

      // Question Screen
      'turn_suffix': ' Sırası',
      'lvl': 'Svy',
      'time_is_up': 'SÜRE DOLDU!',
      'correct_answer': 'Doğru cevap',
      'correct': 'DOĞRU!',
      'almost_correct': 'NEREDEYSE DOĞRU! Yazımını kontrol et.',
      'incorrect': 'YANLIŞ!',
      'the_correct_answer_was': 'Doğru cevap şuydu',
      'hint_label': 'İPUCU',
      'hint_score_reduced': '(Puan %50 düşürüldü)',
      'mic_permission': 'Bu özellik için mikrofon izni gerekli.',
      'time_freeze': 'SÜRE DONDURMA! +15 Saniye',
      'double_risk': 'ÇİFT RİSK! Doğru: x2, Yanlış: -x2',
      'passed': 'PAS! Sıradaki takım cevaplamalı.',
      'type_or_speak': 'CEVABI YAZ VEYA SÖYLE',
      'submit': 'GÖNDER',
      'freeze': 'Dondur',
      'x2_risk': 'x2 Risk',
      'pass': 'Pas',

      // Scoreboard Screen
      'final_scores': 'SKOR TABLOSU',
      'new_game': 'YENİ OYUN',
      'continue_game': 'OYUNA DEVAM',

      // Language & Settings
      'language': 'Language',
      'settings': 'AYARLAR',

      // Categories
      'science': 'Bilim',
      'history': 'Tarih',
      'geography': 'Coğrafya',
      'sports': 'Spor',
      'entertainment': 'Eğlence',

      // Custom Question Screen
      'create_question': 'SORU OLUŞTUR',
      'question_details': 'SORU DETAYLARI',
      'category_hint': 'Kategori (örn: Arkadaşlar Arası)',
      'question_tr': 'Soru (Türkçe)',
      'question_en': 'Soru (İngilizce)',
      'evaluation': 'DEĞERLENDİRME',
      'accepted_answers': 'Kabul Edilen Cevaplar (virgülle ayırın)',
      'accepted_answers_hint': 'örn: ali, ahmet, john doe',
      'required_keywords': 'Gerekli Anahtar Kelimeler (virgülle ayırın, isteğe bağlı)',
      'required_keywords_hint': 'örn: ali',
      'save_question': 'SORUYU KAYDET',
      'required': 'Zorunlu',
      'question_saved': 'Özel soru kaydedildi!',
    },
  };

  String translate(String key) {
    return _localizedValues[locale.languageCode]?[key] ?? key;
  }
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'tr'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) =>
      false;
}
