import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pressureruuvi/components/device_container.dart';
import 'package:pressureruuvi/components/device_loading.dart';
import 'package:pressureruuvi/functions/bluetooth_listener.dart';
import 'package:pressureruuvi/home/data_listen.dart';
import 'package:pressureruuvi/home/ruuvi_devices.dart';

final isRefreshingProvider = StateProvider<bool>((ref) => false);

class Home extends HookConsumerWidget {
  const Home({super.key});

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
    final connectedBluetoothDevices = ref.watch(connectedDevicesProvider(ref));

    return Scaffold(
      appBar: AppBar(
        title: const Text("PressureRuuvi"),
        actions: [
          TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const RuuviSensors(),
                  ),
                );
              },
              child: const Text("Observe")),
        ],
      ),
      body: ListView(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                child: Text(
                  "Available Bluetooth Devices",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
              ),
              // SCANNED DEVICES
              bluetoothDevices.when(
                data: (data) {
                  if (data.isEmpty) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 50),
                      height: 225,
                      width: double.infinity,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            height: 100,
                            width: 100,
                            child: SvgPicture.asset(
                              "assets/icons/bluetooth-slash_svgrepo.com.svg",
                            ),
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          Text(
                            "No bluetooth device found",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w300,
                                color: Colors.black.withOpacity(.25)),
                          ),
                        ],
                      ),
                    );
                  } else {
                    return Wrap(
                      children: data.map<Widget>((device) {
                        return BluetoothDeviceContainers(
                          device: device,
                          connected: false,
                        );
                      }).toList(),
                    );
                  }
                },
                error: (error, stackTrace) => Text(error.toString()),
                loading: () {
                  return const SizedBox(
                    height: 375,
                    child: BluetoothDevicesLoading(),
                  );
                },
              ),
              const SizedBox(
                height: 10,
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                child: Text(
                  "Connected Bluetooth Devices",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
              ),
              // CONNECTED DEVICES
              connectedBluetoothDevices.when(
                data: (data) {
                  if (data.isNotEmpty) {
                    return Wrap(
                      children: data.map<Widget>((device) {
                        return GestureDetector(
                          onTap: () async {
                            // final status = await checkPermissionStatus();
                            // if (status) {
                            // print(
                            //     "CONNECTED DEVICES INFO REDIRECTING TO DEVICE SCREEN");
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    DeviceScreen(device: device),
                              ),
                            );
                            // }
                          },
                          child: BluetoothDeviceContainers(
                            device: device,
                            connected: true,
                          ),
                        );
                      }).toList(),
                    );
                  } else {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 50),
                      height: 225,
                      width: double.infinity,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            height: 100,
                            width: 100,
                            child: SvgPicture.asset(
                              "assets/icons/bluetooth-slash_svgrepo.com.svg",
                            ),
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          Text(
                            "No bluetooth device connected",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w300,
                                color: Colors.black.withOpacity(.25)),
                          ),
                        ],
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
            ],
          ),
        ],
      ),
    );
  }
}
