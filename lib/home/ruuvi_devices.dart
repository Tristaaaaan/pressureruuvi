import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pressureruuvi/components/sensor_container.dart';
import 'package:pressureruuvi/functions/gather_data.dart';
import 'package:pressureruuvi/services/state_provider.dart';

class RuuviSensors extends ConsumerWidget {
  const RuuviSensors({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final devices = ref.watch(devicesProvider);
    final devicesList = ref.watch(devicesListProvider);
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
                return RuuviDevicesContainer(
                  device: device,
                  onTap: () {
                    if (!devicesList.contains(device.advName)) {
                      discoverServices(device, ref, context);
                      ref
                          .read(devicesListProvider.notifier)
                          .update((state) => [...state, device.advName]);
                    } else {
                      ref.read(devicesListProvider.notifier).update(
                            (state) => state
                                .where((deviceName) =>
                                    deviceName != device.advName)
                                .toList(),
                          );

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
      ),
    );
  }
}
