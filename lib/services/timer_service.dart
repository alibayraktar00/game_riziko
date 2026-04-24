import 'dart:async';

class TimerService {
  Timer? _timer;
  int _remainingSeconds = 0;
  final void Function(int) onTick;
  final void Function() onFinished;

  TimerService({
    required this.onTick,
    required this.onFinished,
  });

  void start(int seconds) {
    cancel();
    _remainingSeconds = seconds;
    onTick(_remainingSeconds);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        _remainingSeconds--;
        onTick(_remainingSeconds);
      }
      
      if (_remainingSeconds == 0) {
        cancel();
        onFinished();
      }
    });
  }

  void cancel() {
    _timer?.cancel();
    _timer = null;
  }
}
