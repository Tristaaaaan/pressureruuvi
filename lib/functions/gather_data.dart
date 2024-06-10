import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pressureruuvi/functions/csv_generator.dart';
import 'package:pressureruuvi/services/state_provider.dart';

void cancelAndDisposeSubscription(String containerName,
    Map<String, StreamSubscription<List<int>>> subscriptions) {
  if (subscriptions.containsKey(containerName)) {
    subscriptions[containerName]!.cancel();
    subscriptions.remove(containerName);
  }
}

// Store subscriptions per container
final Map<String, StreamSubscription<List<int>>> subscriptions = {};

// BluetoothDevice device,
Future<void> discoverServices(
  BluetoothDevice device,
  WidgetRef ref,
  BuildContext context,
) async {
  final Map<String, List<List<PressureData>>> devicesData =
      ref.watch(devicesDataProvider);

  // Check if the deviceName exists in devicesData, if not add it
  if (!devicesData.containsKey(device.advName)) {
    devicesData[device.advName] = [];
  }
  devicesData[device.advName]!.clear();

  List<BluetoothService> services = await device.discoverServices();

  // _servicesStreamController.add(services);

  for (var service in services) {
    for (var characteristic in service.characteristics) {
      // Subscribe to notifications if the characteristic supports it
      if (characteristic.properties.notify) {
        await characteristic.setNotifyValue(true);
        subscriptions[device.advName] = characteristic.onValueReceived.listen(
          (value) {
            Uint8List receivedData = Uint8List.fromList(value);
            // Unpack the data (assuming it's a list of 31 floats and 1 integer)
            ByteData byteData = ByteData.sublistView(receivedData);
            List<double> dataAscii = [];
            for (int i = 0; i < 31; i++) {
              dataAscii
                  .add(byteData.getFloat32(i * 4, Endian.little).toDouble());
            }
            dataAscii.add(byteData.getInt32(31 * 4, Endian.little).toDouble());

            PressureData pressureData = PressureData(
              date: DateTime.now().microsecondsSinceEpoch,
              value: value,
            );

            devicesData[device.advName]!.add([pressureData]);
          },
        );
      }
    }
  }
}
