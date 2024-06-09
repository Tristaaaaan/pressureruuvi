import 'dart:async';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:pressureruuvi/components/information_snackbar.dart';
import 'package:pressureruuvi/components/rounded_button.dart';
import 'package:pressureruuvi/functions/csv_generator.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';

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
  late StopWatchTimer _stopWatchTimer;

  late Timer _timer;
  Color _currentColor = Colors.black;
  final Random _random = Random();

  final _servicesStreamController = StreamController<List<BluetoothService>>();

  bool _isColorChangeStarted = false;
  bool _isTimerStarted = false;

  @override
  void initState() {
    super.initState();
    _stopWatchTimer = StopWatchTimer();
  }

  void _startTimer() {
    print("Starting timer");
    _stopWatchTimer.onStartTimer();
  }

  void _stopTimer() {
    print("Stopping timer");
    _stopWatchTimer.onStopTimer();
  }

  void _resetTimer() {
    print("Resetting timer");
    _stopWatchTimer.onResetTimer();
  }

  void _startColorChangeTimer() {
    print("Starting color change");
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _currentColor = Color.fromARGB(
          255,
          _random.nextInt(256),
          _random.nextInt(256),
          _random.nextInt(256),
        );
      });
    });
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

  void _stopServiceDiscovery() {
    for (var subscription in subscriptions) {
      subscription.cancel();
    }
    subscriptions.clear();
  }

  @override
  void dispose() async {
    // Cancel all subscriptions when the widget is disposed
    _timer.cancel();
    for (var subscription in subscriptions) {
      subscription.cancel();
    }
    super.dispose();
    await _stopWatchTimer.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.device.advName), actions: [
        TextButton(
          onPressed: () async {
            final data = await exportCSV(
              pressure,
              widget.device.remoteId.toString(),
              widget.device.advName,
            );
            if (context.mounted) {
              informationSnackBar(
                  context, Icons.info, "Exported successfully.");
            }
            _resetTimer();

            pressure.clear();
          },
          child: const Text(
            "Export CSV",
            style: TextStyle(
              color: Colors.white,
            ),
          ),
        ),
      ]),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "Pressure Reading",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 25,
            ),
          ),
          const SizedBox(
            height: 25,
          ),
          const Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 25,
            ),
            child: Text(
              "Make sure the connection is not interrupted while data gathering  to prevent data loss",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color.fromARGB(255, 216, 216, 216),
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(
            height: 25,
          ),
          if (_isColorChangeStarted)
            LoadingAnimationWidget.stretchedDots(
                color: _currentColor, size: 100),
          const SizedBox(
            height: 25,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Duration",
                    style: TextStyle(
                      color: Color.fromARGB(255, 82, 82, 82),
                      fontSize: 12,
                    )),
                const SizedBox(
                  width: 10,
                ),
                StreamBuilder<int>(
                  stream: _stopWatchTimer.rawTime,
                  initialData: 0,
                  builder: (context, snap) {
                    final value = snap.data;
                    final displayTime = StopWatchTimer.getDisplayTime(value!);
                    return Column(
                      children: <Widget>[
                        Text(
                          displayTime,
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Data Length",
                    style: TextStyle(
                        color: Color.fromARGB(255, 82, 82, 82), fontSize: 12)),
                const SizedBox(
                  width: 10,
                ),
                Text(
                  pressure.length.toString(),
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 25,
          ),
          RoundedButton(
            text: !_isTimerStarted ? "Start" : "Stop",
            onTap: pressure.isEmpty
                ? () {
                    _startTimer();
                    _isColorChangeStarted = true;
                    _isTimerStarted = true;
                    _startColorChangeTimer();
                    _discoverServices();
                  }
                : () async {
                    _stopServiceDiscovery();
                    _stopTimer();
                    _isTimerStarted = false;
                    _isColorChangeStarted = false;
                  },
            margin: const EdgeInsets.symmetric(horizontal: 25),
            color: const Color.fromARGB(255, 105, 86, 250),
            textcolor: Theme.of(context).colorScheme.background,
          ),
        ],
      ),
    );
  }
}
