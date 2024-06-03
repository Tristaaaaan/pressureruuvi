import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:pressureruuvi/components/information_snackbar.dart';
import 'package:pressureruuvi/functions/csv_generator.dart';

class DeviceScreen extends StatefulWidget {
  final BluetoothDevice device;

  const DeviceScreen({super.key, required this.device});

  @override
  DeviceScreenState createState() => DeviceScreenState();
}

class DeviceScreenState extends State<DeviceScreen> {
  List<BluetoothService> services = [];
  List<StreamSubscription<List<int>>> subscriptions = [];
  List<PressureData> pressure = [];

  final _servicesStreamController = StreamController<List<BluetoothService>>();
  @override
  void initState() {
    super.initState();
    _discoverServices();
  }

  Future<void> _discoverServices() async {
    try {
      List<BluetoothService> services = await widget.device.discoverServices();

      _servicesStreamController.add(services);

      for (var service in services) {
        for (var characteristic in service.characteristics) {
          // Subscribe to notifications if the characteristic supports it
          if (characteristic.properties.notify) {
            await characteristic.setNotifyValue(true);
            final subscription = characteristic.onValueReceived.listen((value) {
              Uint8List receivedData = Uint8List.fromList(value);
              // Unpack the data (assuming it's a list of 31 floats and 1 integer)
              ByteData byteData = ByteData.sublistView(receivedData);
              List<double> dataAscii = [];
              for (int i = 0; i < 31; i++) {
                dataAscii
                    .add(byteData.getFloat32(i * 4, Endian.little).toDouble());
              }
              dataAscii
                  .add(byteData.getInt32(31 * 4, Endian.little).toDouble());

              print(
                  'Characteristic ${characteristic.uuid} value: $dataAscii'); // Handle notification value

              PressureData pressureData = PressureData(
                date: DateTime.now().microsecondsSinceEpoch,
                value: value,
              );
              setState(() {
                pressure.add(pressureData);
              });
            });

            subscriptions.add(subscription);
          }

          // Log the properties of each characteristic
          logCharacteristicProperties(characteristic);
        }
      }
    } catch (e) {
      print('Error discovering services: $e');
    }
  }

  void logCharacteristicProperties(BluetoothCharacteristic characteristic) {
    print('Characteristic ${characteristic.uuid}');
    print('Read: ${characteristic.properties.read}');
    print('Write: ${characteristic.properties.write}');
    print('Notify: ${characteristic.properties.notify}');
    // Add other properties as needed
  }

  @override
  void dispose() {
    // Cancel all subscriptions when the widget is disposed
    for (var subscription in subscriptions) {
      subscription.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.device.advName),
        actions: [
          TextButton(
            onPressed: () async {
              final data = await exportCSV(pressure);
              if (context.mounted) {
                informationSnackBar(context, Icons.info, data);
              }
            },
            child: const Text("Generate CSV"),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<BluetoothService>>(
              stream: _servicesStreamController.stream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                return ListView(
                  children: snapshot.data!.map((service) {
                    return ExpansionTile(
                      title: Text(service.uuid.toString()),
                      children: service.characteristics.map(
                        (characteristic) {
                          return ListTile(
                            title: Text(characteristic.uuid.toString()),
                          );
                        },
                      ).toList(),
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
