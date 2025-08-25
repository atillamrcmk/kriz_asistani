import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Nefes döngüsü: 0=Al (4 sn), 1=Tut (4 sn), 2=Ver (6 sn)
class PanicController extends ChangeNotifier {
  int phase = 0;
  int secs = 4;
  Timer? _timer;

  static const int targetRounds = 3;
  int completedRounds = 0;

  // UI için önerilen animasyon değerleri (view bunları kullanır)
  double scale = 1.18;
  double glow = .50;

  bool get isRunning => _timer?.isActive == true;
  bool get isDone => completedRounds >= targetRounds && !isRunning;

  String get label => switch (phase) {
    0 => 'Nefes al',
    1 => 'Tut',
    _ => 'Ver',
  };
  int get phaseTotal => switch (phase) {
    0 => 4,
    1 => 4,
    _ => 6,
  };

  void start() {
    _timer?.cancel();
    completedRounds = 0;
    phase = 0;
    secs = 4;
    _applyPhaseStyle();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      secs--;
      if (secs <= 0) {
        if (phase == 0) {
          phase = 1;
          secs = 4;
        } else if (phase == 1) {
          phase = 2;
          secs = 6;
        } else {
          completedRounds++;
          if (completedRounds >= targetRounds) {
            stop();
            notifyListeners();
            return;
          }
          phase = 0;
          secs = 4;
        }
        _applyPhaseStyle();
        HapticFeedback.lightImpact();
      }
      notifyListeners();
    });
    notifyListeners();
  }

  void restart() => start();

  void stop() {
    _timer?.cancel();
    _timer = null;
    notifyListeners();
  }

  void disposeTimer() {
    _timer?.cancel();
    _timer = null;
  }

  void _applyPhaseStyle() {
    if (phase == 0) {
      scale = 1.18;
      glow = .50;
    } else if (phase == 1) {
      scale = 1.00;
      glow = .40;
    } else {
      scale = 0.86;
      glow = .30;
    }
  }
}
