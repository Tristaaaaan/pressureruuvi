// import 'package:flutter/material.dart';
// import 'package:flutter_blue_plus/flutter_blue_plus.dart';

// class DeviceScreen extends StatelessWidget {
//   final BluetoothDevice device;

//   const DeviceScreen({super.key, required this.device});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(device.platformName),
//       ),
//       body: FutureBuilder<List<BluetoothService>>(
//         future: device.discoverServices(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }

//           if (snapshot.hasError) {
//             return Center(child: Text('Error: ${snapshot.error}'));
//           }

//           return ListView(
//             children: snapshot.data!.map((service) {
//               return ListTile(
//                 title: Text(service.uuid.toString()),
//                 subtitle: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: service.characteristics.map((characteristic) {
//                     return ListTile(
//                       title: Text(characteristic.uuid.toString()),
//                       trailing: IconButton(
//                         icon: const Icon(Icons.download),
//                         onPressed: () async {
//                           if (characteristic.properties.read) {
//                             List<int> value = await characteristic.read();
//                             print(
//                                 'Characteristic ${characteristic.uuid} value: $value');
//                             // You can also update the UI or do something with the value here
//                           }
//                         },
//                       ),
//                     );
//                   }).toList(),
//                 ),
//               );
//             }).toList(),
//           );
//         },
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

// class SensorData {
//   final int timestamp;
//   final double pressure1;
//   final double pressure2;
//   final double pressure3;
//   final int pocketNumber;

//   SensorData(this.timestamp, this.pressure1, this.pressure2, this.pressure3,
//       this.pocketNumber);
// }

// class DeviceScreen extends StatefulWidget {
//   final BluetoothDevice device;

//   const DeviceScreen({super.key, required this.device});

//   @override
//   _DeviceScreenState createState() => _DeviceScreenState();
// }

// class _DeviceScreenState extends State<DeviceScreen> {
//   List<SensorData> sensorDataList = [];

//   @override
//   void initState() {
//     super.initState();
//     widget.device.connect();
//     fetchSensorData();
//   }

//   @override
//   void dispose() {
//     widget.device.disconnect();
//     super.dispose();
//   }

//   void fetchSensorData() async {
//     List<BluetoothService> services = await widget.device.discoverServices();
//     for (BluetoothService service in services) {
//       for (BluetoothCharacteristic characteristic in service.characteristics) {
//         if (characteristic.uuid.toString() ==
//             '6E400003-B5A3-F393-E0A9-E50E24DCCA9E') {
//           await characteristic.setNotifyValue(true);
//           characteristic.lastValueStream.listen((value) {
//             String dataString = String.fromCharCodes(value);
//             SensorData sensorData = parseSensorData(dataString);
//             setState(() {
//               sensorDataList.add(sensorData);
//             });
//           });
//         }
//       }
//     }
//   }

//   SensorData parseSensorData(String dataString) {
//     List<String> parts = dataString.split('\t');
//     int timestamp = int.parse(parts[0]);
//     double pressure1 = double.parse(parts[1]);
//     double pressure2 = double.parse(parts[2]);
//     double pressure3 = double.parse(parts[3]);
//     int pocketNumber = int.parse(parts[4]);
//     return SensorData(timestamp, pressure1, pressure2, pressure3, pocketNumber);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(widget.device.advName),
//       ),
//       body: sensorDataList.isEmpty
//           ? const Center(child: CircularProgressIndicator())
//           : ListView.builder(
//               itemCount: sensorDataList.length,
//               itemBuilder: (context, index) {
//                 final sensorData = sensorDataList[index];
//                 return ListTile(
//                   title: Text('Timestamp: ${sensorData.timestamp}'),
//                   subtitle: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text('Pressure 1: ${sensorData.pressure1}'),
//                       Text('Pressure 2: ${sensorData.pressure2}'),
//                       Text('Pressure 3: ${sensorData.pressure3}'),
//                       Text('Pocket Number: ${sensorData.pocketNumber}'),
//                     ],
//                   ),
//                 );
//               },
//             ),
//     );
//   }
// }

class DeviceScreen extends StatefulWidget {
  final BluetoothDevice device;

  const DeviceScreen({super.key, required this.device});

  @override
  _DeviceScreenState createState() => _DeviceScreenState();
}

class _DeviceScreenState extends State<DeviceScreen> {
  List<BluetoothService> services = [];
  BluetoothCharacteristic? pressureCharacteristic;

  @override
  void initState() {
    super.initState();
    _discoverServices();
  }

  Future<void> _discoverServices() async {
    List<BluetoothService> services = await widget.device.discoverServices();
    setState(() {
      this.services = services;
    });

    // Assuming the pressure characteristic UUID is known
    String pressureCharacteristicUUID = "6E400003-B5A3-F393-E0A9-E50E24DCCA9E";

    for (var service in services) {
      for (var characteristic in service.characteristics) {
        if (characteristic.uuid.toString() == pressureCharacteristicUUID) {
          setState(() {
            pressureCharacteristic = characteristic;
          });
          _startPressureNotifications();
          break;
        }
      }
    }
  }

  void _startPressureNotifications() async {
    if (pressureCharacteristic != null &&
        pressureCharacteristic!.properties.notify) {
      await pressureCharacteristic!.setNotifyValue(true);
      pressureCharacteristic!.lastValueStream.listen((value) {
        // Handle the pressure value
        print('Pressure value: $value');
        // Optionally update the UI with the pressure value
      });
    } else {
      print('Pressure characteristic not found or notifications not supported');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.device.advName),
      ),
      body: services.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: services.map((service) {
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
            ),
    );
  }
}
