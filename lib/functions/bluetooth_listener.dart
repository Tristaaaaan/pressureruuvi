// This observer listens for Bluetooth Off and dismisses the DeviceScreen
import 'dart:async';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pressureruuvi/services/state_provider.dart';

final bluetoothProviders = StateProvider.autoDispose<BluetoothListener>((ref) {
  return BluetoothListener();
});

Future<List<BluetoothDevice>> performScan() async {
  List<BluetoothDevice> devices = [];

  await FlutterBluePlus.adapterState
      .where((val) => val == BluetoothAdapterState.on)
      .first;

  await FlutterBluePlus.startScan(
    timeout: const Duration(seconds: 4),
  );

  var subscription = FlutterBluePlus.onScanResults.listen(
    (results) {
      if (results.isNotEmpty) {
        ScanResult r = results.last;
        if (!r.device.isConnected &&
            !devices.contains(r.device) &&
            r.device.advName.contains("Ruuvi")) {
          devices.add(r.device);
        }
      }
    },
  );

  await FlutterBluePlus.isScanning.where((val) => val == false).first;

  subscription.cancel();

  return devices;
}

Stream<List<BluetoothDevice>> bluetoothDevicesStream() async* {
  while (true) {
    yield await performScan();

    await Future.delayed(const Duration(seconds: 4));
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
  // Connecting to a bluetooth device
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

  Future<bool> disconnectFromDevice(BluetoothDevice device) async {
    try {
      // Check if the device is connected before attempting to disconnect
      if (device.isConnected) {
        // Disconnect the device
        await device.disconnect();

        // Verify the disconnection (this might depend on your Bluetooth library)
        if (!device.isConnected) {
          print("Device disconnected successfully");
          return true;
        } else {
          print("Failed to disconnect the device");
          return false;
        }
      } else {
        print("Device is already disconnected");
        return true;
      }
    } catch (e) {
      // Handle disconnection error if needed
      print("Error disconnecting the device: $e");
      return false;
    }
  }
}
