import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../domain/entities/question.dart';
import '../domain/entities/team_template.dart';
import 'settings_service.dart';

class CustomContentService {
  static const String _customQuestionsKey = 'custom_questions';
  static const String _teamTemplatesKey = 'team_templates';

  final SharedPreferences _prefs;

  CustomContentService(this._prefs);

  // --- Custom Questions ---
  List<Question> getCustomQuestions() {
    final List<String>? questionsJson = _prefs.getStringList(_customQuestionsKey);
    if (questionsJson == null) return [];

    return questionsJson.map((jsonStr) => Question.fromJson(jsonStr)).toList();
  }

  Future<void> saveCustomQuestion(Question question) async {
    final questions = getCustomQuestions();
    final index = questions.indexWhere((q) => q.id == question.id);
    
    if (index >= 0) {
      questions[index] = question;
    } else {
      questions.add(question);
    }

    final List<String> questionsJson = questions.map((e) => e.toJson()).toList();
    await _prefs.setStringList(_customQuestionsKey, questionsJson);
  }

  Future<void> deleteCustomQuestion(String id) async {
    final questions = getCustomQuestions();
    questions.removeWhere((q) => q.id == id);

    final List<String> questionsJson = questions.map((e) => e.toJson()).toList();
    await _prefs.setStringList(_customQuestionsKey, questionsJson);
  }

  // --- Team Templates ---
  List<TeamTemplate> getTeamTemplates() {
    final List<String>? templatesJson = _prefs.getStringList(_teamTemplatesKey);
    if (templatesJson == null) return [];

    return templatesJson.map((jsonStr) => TeamTemplate.fromJson(jsonStr)).toList();
  }

  Future<void> saveTeamTemplate(TeamTemplate template) async {
    final templates = getTeamTemplates();
    final index = templates.indexWhere((t) => t.id == template.id);
    
    if (index >= 0) {
      templates[index] = template;
    } else {
      templates.add(template);
    }

    final List<String> templatesJson = templates.map((e) => e.toJson()).toList();
    await _prefs.setStringList(_teamTemplatesKey, templatesJson);
  }

  Future<void> deleteTeamTemplate(String id) async {
    final templates = getTeamTemplates();
    templates.removeWhere((t) => t.id == id);

    final List<String> templatesJson = templates.map((e) => e.toJson()).toList();
    await _prefs.setStringList(_teamTemplatesKey, templatesJson);
  }
}

final customContentServiceProvider = Provider<CustomContentService>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return CustomContentService(prefs);
});
