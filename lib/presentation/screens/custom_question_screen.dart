import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/question.dart';
import '../../services/custom_content_service.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/localization/locale_provider.dart';

class CustomQuestionScreen extends ConsumerStatefulWidget {
  const CustomQuestionScreen({super.key});

  @override
  ConsumerState<CustomQuestionScreen> createState() => _CustomQuestionScreenState();
}

class _CustomQuestionScreenState extends ConsumerState<CustomQuestionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _categoryController = TextEditingController(text: 'Custom');
  final _trQuestionController = TextEditingController();
  final _enQuestionController = TextEditingController();
  final _answersController = TextEditingController();
  final _keywordsController = TextEditingController();
  int _difficulty = 1;

  @override
  void dispose() {
    _categoryController.dispose();
    _trQuestionController.dispose();
    _enQuestionController.dispose();
    _answersController.dispose();
    _keywordsController.dispose();
    super.dispose();
  }

  void _saveQuestion(AppLocalizations t) {
    if (_formKey.currentState!.validate()) {
      final answers = _answersController.text
          .split(',')
          .map((e) => e.trim().toLowerCase())
          .where((e) => e.isNotEmpty)
          .toList();

      final keywords = _keywordsController.text
          .split(',')
          .map((e) => e.trim().toLowerCase())
          .where((e) => e.isNotEmpty)
          .toList();

      final question = Question(
        id: const Uuid().v4(),
        category: _categoryController.text.trim(),
        difficulty: _difficulty,
        translations: {
          'tr': _trQuestionController.text.trim(),
          'en': _enQuestionController.text.trim(),
        },
        answers: answers,
        keywords: keywords,
        isCustom: true,
      );

      ref.read(customContentServiceProvider).saveCustomQuestion(question);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(t.translate('question_saved')),
          backgroundColor: Theme.of(context).colorScheme.primary,
          behavior: SnackBarBehavior.floating,
        ),
      );
      
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(localeProvider);
    final t = AppLocalizations(locale);

    return Scaffold(
      appBar: AppBar(
        title: Text(t.translate('create_question'), style: const TextStyle(letterSpacing: 2)),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            _buildSectionHeader(t.translate('question_details')),
            TextFormField(
              controller: _categoryController,
              decoration: InputDecoration(labelText: t.translate('category_hint')),
              validator: (v) => v!.trim().isEmpty ? t.translate('required') : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _trQuestionController,
              maxLines: 3,
              decoration: InputDecoration(labelText: t.translate('question_tr')),
              validator: (v) => v!.trim().isEmpty ? t.translate('required') : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _enQuestionController,
              maxLines: 3,
              decoration: InputDecoration(labelText: t.translate('question_en')),
              validator: (v) => v!.trim().isEmpty ? t.translate('required') : null,
            ),
            const SizedBox(height: 24),
            _buildSectionHeader(t.translate('evaluation')),
            TextFormField(
              controller: _answersController,
              decoration: InputDecoration(
                labelText: t.translate('accepted_answers'),
                hintText: t.translate('accepted_answers_hint'),
              ),
              validator: (v) => v!.trim().isEmpty ? t.translate('required') : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _keywordsController,
              decoration: InputDecoration(
                labelText: t.translate('required_keywords'),
                hintText: t.translate('required_keywords_hint'),
              ),
            ),
            const SizedBox(height: 24),
            _buildSectionHeader('${t.translate('difficulty')}: $_difficulty'),
            Slider(
              value: _difficulty.toDouble(),
              min: 1,
              max: 5,
              divisions: 4,
              activeColor: Theme.of(context).colorScheme.primary,
              label: '$_difficulty',
              onChanged: (value) {
                setState(() => _difficulty = value.toInt());
              },
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => _saveQuestion(t),
              icon: const Icon(Icons.save_rounded),
              label: Text(t.translate('save_question')),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
          letterSpacing: 2,
        ),
      ),
    );
  }
}
