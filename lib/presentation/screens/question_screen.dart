import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/localization/locale_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/entities/question.dart';
import '../../services/answer_evaluator_service.dart';
import '../../services/audio_service.dart';
import '../../services/settings_service.dart';
import '../../services/speech_service.dart';
import '../providers/game_provider.dart';
import '../providers/providers.dart';
import '../widgets/glass_card.dart';

class QuestionScreen extends ConsumerStatefulWidget {
  final String category;
  final int difficulty;

  const QuestionScreen({
    super.key,
    required this.category,
    required this.difficulty,
  });

  @override
  ConsumerState<QuestionScreen> createState() => _QuestionScreenState();
}

class _QuestionScreenState extends ConsumerState<QuestionScreen> {
  Question? _question;
  final _answerController = TextEditingController();
  late final ConfettiController _confettiController =
      ConfettiController(duration: const Duration(milliseconds: 1200));
  Timer? _timer;
  int _timeLeft = 30;
  String _feedbackMessage = '';
  bool _hintUsed = false;
  bool _answered = false;
  bool _isDoubleRiskActive = false;

  int? _floatingScoreValue;
  Offset? _floatingScorePosition;

  List<String> _options = [];
  String _correctOption = '';
  final Set<String> _eliminatedOptions = {};
  String? _selectedOption;

  AppLocalizations get _t => AppLocalizations(ref.read(localeProvider));

  // dispose() sırasında ref.read() kullanmak güvensizdir (widget unmount
  // olduğunda Riverpod bir StateError fırlatır) — bu da widget ağacının
  // bozulup bir sonraki soru ekranının boş görünmesine neden oluyordu.
  // Servis referansı burada, henüz widget aktifken güvenle alınıp saklanıyor.
  late final AudioService _audioService;

  @override
  void initState() {
    super.initState();
    _audioService = ref.read(audioServiceProvider);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _timeLeft = ref.read(settingsServiceProvider).getTimerDuration();
      _initQuestion();
      ref.read(audioServiceProvider).playBackgroundMusic();
    });
  }

  void _initQuestion() {
    final availableQuestions = ref.read(gameProvider).availableQuestions;

    final questions = availableQuestions.where((q) {
      final matchCategory = q.category.trim().toLowerCase() == widget.category.trim().toLowerCase();
      final matchDifficulty = q.difficulty == widget.difficulty;
      return matchCategory && matchDifficulty;
    }).toList();

    if (questions.isNotEmpty) {
      final q = questions.first;
      setState(() {
        _question = q;
      });

      final isMultipleChoice = ref.read(gameProvider).isMultipleChoice;
      if (isMultipleChoice) {
        _generateMultipleChoiceOptions(q);
      }
      
      _startTimer();
    } else {
      context.pop();
    }
  }

  String _getBestAnswer(Question question, String languageCode) {
    if (question.answers.isEmpty) return '';
    if (languageCode == 'tr') {
      for (var ans in question.answers.reversed) {
        final normalized = ans.toLowerCase();
        if (normalized.contains(RegExp(r'[çğışöü]')) || 
            normalized == 'sekiz' || 
            normalized == 'yirmi dört' || 
            normalized == 'on bir' || 
            normalized == 'beş' || 
            normalized == 'altı' || 
            normalized == 'yedi' || 
            normalized == 'kanatlar' || 
            normalized == 'çince' || 
            normalized == 'mavi balina' || 
            normalized == 'japonya' || 
            normalized == 'vatikan' || 
            normalized == 'büyük okyanus' || 
            normalized == 'kanada' || 
            normalized == 'ural dağları' || 
            normalized == 'mitokondri' || 
            normalized == 'yapay zeka' || 
            normalized == 'karbondioksit') {
          return ans;
        }
      }
      if (question.answers.length > 1) {
        return question.answers.last;
      }
    }
    return question.answers.first;
  }

  /// Bir cevabın "sayısal" görünüp görünmediğini kontrol eder — çeldirici
  /// seçerken doğru cevapla aynı türden (sayı/kelime) adayları öncelemek
  /// için kullanılır (örn. "Mars" gibi bir cevaba "8" gibi bir sayı
  /// çeldirici olarak gelmesin).
  bool _looksNumeric(String value) {
    return num.tryParse(value.trim()) != null;
  }

  void _generateMultipleChoiceOptions(Question question) {
    final lang = ref.read(localeProvider).languageCode;
    _correctOption = _getBestAnswer(question, lang);

    final distractors = <String>[];

    // Öncelik: sorunun kendi (AI tarafından üretilmiş) konuyla ilgili
    // çeldiricileri — bu, başka sorulardan rastgele toplanan alakasız
    // şıklardan çok daha kaliteli.
    final ownDistractors = question
        .getDistractors(lang)
        .where((ans) => ans.isNotEmpty && ans.toLowerCase() != _correctOption.toLowerCase())
        .toSet()
        .toList()
      ..shuffle();
    for (var ans in ownDistractors) {
      if (distractors.length < 3) distractors.add(ans);
    }

    // Yetersizse (statik banka sorularında veya AI eksik döndüyse), havuzdaki
    // diğer soruların cevaplarından tamamla — önce aynı kategori, ve önce
    // doğru cevapla aynı "türden" (sayı/kelime) cevaplar tercih edilir ki
    // örn. bir gezegen sorusuna "8" gibi alakasız bir sayı çıkmasın.
    if (distractors.length < 3) {
      final correctIsNumeric = _looksNumeric(_correctOption);
      final allQuestions = ref.read(questionsProvider).value ?? [];
      final sameCatQuestions = allQuestions
          .where((q) => q.category.trim().toLowerCase() == widget.category.trim().toLowerCase() && q.id != question.id)
          .toList();
      final otherCatQuestions = allQuestions
          .where((q) => q.category.trim().toLowerCase() != widget.category.trim().toLowerCase())
          .toList();

      final sameCatAnswers = sameCatQuestions
          .map((q) => _getBestAnswer(q, lang))
          .where((ans) => ans.isNotEmpty && ans.toLowerCase() != _correctOption.toLowerCase() && !distractors.contains(ans))
          .toSet()
          .toList();
      final otherCatAnswers = otherCatQuestions
          .map((q) => _getBestAnswer(q, lang))
          .where((ans) => ans.isNotEmpty && ans.toLowerCase() != _correctOption.toLowerCase() && !distractors.contains(ans))
          .toSet()
          .toList();

      sameCatAnswers.shuffle();
      otherCatAnswers.shuffle();

      // Aynı türden (sayı/kelime) cevapları önce, kalan farklı türden
      // cevapları en sona koy — böylece dolgu gerekirse önce en makul
      // adaylar denenir.
      final candidates = [
        ...sameCatAnswers.where((a) => _looksNumeric(a) == correctIsNumeric),
        ...otherCatAnswers.where((a) => _looksNumeric(a) == correctIsNumeric),
        ...sameCatAnswers.where((a) => _looksNumeric(a) != correctIsNumeric),
        ...otherCatAnswers.where((a) => _looksNumeric(a) != correctIsNumeric),
      ];

      for (var ans in candidates) {
        if (distractors.length >= 3) break;
        distractors.add(ans);
      }
    }

    while (distractors.length < 3) {
      distractors.add('Option ${distractors.length + 1}');
    }

    _options = [_correctOption, ...distractors];
    _options.shuffle();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeft > 0) {
        setState(() {
          _timeLeft--;
        });
        if (_timeLeft > 0 && _timeLeft <= 5) {
          ref.read(audioServiceProvider).playTick();
        }
      } else {
        _handleTimeOut();
      }
    });
  }

  void _handleTimeOut() {
    if (_answered) return;
    _timer?.cancel();
    setState(() {
      _answered = true;
      _feedbackMessage = '${_t.translate('time_is_up')}\n${_t.translate('correct_answer')}: ${_question?.answers.first.toUpperCase()}';
    });
    ref.read(audioServiceProvider).playBuzzer();
    _finishTurn(false);
  }

  void _evaluateAnswer() {
    if (_answered || _question == null || _answerController.text.trim().isEmpty) return;
    
    final evaluator = ref.read(answerEvaluatorServiceProvider);
    final result = evaluator.evaluate(_answerController.text, _question!);

    setState(() {
      if (result == AnswerResult.correct) {
        _answered = true;
        _timer?.cancel();
        _feedbackMessage = _t.translate('correct');
        ref.read(audioServiceProvider).playDing();
        _confettiController.play();
        _finishTurn(true);
      } else if (result == AnswerResult.almostCorrect) {
        _feedbackMessage = _t.translate('almost_correct');
      } else {
        _answered = true;
        _timer?.cancel();
        _feedbackMessage = '${_t.translate('incorrect')}\n${_t.translate('the_correct_answer_was')}: ${_question!.answers.first.toUpperCase()}';
        ref.read(audioServiceProvider).playBuzzer();
        _finishTurn(false);
      }
    });
  }

  void _finishTurn(bool correct) {
    int points = widget.difficulty * 10;
    
    if (_isDoubleRiskActive) {
      points *= 2;
    }
    
    if (!correct && _isDoubleRiskActive) {
      points = -points;
    } else if (!correct) {
      points = 0;
    } else if (_hintUsed) {
      points = (points * 0.5).round();
    }

    if (points != 0) {
      setState(() {
        _floatingScoreValue = points;
        _floatingScorePosition = const Offset(0, -100); 
      });
      ref.read(gameProvider.notifier).addScoreToCurrentTeam(points);
    }

    Future.delayed(const Duration(seconds: 4), () {
      if (!mounted) return;
      ref.read(audioServiceProvider).stopBackgroundMusic();
      ref.read(gameProvider.notifier).removeQuestion(_question!.id);
      ref.read(gameProvider.notifier).nextTurn();
      context.go('/category-selection');
    });
  }

  void _useHint() {
    if (_hintUsed || _question == null) return;
    final isMultipleChoice = ref.read(gameProvider).isMultipleChoice;
    
    if (isMultipleChoice) {
      final wrongOptions = _options.where((opt) => opt.toLowerCase() != _correctOption.toLowerCase()).toList();
      wrongOptions.shuffle();
      final toEliminate = wrongOptions.take(2).toList();
      
      setState(() {
        _eliminatedOptions.addAll(toEliminate);
        _hintUsed = true;
        _feedbackMessage = _t.translate('hint_score_reduced');
      });
    } else {
      setState(() {
        _hintUsed = true;
        final ans = _question!.answers.first;
        final hintText = ans.length > 2 
            ? '${ans.substring(0, 2)}${List.filled(ans.length - 2, '*').join('')}'
            : ans.characters.first;
        _feedbackMessage = '${_t.translate('hint_label')}: $hintText ${_t.translate('hint_score_reduced')}';
      });
    }
  }

  Future<void> _toggleMic() async {
    final speechService = ref.read(speechServiceProvider);
    
    if (speechService.isListening) {
      await speechService.stopListening();
      setState(() {});
    } else {
      var status = await Permission.microphone.request();
      if (status.isGranted) {
        await speechService.startListening(
          onResult: (text) {
            setState(() {
              _answerController.text = text;
            });
          }
        );
        setState(() {});
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_t.translate('mic_permission'))),
        );
      }
    }
  }

  void _useJoker(String jokerKey) {
    if (_answered) return;
    
    final notifier = ref.read(gameProvider.notifier);
    notifier.useJoker(jokerKey);

    setState(() {
      if (jokerKey == 'time_freeze') {
        _timeLeft += 15;
        _feedbackMessage = _t.translate('time_freeze');
      } else if (jokerKey == 'double_risk') {
        _isDoubleRiskActive = true;
        _feedbackMessage = _t.translate('double_risk');
      } else if (jokerKey == 'pass') {
        _timer?.cancel();
        notifier.nextTurn();
        _feedbackMessage = _t.translate('passed');
        
        Future.delayed(const Duration(seconds: 2), () {
          if (!mounted) return;
          _startTimer();
          setState(() {
            _feedbackMessage = '';
          });
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _answerController.dispose();
    _confettiController.dispose();
    _audioService.stopBackgroundMusic();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_question == null) {
      return Scaffold(
        body: Container(
          decoration: AppTheme.neonGradient,
          child: Center(child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary)),
        ),
      );
    }

    final currentTeam = ref.watch(gameProvider.select((s) => s.currentTeam));
    final speechService = ref.watch(speechServiceProvider);
    final locale = ref.watch(localeProvider);
    final t = AppLocalizations(locale);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          // Premium Background Image with Dark Overlay
          Positioned.fill(
            child: Container(
              decoration: AppTheme.neonGradient,
            ),
          ),
          
          // Subtle decorative element
          Positioned(
            bottom: -50,
            left: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colorScheme.secondary.withValues(alpha: 0.03),
              ),
            ).animate(onPlay: (c) => c.repeat(reverse: true))
             .scale(begin: const Offset(1, 1), end: const Offset(1.2, 1.2), duration: 4.seconds)
             .blur(begin: const Offset(30, 30), end: const Offset(50, 50)),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Top Bar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white70),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('Oyundan Çık?'),
                              content: const Text('Mevcut sorudan çıkmak istediğinize emin misiniz?'),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('HAYIR')),
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.pop(ctx);
                                    context.pop();
                                  },
                                  child: const Text('EVET'),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      _TimerDisplay(timeLeft: _timeLeft),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  _QuestionHeader(
                    teamName: currentTeam.name,
                    category: widget.category,
                    difficulty: widget.difficulty,
                    t: t,
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Question Card
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: colorScheme.primary.withValues(alpha: 0.15),
                            blurRadius: 40,
                            spreadRadius: -10,
                          ),
                        ],
                      ),
                      child: GlassCard(
                        radius: AppRadius.hero,
                        padding: const EdgeInsets.all(AppSpacing.xl),
                        child: Center(
                          child: SingleChildScrollView(
                            child: Text(
                              _question!.getText(locale.languageCode),
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    height: 1.5,
                                    color: Colors.white,
                                    letterSpacing: 0.5,
                                    shadows: [
                                      const Shadow(color: Colors.black45, blurRadius: 15),
                                    ],
                                  ),
                            ),
                          ),
                        ),
                      ),
                    ).animate().fadeIn(duration: 800.ms).scaleXY(begin: 0.96, end: 1.0, curve: Curves.easeOutBack),
                  ),
                  
                  const SizedBox(height: 24),

                  // Jokers Row (Modern Chips)
                  if (!_answered)
                    _JokerActions(
                      currentTeam: currentTeam,
                      onUseJoker: _useJoker,
                      t: t,
                    ),

                  const SizedBox(height: 16),
                  
                  // Feedback Message (Refined)
                  if (_feedbackMessage.isNotEmpty) ...[
                    Builder(builder: (context) {
                      final isCorrectFeedback = _feedbackMessage.startsWith(_t.translate('correct'));
                      final isAlmostFeedback = _feedbackMessage.startsWith(_t.translate('almost_correct').substring(0, 5));
                      final isWrongFeedback = _answered && !isCorrectFeedback;
                      final accent = isCorrectFeedback
                          ? Colors.greenAccent
                          : isAlmostFeedback
                              ? Colors.orangeAccent
                              : isWrongFeedback
                                  ? Colors.redAccent
                                  : colorScheme.primary;

                      return Container(
                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: accent.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: accent.withValues(alpha: 0.5), width: 1.5),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isCorrectFeedback
                                  ? Icons.check_circle_rounded
                                  : isWrongFeedback
                                      ? Icons.cancel_rounded
                                      : Icons.info_rounded,
                              color: accent,
                              size: 22,
                            ).animate(key: ValueKey('icon-$_feedbackMessage')).scale(
                                  begin: const Offset(0.4, 0.4),
                                  end: const Offset(1.0, 1.0),
                                  curve: Curves.elasticOut,
                                  duration: 500.ms,
                                ),
                            const SizedBox(width: 12),
                            Flexible(
                              child: Text(
                                _feedbackMessage,
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, letterSpacing: 1),
                              ),
                            ),
                          ],
                        ),
                      ).animate(key: ValueKey(_feedbackMessage)).fadeIn().shakeX();
                    }),
                  ],

                  const SizedBox(height: 16),
                  
                  if (ref.read(gameProvider).isMultipleChoice) ...[
                    _buildMultipleChoiceOptions(colorScheme),
                    const SizedBox(height: 16),
                    if (!_answered && !_hintUsed)
                      _buildHintButton(
                        onTap: _useHint,
                        label: '${t.translate('hint_label')} (50:50)',
                        colorScheme: colorScheme,
                      ).animate().fadeIn(delay: 400.ms),
                  ] else ...[
                    // Input Area
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A2238),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: TextField(
                                controller: _answerController,
                                enabled: !_answered,
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, letterSpacing: 1.5),
                                decoration: InputDecoration(
                                  hintText: t.translate('type_or_speak'),
                                  filled: false,
                                  border: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                ),
                                onSubmitted: (_) => _evaluateAnswer(),
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: _answered ? null : _toggleMic,
                            child: AnimatedContainer(
                              duration: 300.ms,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: speechService.isListening 
                                    ? [Colors.redAccent, Colors.red[900]!] 
                                    : [colorScheme.primary, colorScheme.secondary],
                                ),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: (speechService.isListening ? Colors.red : colorScheme.primary).withValues(alpha: 0.4),
                                    blurRadius: 15,
                                    spreadRadius: speechService.isListening ? 4 : 0,
                                  )
                                ],
                              ),
                              child: Icon(
                                speechService.isListening ? Icons.mic : Icons.mic_none,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                          ).animate(target: speechService.isListening ? 1 : 0).scaleXY(end: 1.1),
                        ],
                      ),
                    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2, end: 0),
                    
                    const SizedBox(height: 20),
                    
                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: _buildHintButton(
                            onTap: _answered || _hintUsed ? null : _useHint,
                            label: t.translate('hint_label'),
                            colorScheme: colorScheme,
                          ).animate().fadeIn(delay: 500.ms),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 2,
                          child: _buildSubmitButton(
                            onTap: _answered ? null : _evaluateAnswer,
                            label: t.translate('submit'),
                            colorScheme: colorScheme,
                          ).animate().fadeIn(delay: 600.ms),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),

          // Floating Score Animation (Refined)
          if (_floatingScoreValue != null)
            Align(
              alignment: Alignment.center,
              child: Transform.translate(
                offset: _floatingScorePosition ?? Offset.zero,
                child: Text(
                  _floatingScoreValue! > 0 ? '+${_floatingScoreValue!}' : '${_floatingScoreValue!}',
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                    fontSize: 80,
                    color: _floatingScoreValue! > 0 ? Colors.greenAccent : Colors.redAccent,
                    shadows: [
                      Shadow(
                        color: (_floatingScoreValue! > 0 ? Colors.green : Colors.red).withValues(alpha: 0.8),
                        blurRadius: 40,
                      )
                    ]
                  ),
                ).animate()
                 .fadeIn(duration: 400.ms)
                 .scale(begin: const Offset(0.5, 0.5), end: const Offset(1.0, 1.0), curve: Curves.elasticOut)
                 .slideY(begin: 0, end: -1.5, duration: 2.seconds, curve: Curves.easeOut)
                 .fadeOut(delay: 1.5.seconds, duration: 500.ms),
              ),
            ),

          // Correct-answer confetti burst
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirection: pi / 2,
              maxBlastForce: 4,
              minBlastForce: 2,
              emissionFrequency: 0.06,
              numberOfParticles: 16,
              gravity: 0.15,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMultipleChoiceOptions(ColorScheme colorScheme) {
    return Column(
      children: _options.asMap().entries.map((entry) {
        final idx = entry.key;
        final option = entry.value;
        final isEliminated = _eliminatedOptions.contains(option);
        final isSelected = _selectedOption == option;
        final isCorrect = option.toLowerCase() == _correctOption.toLowerCase();
        final letter = String.fromCharCode(65 + idx); // A, B, C, D
        
        Gradient? cardGradient;
        Color borderColor = Colors.white.withValues(alpha: 0.08);
        List<BoxShadow> cardShadows = [];
        Widget? trailingIcon;
        
        Color badgeBgColor = Colors.white.withValues(alpha: 0.05);
        Color badgeBorderColor = Colors.white.withValues(alpha: 0.2);
        Color badgeTextColor = Colors.white70;
        
        if (_answered) {
          if (isCorrect) {
            cardGradient = LinearGradient(
              colors: [
                Colors.greenAccent.withValues(alpha: 0.25),
                Colors.greenAccent.withValues(alpha: 0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            );
            borderColor = Colors.greenAccent.withValues(alpha: 0.6);
            cardShadows = [
              BoxShadow(
                color: Colors.greenAccent.withValues(alpha: 0.25),
                blurRadius: 15,
                spreadRadius: 1,
              )
            ];
            trailingIcon = const Icon(Icons.check_circle_rounded, color: Colors.greenAccent);
            badgeBgColor = Colors.greenAccent.withValues(alpha: 0.2);
            badgeBorderColor = Colors.greenAccent.withValues(alpha: 0.5);
            badgeTextColor = Colors.white;
          } else if (isSelected) {
            cardGradient = LinearGradient(
              colors: [
                Colors.redAccent.withValues(alpha: 0.25),
                Colors.redAccent.withValues(alpha: 0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            );
            borderColor = Colors.redAccent.withValues(alpha: 0.6);
            cardShadows = [
              BoxShadow(
                color: Colors.redAccent.withValues(alpha: 0.25),
                blurRadius: 15,
                spreadRadius: 1,
              )
            ];
            trailingIcon = const Icon(Icons.cancel_rounded, color: Colors.redAccent);
            badgeBgColor = Colors.redAccent.withValues(alpha: 0.2);
            badgeBorderColor = Colors.redAccent.withValues(alpha: 0.5);
            badgeTextColor = Colors.white;
          } else {
            cardGradient = LinearGradient(
              colors: [
                Colors.white.withValues(alpha: 0.03),
                Colors.white.withValues(alpha: 0.01),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            );
            borderColor = Colors.white.withValues(alpha: 0.05);
          }
        } else if (isEliminated) {
          cardGradient = LinearGradient(
            colors: [
              Colors.white.withValues(alpha: 0.01),
              Colors.white.withValues(alpha: 0.005),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          );
          borderColor = Colors.white.withValues(alpha: 0.02);
          badgeTextColor = Colors.white10;
          badgeBorderColor = Colors.white.withValues(alpha: 0.05);
          badgeBgColor = Colors.transparent;
        } else if (isSelected) {
          cardGradient = LinearGradient(
            colors: [
              colorScheme.primary.withValues(alpha: 0.25),
              colorScheme.secondary.withValues(alpha: 0.08),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          );
          borderColor = colorScheme.primary;
          cardShadows = [
            BoxShadow(
              color: colorScheme.primary.withValues(alpha: 0.3),
              blurRadius: 15,
              spreadRadius: 1,
            )
          ];
          badgeBgColor = colorScheme.primary.withValues(alpha: 0.25);
          badgeBorderColor = colorScheme.primary;
          badgeTextColor = Colors.white;
        } else {
          cardGradient = LinearGradient(
            colors: [
              Colors.white.withValues(alpha: 0.06),
              Colors.white.withValues(alpha: 0.01),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          );
          borderColor = Colors.white.withValues(alpha: 0.08);
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: AnimatedOpacity(
            duration: 300.ms,
            opacity: isEliminated ? 0.15 : 1.0,
            child: AnimatedScale(
              scale: isSelected && !_answered ? 1.025 : 1.0,
              duration: 250.ms,
              curve: Curves.easeOutBack,
              child: InkWell(
                onTap: (_answered || isEliminated) ? null : () {
                  setState(() {
                    _selectedOption = option;
                  });
                  _answerController.text = option;
                  _evaluateAnswer();
                },
                borderRadius: BorderRadius.circular(20),
                child: AnimatedContainer(
                      duration: 250.ms,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      decoration: BoxDecoration(
                        gradient: cardGradient,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: borderColor, width: isSelected ? 2.0 : 1.2),
                        boxShadow: cardShadows,
                      ),
                      child: Row(
                        children: [
                          AnimatedContainer(
                            duration: 250.ms,
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: badgeBgColor,
                              border: Border.all(color: badgeBorderColor, width: 1.5),
                            ),
                            child: Center(
                              child: Text(
                                letter,
                                style: GoogleFonts.outfit(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w900,
                                  color: badgeTextColor,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              option,
                              style: GoogleFonts.outfit(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: isEliminated 
                                    ? Colors.white24 
                                    : (isCorrect && _answered) 
                                        ? Colors.greenAccent 
                                        : isSelected 
                                            ? Colors.white 
                                            : Colors.white70,
                              ),
                            ),
                          ),
                          ?trailingIcon,
                        ],
                      ),
                    ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildHintButton({required VoidCallback? onTap, required String label, required ColorScheme colorScheme}) {
    final enabled = onTap != null;
    final buttonColor = colorScheme.primary;
    return Opacity(
      opacity: enabled ? 1.0 : 0.4,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: enabled ? buttonColor.withValues(alpha: 0.5) : Colors.white10,
            width: 1.5,
          ),
          boxShadow: enabled
              ? [
                  BoxShadow(
                    color: buttonColor.withValues(alpha: 0.1),
                    blurRadius: 10,
                  )
                ]
              : [],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 18),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.lightbulb_outline_rounded,
                        size: 20,
                        color: enabled ? buttonColor : Colors.white24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        label.toUpperCase(),
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                          color: enabled ? buttonColor : Colors.white24,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSubmitButton({required VoidCallback? onTap, required String label, required ColorScheme colorScheme}) {
    final enabled = onTap != null;
    return Opacity(
      opacity: enabled ? 1.0 : 0.4,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: enabled
              ? LinearGradient(
                  colors: [colorScheme.primary, colorScheme.secondary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: enabled ? null : Colors.white.withValues(alpha: 0.05),
          boxShadow: enabled
              ? [
                  BoxShadow(
                    color: colorScheme.primary.withValues(alpha: 0.3),
                    blurRadius: 16,
                    spreadRadius: 1,
                  )
                ]
              : [],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 18),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.check_rounded,
                        size: 20,
                        color: enabled ? Colors.black : Colors.white24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        label.toUpperCase(),
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.5,
                          color: enabled ? Colors.black : Colors.white24,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _QuestionHeader extends StatelessWidget {
  final String teamName;
  final String category;
  final int difficulty;
  final AppLocalizations t;

  const _QuestionHeader({
    required this.teamName,
    required this.category,
    required this.difficulty,
    required this.t,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 24,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(2),
                boxShadow: [
                  BoxShadow(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5), blurRadius: 10),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text(
              '$teamName${t.translate('turn_suffix')}',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                  ),
            ),
          ],
        ).animate(key: ValueKey(teamName)).fadeIn().slideX(begin: -0.1, end: 0),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Text(
            '${t.translate(category.toLowerCase())} • ${t.translate('lvl')} $difficulty',
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.7),
              fontWeight: FontWeight.w700,
              letterSpacing: 2,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }
}

class _JokerActions extends StatelessWidget {
  final dynamic currentTeam;
  final Function(String) onUseJoker;
  final AppLocalizations t;

  const _JokerActions({
    required this.currentTeam,
    required this.onUseJoker,
    required this.t,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _JokerButton(
          icon: Icons.ac_unit_rounded,
          label: t.translate('freeze'),
          isAvailable: currentTeam.availableJokers['time_freeze'] ?? false,
          onTap: () => onUseJoker('time_freeze'),
          color: Colors.cyanAccent,
        ),
        _JokerButton(
          icon: Icons.bolt_rounded,
          label: t.translate('x2_risk'),
          isAvailable: currentTeam.availableJokers['double_risk'] ?? false,
          onTap: () => onUseJoker('double_risk'),
          color: Colors.orangeAccent,
        ),
        _JokerButton(
          icon: Icons.skip_next_rounded,
          label: t.translate('pass'),
          isAvailable: currentTeam.availableJokers['pass'] ?? false,
          onTap: () => onUseJoker('pass'),
          color: Colors.purpleAccent,
        ),
      ],
    ).animate().fadeIn(delay: 300.ms);
  }
}

class _JokerButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isAvailable;
  final VoidCallback onTap;
  final Color color;

  const _JokerButton({
    required this.icon,
    required this.label,
    required this.isAvailable,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isAvailable ? onTap : null,
      child: Column(
        children: [
          AnimatedContainer(
            duration: 300.ms,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isAvailable ? color.withValues(alpha: 0.15) : Colors.white.withValues(alpha: 0.03),
              shape: BoxShape.circle,
              border: Border.all(
                color: isAvailable ? color.withValues(alpha: 0.5) : Colors.white.withValues(alpha: 0.05),
                width: 2,
              ),
              boxShadow: isAvailable ? [
                BoxShadow(
                  color: color.withValues(alpha: 0.2),
                  blurRadius: 15,
                )
              ] : [],
            ),
            child: Icon(
              icon,
              color: isAvailable ? color : Colors.white12,
              size: 28,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
              color: isAvailable ? Colors.white : Colors.white12,
            ),
          ),
        ],
      ),
    );
  }
}

class _TimerDisplay extends StatelessWidget {
  final int timeLeft;

  const _TimerDisplay({required this.timeLeft});

  @override
  Widget build(BuildContext context) {
    final isWarningTime = timeLeft <= 5;
    final color = isWarningTime ? Colors.redAccent : Theme.of(context).colorScheme.primary;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: color.withValues(alpha: 0.4),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(color: color.withValues(alpha: 0.1), blurRadius: 15),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.timer_outlined, color: color, size: 20),
          const SizedBox(width: 8),
          Text(
            '00:${timeLeft.toString().padLeft(2, '0')}',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    ).animate(target: isWarningTime ? 1 : 0).shake(duration: 500.ms);
  }
}
