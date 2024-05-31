import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pressureruvvi/components/device_container.dart';
import 'package:pressureruvvi/components/device_loading.dart';
import 'package:pressureruvvi/functions/bluetooth_listener.dart';
import 'package:pressureruvvi/home/data_listen.dart';

final isRefreshingProvider = StateProvider<bool>((ref) => false);

class Home extends HookConsumerWidget {
  const Home({super.key});

  // final BluetoothListener _bluetoothListener = BluetoothListener();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Future<void> requestPermissions() async {
      await requestPermissions();
    }

    useEffect(() {
      requestPermissions();
      return;
    }, []);

    final bluetoothDevices = ref.watch(bluetoothDevicesProvider);
    final connectedBluetoothDevices = ref.watch(connectedDevicesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("PressureRuuvi"),
      ),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Bluetooth Devices",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            // SCANNED DEVICES
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
            const SizedBox(
              height: 10,
            ),
            const Text(
              "Connected Bluetooth Devices",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            // CONNECTED DEVICES
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

                        return GestureDetector(
                          onTap: () async {
                            // final status = await checkPermissionStatus();
                            // if (status) {
                            print(
                                "CONNECTED DEVICES INFO REDIRECTING TO DEVICE SCREEN");
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    DeviceScreen(device: device),
                              ),
                            );
                            // }
                          },
                          child: BluetoothDeviceContainer(
                            device: device,
                            connected: true,
                          ),
                        );
                      },
                    ),
                  );
                } else {
                  return const Center(child: Text("No device connected"));
                }
              },
              error: (error, stackTrace) => Text(
                error.toString(),
              ),
              loading: () {
                return const SizedBox(
                  height: 500,
                  child: BluetoothDevicesLoading(),
                );
              },
            ),
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
