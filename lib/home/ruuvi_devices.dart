import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pressureruuvi/components/bluetooth_device_container.dart';
import 'package:pressureruuvi/functions/gather_data.dart';
import 'package:pressureruuvi/services/state_provider.dart';

final devicesProvider = StateProvider<List<BluetoothDevice>>((ref) {
  return [];
});

class RuuviSensors extends ConsumerWidget {
  const RuuviSensors({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final devices = ref.watch(devicesProvider);
    final List<String> devicesList = [];

    return Scaffold(
        appBar: AppBar(
          title: const Text("Ruuvi Sensors"),
        ),
        body: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: devices.length,
                itemBuilder: (context, index) {
                  final device = devices[index];
                  return BluetoothDeviceContainer(
                    device: device,
                    onTap: () {
                      if (!devicesList.contains(device.advName)) {
                        discoverServices(device, ref, context);
                        devicesList.add(device.advName);
                      } else {
                        devicesList.remove(device.advName);

                        cancelAndDisposeSubscription(
                            device.advName, subscriptions);
                      }
                      ref.read(clickedIconProvider.notifier).update(
                        (state) {
                          return {
                            ...state,
                            device.advName: !(state[device.advName] ?? false)
                          };
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ));
  }
}
