import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pressureruuvi/components/device_container.dart';
import 'package:pressureruuvi/components/device_loading.dart';
import 'package:pressureruuvi/functions/bluetooth_listener.dart';
import 'package:pressureruuvi/home/data_listen.dart';

final isRefreshingProvider = StateProvider<bool>((ref) => false);

// Bluetooth Device Placeholder
// class BluetoothDeviceItem {
//   String advName;
//   String remoteId;
//   bool connected;
//   BluetoothDeviceItem({
//     required this.advName,
//     required this.remoteId,
//     required this.connected,
//   });
// }

// Future<List<BluetoothDeviceItem>> bluetoothItem() async {
//   await Future.delayed(const Duration(seconds: 10));
//   List<BluetoothDeviceItem> devices = [
//     BluetoothDeviceItem(advName: "Ruuvi 1", remoteId: "321", connected: true),
//     BluetoothDeviceItem(advName: "Ruuvi 2", remoteId: "143", connected: true),
//     BluetoothDeviceItem(advName: "Ruuvi 3", remoteId: "312", connected: false),
//     BluetoothDeviceItem(advName: "Ruuvi 4", remoteId: "43d", connected: false),
//     BluetoothDeviceItem(advName: "Ruuvi 5", remoteId: "1d3", connected: false),
//     BluetoothDeviceItem(advName: "Ruuvi 6", remoteId: "r33", connected: false),
//     BluetoothDeviceItem(advName: "Ruuvi 7", remoteId: "23d", connected: true),
//     BluetoothDeviceItem(advName: "Ruuvi 8", remoteId: "gf3", connected: false),
//   ];
//   return devices;
// }

// final bluetoothItemsProvider =
//     FutureProvider<List<BluetoothDeviceItem>>((ref) async {
//   return bluetoothItem();
// });
// ORIGINAL CODE

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
    // final bluetoothItems = ref.watch(bluetoothItemsProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text("PressureRuuvi"),
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
                  style: TextStyle(fontWeight: FontWeight.bold),
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
                        return BluetoothDeviceContainer(
                          device: device,
                          connected: false,
                        );
                      }).toList(),
                    );

                    // ListView.separated(
                    //   separatorBuilder: (context, index) {
                    //     return const SizedBox(
                    //       height: 12,
                    //     );
                    //   },
                    //   itemCount: data.length,
                    //   itemBuilder: (context, index) {
                    //     final device = data[index];

                    //     return BluetoothDeviceContainer(
                    //       device: device,
                    //       connected: false,
                    //     );
                    //   },
                    // );
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
                  style: TextStyle(fontWeight: FontWeight.bold),
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
                          child: BluetoothDeviceContainer(
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
                // ListView.separated(
                //   separatorBuilder: (context, index) {
                //     return const SizedBox(
                //       height: 5,
                //     );
                //   },
                //   itemCount: data.length,
                //   itemBuilder: (context, index) {
                //     final device = data[index];

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
