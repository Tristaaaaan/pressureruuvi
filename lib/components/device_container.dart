import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class BluetoothDeviceContainer extends ConsumerWidget {
  final BluetoothDevice device;
  final bool connected;
  final void Function()? onTap;

  const BluetoothDeviceContainer({
    super.key,
    required this.device,
    required this.connected,
    required this.onTap,
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
            if (!connected)
              InkWell(
                onTap: onTap,
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
                      color: device.isDisconnected
                          ? const Color(0xFF313167)
                          : const Color(0x00645aa4),
                    ),
                    child: device.isDisconnected
                        ? const Text(
                            'Connect',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          )
                        : const Text(
                            'View',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                  ),
                ),
              )
          ],
        ),
      ),
    );
  }
}
