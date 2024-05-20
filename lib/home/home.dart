import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pressureruvvi/components/device_container.dart';
import 'package:pressureruvvi/components/device_loading.dart';
import 'package:pressureruvvi/functions/bluetooth_listener.dart';
import 'package:pressureruvvi/home/data_listen.dart';

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
                          onTap: () async {
                            final isSuccess = await ref
                                .read(bluetoothProviders)
                                .connectToDevice(device);

                            if (isSuccess) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Device Connected"),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Device Connection Failed"),
                                ),
                              );
                            }
                          },
                        );
                      },
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
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  DeviceScreen(device: device),
                            ),
                          ),
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

            SizedBox(
              height: 100,
              child: IconButton(
                onPressed: () {
                  List<BluetoothDevice> devs = FlutterBluePlus.connectedDevices;
                  for (var devices in devs) {
                    print(
                        "CONNECTED: ${devices.advName} (${devices.remoteId})");
                  }
                },
                icon: const Text("Check Connected Devices"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
