// This observer listens for Bluetooth Off and dismisses the DeviceScreen
import 'dart:async';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

// final bluetoothDevicesProvider =
//     StreamProvider<List<BluetoothDevice>>((ref) async* {
//   ref.read(isRefreshingProvider.notifier).update((state) => false);
//   List<BluetoothDevice> devices = [];
//   await FlutterBluePlus.adapterState
//       .where((val) => val == BluetoothAdapterState.on)
//       .first;

//   await FlutterBluePlus.startScan(
//     timeout: const Duration(seconds: 3),
//   );

//   var subscription = FlutterBluePlus.onScanResults.listen((results) {
//     if (results.isNotEmpty) {
//       ScanResult r = results.last;
//       if (!r.device.isConnected &&
//           !devices.contains(r.device) &&
//           !r.device.advName.contains("Ruuvi")) {
//         devices.add(r.device);
//         print(r.device);
//       }
//     }
//   }, onError: (e) => print(e));

//   await FlutterBluePlus.isScanning.where((val) => val == false).first;

//   FlutterBluePlus.cancelWhenScanComplete(subscription);

//   ref.read(isRefreshingProvider.notifier).update((state) => false);

//   yield devices;
// });

final bluetoothProviders = StateProvider.autoDispose<BluetoothListener>((ref) {
  return BluetoothListener();
});

final bluetoothDevicesProvider =
    FutureProvider<List<BluetoothDevice>>((ref) async {
  List<BluetoothDevice> devices = [];
  await FlutterBluePlus.adapterState
      .where((val) => val == BluetoothAdapterState.on)
      .first;

  await FlutterBluePlus.startScan(
    timeout: const Duration(seconds: 1),
  );

  var subscription = FlutterBluePlus.onScanResults.listen((results) {
    if (results.isNotEmpty) {
      ScanResult r = results.last;
      if (!r.device.isConnected &&
          !devices.contains(r.device) &&
          !r.device.advName.contains("Ruuvi")) {
        devices.add(r.device);
      }
    }
  }, onError: (e) => print(e));

  await FlutterBluePlus.isScanning.where((val) => val == false).first;

  FlutterBluePlus.cancelWhenScanComplete(subscription);

  return devices;
});

final connectedDevicesProvider = StreamProvider<List<BluetoothDevice>>(
  (ref) async* {
    List<BluetoothDevice> devices = [];

    List<BluetoothDevice> devs = FlutterBluePlus.connectedDevices;
    for (var d in devs) {
      devices.add(d);
    }

    yield devices;
  },
);

class BluetoothListener {
  Future<bool> connectToDevice(BluetoothDevice device) async {
    print("Connecting to device: ${device.advName} (${device.remoteId})");

    // Listen for disconnection
    var subscription =
        device.connectionState.listen((BluetoothConnectionState state) async {
      if (state == BluetoothConnectionState.disconnected) {
        // 1. typically, start a periodic timer that tries to
        //    reconnect, or just call connect() again right now
        // 2. you must always re-discover services after disconnection!
        print(
            "Disconnected from device: ${device.advName} (${device.remoteId})");
      }
    });

    try {
      // Check if the device is connected
      if (device.connectionState == BluetoothConnectionState.connected) {
        print("Device is already connected");
        return true;
      }

      // Connect to the device
      print("Connecting to device...");
      await device.connect();
      print("CONNECTED");

      // Cancel to prevent duplicate listeners
      subscription.cancel();

      return true;
    } catch (e) {
      print("Error connecting to device: $e");

      device.cancelWhenDisconnected(subscription, delayed: true, next: true);
      return false;
    }
  }
}
