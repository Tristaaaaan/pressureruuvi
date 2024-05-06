import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:pressureruvvi/functions/bluetooth_listener.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final BluetoothListener _bluetoothListener = BluetoothListener();
  List<BluetoothDevice>? devices;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Bluetooth"),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          children: [
            TextButton(
              onPressed: () async {
                final scannedDevices =
                    await _bluetoothListener.startBluetoothScan();
                setState(() {
                  devices = scannedDevices;
                });
                print("devices: $devices");
              },
              child: const Text("Start Bluetooth Scan"),
            ),
            if (devices != null)
              Expanded(
                child: ListView.separated(
                  separatorBuilder: (context, index) {
                    return const Divider();
                  },
                  itemCount: devices!.length,
                  itemBuilder: (context, index) {
                    final device = devices![index];
                    return IntrinsicHeight(
                      child: Container(
                        margin: const EdgeInsets.all(20),
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 20),
                        child: Column(
                          children: [
                            Text(device.platformName),
                            Text("${device.remoteId}"),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              )
          ],
        ),
      ),
    );
  }
}
