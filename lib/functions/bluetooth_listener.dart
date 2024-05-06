// This observer listens for Bluetooth Off and dismisses the DeviceScreen
import 'dart:async';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BluetoothListener {
  Future<List<BluetoothDevice>> startBluetoothScan() async {
    List<BluetoothDevice> devices = [];

    await FlutterBluePlus.adapterState
        .where((val) => val == BluetoothAdapterState.on)
        .first;

    await FlutterBluePlus.startScan(
      timeout: const Duration(seconds: 15),
    );

    var subscription = FlutterBluePlus.onScanResults.listen((results) {
      if (results.isNotEmpty) {
        ScanResult r = results.last;

        devices.add(r.device);
      }
    }, onError: (e) => print(e));

    await FlutterBluePlus.isScanning.where((val) => val == false).first;

    // cleanup: cancel subscription when scanning stops
    FlutterBluePlus.cancelWhenScanComplete(subscription);

    return devices;
  }

  Future<void> connectToDevice(BluetoothDevice device) async {
    // Listen for disconnection
    var subscription =
        device.connectionState.listen((BluetoothConnectionState state) async {
      if (state == BluetoothConnectionState.disconnected) {
        // 1. typically, start a periodic timer that tries to
        //    reconnect, or just call connect() again right now
        // 2. you must always re-discover services after disconnection!
        print("$device $device");
      }
    });

    // Connect to the device
    await device.connect();

    // Disconnect from device
    await device.disconnect();

    // Cleanup: cancel subscription when disconnected
    // Note: `delayed:true` lets the `connectionState` listener receive
    //        the `disconnected` event before it is canceled
    // Note: `next:true` means cancel on *next* disconnection. Without this
    //        if we're already disconnected it would cancel immediately
    device.cancelWhenDisconnected(subscription, delayed: true, next: true);

    // Cancel to prevent duplicate listeners
    subscription.cancel();
  }
}
