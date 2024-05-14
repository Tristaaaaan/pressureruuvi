import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pressureruvvi/components/device_container.dart';
import 'package:pressureruvvi/components/device_loading.dart';
import 'package:pressureruvvi/functions/bluetooth_listener.dart';

final isRefreshingProvider = StateProvider<bool>((ref) => false);

class Home extends ConsumerWidget {
  const Home({super.key});

  // final BluetoothListener _bluetoothListener = BluetoothListener();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bluetoothDevices = ref.watch(bluetoothDevicesProvider);
    final connectedBluetoothDevices = ref.watch(connectedDevicesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("PressureRuuvi"),
      ),
      body: Center(
        child: Column(
          children: [
            bluetoothDevices.when(
              data: (data) {
                if (data.isEmpty) {
                  return const Center(child: Text("No device found"));
                } else {
                  return Expanded(
                    child: RefreshIndicator(
                      onRefresh: () async {
                        return await ref.refresh(bluetoothDevicesProvider);
                      },
                      child: ListView.separated(
                        separatorBuilder: (context, index) {
                          return const SizedBox(
                            height: 12,
                          );
                        },
                        itemCount: data.length,
                        itemBuilder: (context, index) {
                          final device = data[index];

                          return BluetoothDeviceContainer(
                            device: device,
                            connected: false,
                          );
                        },
                      ),
                    ),
                  );
                }
              },
              error: (error, stackTrace) => Text(error.toString()),
              loading: () {
                return const SizedBox(
                  height: 500,
                  child: BluetoothDevicesLoading(),
                );
              },
            ),
            connectedBluetoothDevices.when(
              data: (data) {
                if (data.isNotEmpty) {
                  return Expanded(
                    child: ListView.separated(
                      separatorBuilder: (context, index) {
                        return const SizedBox(
                          height: 5,
                        );
                      },
                      itemCount: data.length,
                      itemBuilder: (context, index) {
                        final device = data[index];

                        return BluetoothDeviceContainer(
                          device: device,
                          connected: true,
                        );
                      },
                    ),
                  );
                } else {
                  return const Center(child: Text("No device connected"));
                }
              },
              error: (error, stackTrace) => Text(error.toString()),
              loading: () {
                return const SizedBox(
                  height: 500,
                  child: BluetoothDevicesLoading(),
                );
              },
            ),
            // TextButton(
            //   onPressed: () async {
            //     await requestPermissions();

            //     final status = await checkPermissionStatus();
            //     print("DEVICES: $devices");
            //     if (status) {
            //       List<Map<String, dynamic>> associateList = [
            //         {
            //           "devices": devices,
            //         },
            //       ];

            //       exportCSV(associateList);
            //     } else {
            //       print("Permission not granted");
            //     }
            //   },
            //   child: const Text("Generate CSV"),
            // ),
          ],
        ),
      ),
    );
  }
}
