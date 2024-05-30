import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

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

// class DeviceScreen extends StatefulWidget {
//   final BluetoothDevice device;

//   const DeviceScreen({super.key, required this.device});

//   @override
//   _DeviceScreenState createState() => _DeviceScreenState();
// }

// class _DeviceScreenState extends State<DeviceScreen> {
//   List<BluetoothService> services = [];
//   BluetoothCharacteristic? pressureCharacteristic;

//   @override
//   void initState() {
//     super.initState();
//     _discoverServices();
//   }

//   Future<void> _discoverServices() async {
//     List<BluetoothService> services = await widget.device.discoverServices();
//     setState(() {
//       this.services = services;
//     });

//     String pressureCharacteristicUUID =
//         "6E400003-B5A3-F393-E0A9-E50E24DCCA9E"; // Update this if needed

//     for (var service in services) {
//       for (var characteristic in service.characteristics) {
//         if (characteristic.uuid.toString() == pressureCharacteristicUUID) {
//           setState(() {
//             pressureCharacteristic = characteristic;
//           });
//           await _startPressureNotifications();
//           break;
//         }
//       }
//     }

//     if (pressureCharacteristic == null) {
//       print('Pressure characteristic not found');
//     }
//   }

//   Future<void> _startPressureNotifications() async {
//     if (pressureCharacteristic != null &&
//         pressureCharacteristic!.properties.notify) {
//       await pressureCharacteristic!.setNotifyValue(true);
//       pressureCharacteristic!.lastValueStream.listen((value) {
//         // Parse and display the pressure value
//         _handlePressureValue(value);
//       });
//     } else {
//       print('Pressure characteristic not found or notifications not supported');
//     }
//   }

//   void _handlePressureValue(List<int> value) {
//     // Assuming the pressure is in bytes 5 and 6 (as a 16-bit unsigned integer in pascals)
//     if (value.length >= 6) {
//       int pressure = (value[4] << 8) | value[5];
//       double pressureHpa = pressure / 100.0; // Convert to hPa if necessary

//       print('Pressure value: $pressureHpa hPa');
//     } else {
//       print('Unexpected pressure value length: ${value.length}');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(widget.device.advName), // Change from advName to name
//       ),
//       body: ListView.builder(
//         itemCount: services.length,
//         itemBuilder: (context, index) {
//           var service = services[index];
//           return ListTile(
//             title: Text(service.uuid.toString()),
//           );
//         },
//       ),
//     );
//   }
// }

// class DeviceScreen extends StatefulWidget {
//   final BluetoothDevice device;

//   const DeviceScreen({super.key, required this.device});

//   @override
//   _DeviceScreenState createState() => _DeviceScreenState();
// }

// class _DeviceScreenState extends State<DeviceScreen> {
//   List<BluetoothService> services = [];
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
//                     subtitle: FutureBuilder<List<int>>(
//                       future: _readCharacteristic(characteristic),
//                       builder: (context, snapshot) {
//                         if (snapshot.connectionState ==
//                             ConnectionState.waiting) {
//                           return const Text('Reading...');
//                         }

//                         if (snapshot.hasError) {
//                           return Text('Error: ${snapshot.error}');
//                         }

//                         final value = snapshot.data;
//                         return Text('Value: ${value.toString()}');
//                       },
//                     ),
//                     trailing: IconButton(
//                       icon: const Icon(Icons.download),
//                       onPressed: () async {
//                         if (characteristic.properties.read) {
//                           try {
//                             List<int> value = await characteristic.read();
//                             print(
//                                 'Characteristic ${characteristic.uuid} value: $value');
//                             setState(
//                                 () {}); // Force rebuild to show the updated value
//                           } catch (e) {
//                             print('Error reading characteristic: $e');
//                           }
//                         } else {
//                           print(
//                               'Characteristic ${characteristic.uuid} does not have read permission');
//                         }
//                       },
//                     ),
//                   );
//                 }).toList(),
//               );
//             }).toList(),
//           );
//         },
//       ),
//     );
//   }

//   Future<List<int>> _readCharacteristic(
//       BluetoothCharacteristic characteristic) async {
//     if (characteristic.properties.read) {
//       try {
//         return await characteristic.read();
//       } catch (e) {
//         print('Error reading characteristic: $e');
//         return [];
//       }
//     } else {
//       print(
//           'Characteristic ${characteristic.uuid} does not have read permission');
//       return [];
//     }
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
  Map<Guid, List<int>> characteristicValues = {};
  List<StreamSubscription<List<int>>> subscriptions = [];

  @override
  void initState() {
    super.initState();
    _discoverServices();
  }

  Future<void> _discoverServices() async {
    try {
      List<BluetoothService> services = await widget.device.discoverServices();
      setState(() {
        this.services = services;
      });

      for (var service in services) {
        for (var characteristic in service.characteristics) {
          // Subscribe to notifications if the characteristic supports it
          if (characteristic.properties.notify) {
            await characteristic.setNotifyValue(true);
            final subscription = characteristic.onValueReceived.listen((value) {
              setState(() {
                characteristicValues[characteristic.uuid] = value;
              });
              print(
                  'Characteristic ${characteristic.uuid} value: $value'); // Handle notification value
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
      ),
      body: FutureBuilder<List<BluetoothService>>(
        future: widget.device.discoverServices(),
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
                children: service.characteristics.map((characteristic) {
                  return ListTile(
                    title: Text(characteristic.uuid.toString()),
                    subtitle: Text(
                      'Value: ${characteristicValues[characteristic.uuid]?.toString() ?? 'Waiting for notification...'}',
                    ),
                    trailing: characteristic.properties.read
                        ? IconButton(
                            icon: const Icon(Icons.download),
                            onPressed: () async {
                              try {
                                List<int> value = await characteristic.read();
                                print(
                                    'Characteristic ${characteristic.uuid} value: $value');
                                setState(() {
                                  characteristicValues[characteristic.uuid] =
                                      value; // Update with the read value
                                });
                              } catch (e) {
                                print('Error reading characteristic: $e');
                              }
                            },
                          )
                        : null,
                  );
                }).toList(),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
