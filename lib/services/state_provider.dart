import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pressureruuvi/functions/csv_generator.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';

final clickedIconProvider = StateProvider<Map<String, bool>>((ref) {
  return {};
});

final stopWatchTimerProvider =
    StateProvider.family<StopWatchTimer, String>((ref, deviceName) {
  return StopWatchTimer();
});

final devicesProvider = StateProvider<List<BluetoothDevice>>((ref) {
  return [];
});

final devicesListProvider = StateProvider<List<String>>((ref) {
  return [];
});

final isRefreshingProvider = StateProvider<bool>((ref) => false);

final devicesDataProvider =
    StateProvider<Map<String, List<List<PressureData>>>>((ref) {
  return {};
});

final streamFromDevices =
    StreamProvider<Map<String, List<List<PressureData>>>>((ref) {
  final state = ref.watch(devicesDataProvider);

  return Stream.value(state);
});

final isLoadingProvider = StateProvider<bool>((ref) => false);
