

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';

final clickedIconProvider = StateProvider<Map<String, bool>>((ref) {
  return {};
});

final stopWatchTimerProvider =
    StateProvider.family<StopWatchTimer, String>((ref, deviceName) {
  return StopWatchTimer();
});

