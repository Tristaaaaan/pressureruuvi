// This observer listens for Bluetooth Off and dismisses the DeviceScreen
import 'dart:async';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pressureruuvi/home/ruuvi_devices.dart';

final bluetoothProviders = StateProvider.autoDispose<BluetoothListener>((ref) {
  return BluetoothListener();
});

Future<List<BluetoothDevice>> performScan() async {
  List<BluetoothDevice> devices = [];

  await FlutterBluePlus.adapterState
      .where((val) => val == BluetoothAdapterState.on)
      .first;

  await FlutterBluePlus.startScan(
    timeout: const Duration(seconds: 5),
  );

  var subscription = FlutterBluePlus.onScanResults.listen((results) {
    if (results.isNotEmpty) {
      ScanResult r = results.last;
      if (!r.device.isConnected &&
          !devices.contains(r.device) &&
          r.device.advName.contains("Ruuvi")) {
        devices.add(r.device);
      }
    }
  }, onError: (e) => print(e));

  await FlutterBluePlus.isScanning.where((val) => val == false).first;

  subscription.cancel();

  return devices;
}

Stream<List<BluetoothDevice>> bluetoothDevicesStream() async* {
  while (true) {
    yield await performScan();

    await Future.delayed(const Duration(seconds: 10));
  }
}

final bluetoothDevicesProvider = StreamProvider<List<BluetoothDevice>>((ref) {
  return bluetoothDevicesStream();
});

Stream<List<BluetoothDevice>> connectedDevicesStream(WidgetRef ref) async* {
  while (true) {
    final devices = FlutterBluePlus.connectedDevices;
    yield devices;
    ref.read(devicesProvider.notifier).update((state) => devices);
    await Future.delayed(const Duration(seconds: 2));
  }
}

final connectedDevicesProvider =
    StreamProvider.family<List<BluetoothDevice>, WidgetRef>((ref, widget) {
  return connectedDevicesStream(widget);
});

class BluetoothListener {
  Future<bool> connectToDevice(BluetoothDevice device) async {
    // Listen for disconnection
    var subscription =
        device.connectionState.listen((BluetoothConnectionState state) async {
      if (state == BluetoothConnectionState.disconnected) {}
    });

    try {
      // Check if the device is connected
      if (device.connectionState == BluetoothConnectionState.connected) {
        return true;
      }

      await device.connect();

      // Cancel to prevent duplicate listeners
      subscription.cancel();

      return true;
    } catch (e) {
      device.cancelWhenDisconnected(subscription, delayed: true, next: true);
      return false;
    }
  }

  Future<bool> disconnectToDevice(BluetoothDevice device) async {
    try {
      // Disconnect the device
      await device.disconnect();

      return true;
    } catch (e) {
      // Handle disconnection error if needed
      return false;
    }
  }
}
