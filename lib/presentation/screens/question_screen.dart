import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../domain/entities/question.dart';
import '../../services/answer_evaluator_service.dart';
import '../../services/audio_service.dart';
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
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
      _feedbackMessage = 'TIME IS UP!\nCorrect answer: ${_question?.answers.first.toUpperCase()}';
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
        _feedbackMessage = 'CORRECT!';
        ref.read(audioServiceProvider).playDing();
        _finishTurn(true);
      } else if (result == AnswerResult.almostCorrect) {
        _feedbackMessage = 'ALMOST CORRECT! Check your spelling.';
      } else {
        _answered = true;
        _timer?.cancel();
        _feedbackMessage = 'INCORRECT!\nThe correct answer was: ${_question!.answers.first.toUpperCase()}';
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
        // Position score near the top center
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
      _feedbackMessage = 'HINT: $hintText (Score reduced by 50%)';
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
        setState(() {}); // Trigger rebuild to show listening UI
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Microphone permission required for this feature.')),
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
        _feedbackMessage = 'TIME FREEZE! +15 Seconds';
      } else if (jokerKey == 'double_risk') {
        _isDoubleRiskActive = true;
        _feedbackMessage = 'DOUBLE RISK! Correct: x2, Wrong: -x2';
      } else if (jokerKey == 'pass') {
        // Pass immediately stops timer and delegates to next team
        _timer?.cancel();
        notifier.nextTurn();
        _feedbackMessage = 'PASSED! Next team must answer.';
        
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

    final gameState = ref.watch(gameProvider);
    final currentTeam = gameState.currentTeam;
    final isWarningTime = _timeLeft <= 5;
    final speechService = ref.watch(speechServiceProvider);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          // Background Gradient
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                    Theme.of(context).scaffoldBackgroundColor,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${currentTeam.name}\'s Turn',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.5,
                                ),
                          ).animate(key: ValueKey(currentTeam.id)).fadeIn().slideX(),
                          const SizedBox(height: 4),
                          Text(
                            '${widget.category} - Lvl ${widget.difficulty}',
                            style: const TextStyle(color: Colors.white54, letterSpacing: 1),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: isWarningTime ? Colors.red.withValues(alpha: 0.2) : Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isWarningTime ? Colors.red : Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
                          ),
                        ),
                        child: Text(
                          '00:${_timeLeft.toString().padLeft(2, '0')}',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: isWarningTime ? Colors.redAccent : Colors.white,
                          ),
                        ),
                      ).animate(target: isWarningTime ? 1 : 0).scaleXY(end: 1.1).tint(color: Colors.red).shake(),
                    ],
                  ),
                  const SizedBox(height: 32),
                  
                  // Question Card (Glassmorphism)
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          padding: const EdgeInsets.all(32),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                          ),
                          child: Center(
                            child: SingleChildScrollView(
                              child: Text(
                                _question!.questionText,
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      height: 1.5,
                                    ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ).animate().fadeIn(duration: 600.ms).scaleXY(begin: 0.9, end: 1.0, curve: Curves.easeOutBack),
                  ),
                  const SizedBox(height: 16),

                  // Jokers Row
                  if (!_answered)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildJokerButton(
                          icon: Icons.ac_unit,
                          label: 'Freeze',
                          isAvailable: currentTeam.availableJokers['time_freeze'] ?? false,
                          onTap: () => _useJoker('time_freeze'),
                        ),
                        _buildJokerButton(
                          icon: Icons.monetization_on,
                          label: 'x2 Risk',
                          isAvailable: currentTeam.availableJokers['double_risk'] ?? false,
                          onTap: () => _useJoker('double_risk'),
                        ),
                        _buildJokerButton(
                          icon: Icons.switch_right,
                          label: 'Pass',
                          isAvailable: currentTeam.availableJokers['pass'] ?? false,
                          onTap: () => _useJoker('pass'),
                        ),
                      ],
                    ).animate().fadeIn(delay: 300.ms),

                  const SizedBox(height: 16),
                  
                  // Feedback Message
                  if (_feedbackMessage.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: _feedbackMessage.startsWith('CORRECT') 
                            ? Colors.green.withValues(alpha: 0.2)
                            : _feedbackMessage.startsWith('ALMOST')
                                ? Colors.orange.withValues(alpha: 0.2)
                                : Colors.blue.withValues(alpha: 0.2), // Default for jokers/hints
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: _feedbackMessage.startsWith('CORRECT') 
                            ? Colors.green
                            : _feedbackMessage.startsWith('ALMOST')
                                ? Colors.orange
                                : Colors.blue,
                        ),
                      ),
                      child: Text(
                        _feedbackMessage,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1),
                      ),
                    ).animate(key: ValueKey(_feedbackMessage)).fadeIn().shakeX(),
                    
                  // Input Area with Mic
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _answerController,
                          enabled: !_answered,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 2),
                          textAlign: TextAlign.center,
                          decoration: const InputDecoration(
                            hintText: 'TYPE OR SPEAK ANSWER',
                          ),
                          onSubmitted: (_) => _evaluateAnswer(),
                        ),
                      ),
                      const SizedBox(width: 12),
                      GestureDetector(
                        onTap: _answered ? null : _toggleMic,
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: speechService.isListening 
                              ? Colors.redAccent 
                              : Theme.of(context).colorScheme.primary,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: (speechService.isListening ? Colors.red : Theme.of(context).colorScheme.primary).withValues(alpha: 0.5),
                                blurRadius: 15,
                                spreadRadius: speechService.isListening ? 5 : 1,
                              )
                            ],
                          ),
                          child: Icon(
                            speechService.isListening ? Icons.mic : Icons.mic_none,
                            color: speechService.isListening ? Colors.white : Theme.of(context).scaffoldBackgroundColor,
                            size: 28,
                          ),
                        ).animate(target: speechService.isListening ? 1 : 0).scaleXY(end: 1.1).shimmer(),
                      ),
                    ],
                  ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2, end: 0),
                  const SizedBox(height: 16),
                  
                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _answered || _hintUsed ? null : _useHint,
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            side: BorderSide(color: Theme.of(context).colorScheme.primary),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          child: const Text('HINT', style: TextStyle(fontWeight: FontWeight.bold)),
                        ).animate().fadeIn(delay: 500.ms),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed: _answered ? null : _evaluateAnswer,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                          ),
                          child: const Text('SUBMIT'),
                        ).animate().fadeIn(delay: 600.ms),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Floating Score Animation
          if (_floatingScoreValue != null)
            Align(
              alignment: Alignment.center,
              child: Transform.translate(
                offset: _floatingScorePosition ?? Offset.zero,
                child: Text(
                  _floatingScoreValue! > 0 ? '+${_floatingScoreValue!}' : '${_floatingScoreValue!}',
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: _floatingScoreValue! > 0 ? Colors.greenAccent : Colors.redAccent,
                    shadows: [
                      Shadow(
                        color: _floatingScoreValue! > 0 ? Colors.green : Colors.red,
                        blurRadius: 20,
                      )
                    ]
                  ),
                ).animate()
                 .fadeIn(duration: 400.ms)
                 .slideY(begin: 0, end: -2.0, duration: 2.seconds, curve: Curves.easeOut)
                 .fadeOut(delay: 1.5.seconds, duration: 500.ms),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildJokerButton({
    required IconData icon,
    required String label,
    required bool isAvailable,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: isAvailable ? onTap : null,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isAvailable ? Theme.of(context).colorScheme.secondary.withValues(alpha: 0.2) : Colors.grey.withValues(alpha: 0.1),
              shape: BoxShape.circle,
              border: Border.all(
                color: isAvailable ? Theme.of(context).colorScheme.secondary : Colors.grey.withValues(alpha: 0.3),
                width: 2,
              ),
              boxShadow: isAvailable ? [
                BoxShadow(
                  color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.3),
                  blurRadius: 10,
                )
              ] : [],
            ),
            child: Icon(
              icon,
              color: isAvailable ? Theme.of(context).colorScheme.secondary : Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isAvailable ? Colors.white : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
