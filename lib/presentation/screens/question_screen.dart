import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/localization/locale_provider.dart';
import '../../domain/entities/question.dart';
import '../../services/answer_evaluator_service.dart';
import '../../services/audio_service.dart';
import '../../services/settings_service.dart';
import '../../services/speech_service.dart';
import '../providers/game_provider.dart';
import '../providers/providers.dart';

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
  Timer? _timer;
  int _timeLeft = 30;
  String _feedbackMessage = '';
  bool _hintUsed = false;
  bool _answered = false;
  bool _isDoubleRiskActive = false;

  int? _floatingScoreValue;
  Offset? _floatingScorePosition;

  AppLocalizations get _t => AppLocalizations(ref.read(localeProvider));

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _timeLeft = ref.read(settingsServiceProvider).getTimerDuration();
      _initQuestion();
      ref.read(audioServiceProvider).playBackgroundMusic();
    });
  }

  void _initQuestion() {
    final availableQuestions = ref.read(gameProvider).availableQuestions;
    final questions = availableQuestions.where(
      (q) => q.category == widget.category && q.difficulty == widget.difficulty,
    ).toList();

    if (questions.isNotEmpty) {
      setState(() {
        _question = questions.first;
      });
      _startTimer();
    } else {
      context.pop();
    }
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
    setState(() {
      _hintUsed = true;
      final ans = _question!.answers.first;
      final hintText = ans.length > 2 
          ? '${ans.substring(0, 2)}${List.filled(ans.length - 2, '*').join('')}'
          : ans.characters.first;
      _feedbackMessage = '${_t.translate('hint_label')}: $hintText ${_t.translate('hint_score_reduced')}';
    });
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
    ref.read(audioServiceProvider).stopBackgroundMusic();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_question == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
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
          // Premium Background Gradient
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.topRight,
                  radius: 1.5,
                  colors: [
                    colorScheme.primary.withValues(alpha: 0.1),
                    const Color(0xFF131B2F),
                    const Color(0xFF0B0F19),
                  ],
                ),
              ),
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
                  
                  // Question Card (High-Fidelity Glassmorphism)
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
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(32),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                          child: Container(
                            padding: const EdgeInsets.all(32),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.white.withValues(alpha: 0.08),
                                  Colors.white.withValues(alpha: 0.02),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(32),
                              border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
                            ),
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
                  if (_feedbackMessage.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: _feedbackMessage.startsWith(_t.translate('correct')) 
                            ? Colors.greenAccent.withValues(alpha: 0.15)
                            : _feedbackMessage.startsWith(_t.translate('almost_correct').substring(0, 5))
                                ? Colors.orangeAccent.withValues(alpha: 0.15)
                                : colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _feedbackMessage.startsWith(_t.translate('correct')) 
                            ? Colors.greenAccent.withValues(alpha: 0.5)
                            : _feedbackMessage.startsWith(_t.translate('almost_correct').substring(0, 5))
                                ? Colors.orangeAccent.withValues(alpha: 0.5)
                                : colorScheme.primary.withValues(alpha: 0.3),
                          width: 1.5,
                        ),
                      ),
                      child: Text(
                        _feedbackMessage,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, letterSpacing: 1),
                      ),
                    ).animate(key: ValueKey(_feedbackMessage)).fadeIn().shakeX(),
                    
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
                        child: OutlinedButton(
                          onPressed: _answered || _hintUsed ? null : _useHint,
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          ),
                          child: Text(t.translate('hint_label')),
                        ).animate().fadeIn(delay: 500.ms),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed: _answered ? null : _evaluateAnswer,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          ),
                          child: Text(t.translate('submit')),
                        ).animate().fadeIn(delay: 600.ms),
                      ),
                    ],
                  ),
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
        ],
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
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    ).animate(target: isWarningTime ? 1 : 0).shake(duration: 500.ms);
  }
}
