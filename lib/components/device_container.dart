import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pressureruvvi/functions/bluetooth_listener.dart';
import 'package:pressureruvvi/home/data_listen.dart';

class BluetoothDeviceContainer extends ConsumerWidget {
  final BluetoothDevice device;
  final bool connected;

  const BluetoothDeviceContainer({
    super.key,
    required this.device,
    required this.connected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IntrinsicHeight(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 15),
        padding: const EdgeInsets.symmetric(
          vertical: 10,
          horizontal: 10,
        ),
        decoration: BoxDecoration(
            border: Border.all(
              width: .5,
              color: const Color(0xFF313167),
            ),
            borderRadius: BorderRadius.circular(10)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  device.advName,
                  style: const TextStyle(
                      fontWeight: FontWeight.w400, fontSize: 16),
                ),
                const SizedBox(
                  height: 3,
                ),
                Text(
                  "${device.remoteId}",
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            connected
                ? InkWell(
                    onTap: () async {
                      print(
                          "CONNECTED DEVICES INFO REDIRECTING TO DEVICE SCREEN");
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DeviceScreen(device: device),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(10),
                    child: IntrinsicWidth(
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 4,
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: const Color(0x00645aa4),
                        ),
                        child: const Text(
                          'View',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  )
                : InkWell(
                    onTap: () async {
                      print(
                          " CONNECTING TO DEVICE: ${device.advName} (${device.remoteId})");
                      final isSuccess = await ref
                          .read(bluetoothProviders)
                          .connectToDevice(device);

                      if (isSuccess) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Device Connected"),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Device Connection Failed"),
                          ),
                        );
                      }
                    },
                    borderRadius: BorderRadius.circular(10),
                    child: IntrinsicWidth(
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 4,
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: const Color(0xFF313167)),
                        child: const Text(
                          'Connect',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
