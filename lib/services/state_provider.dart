import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pressureruuvi/model/pressure_data_model.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';

// Return the map of Sensor Containers which collects data
final clickedIconProvider = StateProvider<Map<String, bool>>((ref) {
  return {};
});

// Controls the StopWatchTimer package for each sensor
final stopWatchTimerProvider =
    StateProvider.family<StopWatchTimer, String>((ref, deviceName) {
  return StopWatchTimer();
});

// List of connected sensors
final devicesProvider = StateProvider<List<BluetoothDevice>>((ref) {
  return [];
});

// List of sensors which are currently gathering data
final devicesListProvider = StateProvider<List<String>>((ref) {
  return [];
});

// Holds the data of each sensor
final devicesDataProvider =
    StateProvider<Map<String, List<List<PressureData>>>>((ref) {
  return {};
});

// Check if the process is ongoing
final isLoadingProvider = StateProvider<bool>((ref) => false);
