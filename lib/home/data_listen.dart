import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:pressureruvvi/functions/csv_generator.dart';

class DeviceScreen extends StatefulWidget {
  final BluetoothDevice device;

  const DeviceScreen({super.key, required this.device});

  @override
  DeviceScreenState createState() => DeviceScreenState();
}

class DeviceScreenState extends State<DeviceScreen> {
  List<BluetoothService> services = [];
  // Map<Guid, List<int>> characteristicValues = {};
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
      // setState(() {
      //   this.services = services;
      // });

      for (var service in services) {
        for (var characteristic in service.characteristics) {
          // Subscribe to notifications if the characteristic supports it
          if (characteristic.properties.notify) {
            await characteristic.setNotifyValue(true);
            final subscription = characteristic.onValueReceived.listen((value) {
              // setState(() {
              //   characteristicValues[characteristic.uuid] = value;
              // });
              // List<int?> pressureReading = [];
              // int offset = 50000;
              // // CALCULATE

              // for (int i = 0; i < value.length - 4; i += 4) {
              //   // Combine two bytes to form a 16-bit unsigned integer (little-endian)
              //   int pressureRaw = value[i] + (value[i + 1] << 8);
              //   int? pressure;

              //   if (pressureRaw == 0xFFFF) {
              //     // Indicate invalid or unavailable data
              //     pressure = null;
              //   } else {
              //     pressure = pressureRaw + offset;
              //   }

              //   pressureReading.add(pressure);
              // }

              // List to store pressure readings
              List<int> pressureReadings = [];
              if (value.length != 128) {
                throw ArgumentError("Invalid data length, expected 128 bytes");
              }

              // Convert the list of integers to bytes
              List<int> data = value;

              // Define the number of readings and size of each chunk in bytes
              int numReadings = 31;
              int chunkSize = 4;

              // Iterate over the data to extract each pressure reading
              for (int i = 0; i < numReadings; i++) {
                int startIndex = i * chunkSize;
                List<int> pressureBytes =
                    data.sublist(startIndex + 2, startIndex + 4);

                // Convert bytes to integer (assuming big-endian format)
                int pressure = 0;
                for (int byte in pressureBytes) {
                  pressure = (pressure << 8) | byte;
                }

                // Adjust pressure value according to the sensor's encoding formula, if necessary
                int pressureAdjusted = pressure + 50000; // Example adjustment

                pressureReadings.add(pressureAdjusted);
              }

              print(
                  'Characteristic ${characteristic.uuid} value: $pressureReadings'); // Handle notification value

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
              // final status = await checkPermissionStatus();

              // if (status) {
              await exportCSV(pressure);
              // } else {
              //   print("Permission not granted");
              // }
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
                            // subtitle: Text(
                            //   'Value: ${characteristicValues[characteristic.uuid]?.toString() ?? 'Waiting for notification...'}',
                            // ),
                            // trailing: characteristic.properties.read
                            //     ? IconButton(
                            //         icon: const Icon(Icons.download),
                            //         onPressed: () async {
                            //           try {
                            //             List<int> value =
                            //                 await characteristic.read();
                            //             print(
                            //                 'Characteristic ${characteristic.uuid} value: $value');
                            //             setState(() {
                            //               characteristicValues[
                            //                       characteristic.uuid] =
                            //                   value; // Update with the read value
                            //             });
                            //           } catch (e) {
                            //             print(
                            //                 'Error reading characteristic: $e');
                            //           }
                            //         },
                            //       )
                            //     : null,
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


// class DeviceScreen extends StatefulWidget {
//   final BluetoothDevice device;

//   const DeviceScreen({super.key, required this.device});

//   @override
//   _DeviceScreenState createState() => _DeviceScreenState();
// }

// class _DeviceScreenState extends State<DeviceScreen> {
//   List<BluetoothService> services = [];
//   Map<Guid, List<int>> characteristicValues = {};
//   List<StreamSubscription<List<int>>> subscriptions = [];

//   @override
//   void initState() {
//     super.initState();
//     _discoverServices();
//   }

//   Future<void> _discoverServices() async {
//     try {
//       List<BluetoothService> services = await widget.device.discoverServices();
//       setState(() {
//         this.services = services;
//       });

//       for (var service in services) {
//         for (var characteristic in service.characteristics) {
//           // Subscribe to notifications if the characteristic supports it
//           if (characteristic.properties.notify) {
//             await characteristic.setNotifyValue(true);
//             final subscription = characteristic.onValueReceived.listen((value) {
//               setState(() {
//                 characteristicValues[characteristic.uuid] = value;
//               });
//               print(
//                   'Characteristic ${characteristic.uuid} value: $value'); // Handle notification value
//             });

//             subscriptions.add(subscription);
//           }

//           // Log the properties of each characteristic
//           logCharacteristicProperties(characteristic);
//         }
//       }
//     } catch (e) {
//       print('Error discovering services: $e');
//     }
//   }

//   void logCharacteristicProperties(BluetoothCharacteristic characteristic) {
//     print('Characteristic ${characteristic.uuid}');
//     print('Read: ${characteristic.properties.read}');
//     print('Write: ${characteristic.properties.write}');
//     print('Notify: ${characteristic.properties.notify}');
//     // Add other properties as needed
//   }

//   @override
//   void dispose() {
//     // Cancel all subscriptions when the widget is disposed
//     for (var subscription in subscriptions) {
//       subscription.cancel();
//     }
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(widget.device.advName),
//       ),
//       body: FutureBuilder<List<BluetoothService>>(
//         future: widget.device.discoverServices(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }

//           if (snapshot.hasError) {
//             return Center(child: Text('Error: ${snapshot.error}'));
//           }

//           return ListView(
//             children: snapshot.data!.map((service) {
//               return ExpansionTile(
//                 title: Text(service.uuid.toString()),
//                 children: service.characteristics.map((characteristic) {
//                   return ListTile(
//                     title: Text(characteristic.uuid.toString()),
//                     subtitle: Text(
//                       'Value: ${characteristicValues[characteristic.uuid]?.toString() ?? 'Waiting for notification...'}',
//                     ),
//                     trailing: characteristic.properties.read
//                         ? IconButton(
//                             icon: const Icon(Icons.download),
//                             onPressed: () async {
//                               try {
//                                 List<int> value = await characteristic.read();
//                                 print(
//                                     'Characteristic ${characteristic.uuid} value: $value');
//                                 setState(() {
//                                   characteristicValues[characteristic.uuid] =
//                                       value; // Update with the read value
//                                 });
//                               } catch (e) {
//                                 print('Error reading characteristic: $e');
//                               }
//                             },
//                           )
//                         : null,
//                   );
//                 }).toList(),
//               );
//             }).toList(),
//           );
//         },
//       ),
//     );
//   }
// }
