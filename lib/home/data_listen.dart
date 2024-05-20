import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class DeviceScreen extends StatelessWidget {
  final BluetoothDevice device;

  const DeviceScreen({super.key, required this.device});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(device.platformName),
      ),
      body: FutureBuilder<List<BluetoothService>>(
        future: device.discoverServices(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          return ListView(
            children: snapshot.data!.map((service) {
              return ListTile(
                title: Text(service.uuid.toString()),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: service.characteristics.map((characteristic) {
                    return ListTile(
                      title: Text(characteristic.uuid.toString()),
                      trailing: IconButton(
                        icon: const Icon(Icons.download),
                        onPressed: () async {
                          if (characteristic.properties.read) {
                            List<int> value = await characteristic.read();
                            print(
                                'Characteristic ${characteristic.uuid} value: $value');
                            // You can also update the UI or do something with the value here
                          }
                        },
                      ),
                    );
                  }).toList(),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
