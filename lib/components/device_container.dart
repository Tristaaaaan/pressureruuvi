import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pressureruuvi/components/information_snackbar.dart';
import 'package:pressureruuvi/functions/bluetooth_listener.dart';
import 'package:pressureruuvi/services/state_provider.dart';

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
    final isLoading = ref.watch(isLoadingProvider);
    return IntrinsicHeight(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
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
                  device.remoteId.toString(),
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            connected
                ? InkWell(
                    radius: 10,
                    onTap: () async {
                      isLoading
                          ? () {}
                          : () async {
                              final loadingNotifier =
                                  ref.read(isLoadingProvider.notifier);

                              loadingNotifier.update((state) => true);
                              final isSuccess = await ref
                                  .read(bluetoothProviders)
                                  .disconnectToDevice(device);

                              loadingNotifier.update((state) => false);
                              if (isSuccess) {
                                if (context.mounted) {
                                  informationSnackBar(context, Icons.check,
                                      "Device disconnected");
                                }
                              } else {
                                if (context.mounted) {
                                  informationSnackBar(context, Icons.warning,
                                      "Failed to disconnect");
                                }
                              }
                            };
                    },
                    borderRadius: BorderRadius.circular(10),
                    child: IntrinsicWidth(
                      child: Container(
                        width: 80,
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
                            color: const Color.fromARGB(255, 123, 123, 204)),
                        child: const Text(
                          textAlign: TextAlign.center,
                          'Disconnect',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  )
                : InkWell(
                    radius: 10,
                    onTap: isLoading
                        ? () {}
                        : () async {
                            final loadingNotifier =
                                ref.read(isLoadingProvider.notifier);

                            loadingNotifier.update((state) => true);
                            final isSuccess = await ref
                                .read(bluetoothProviders)
                                .connectToDevice(device);

                            loadingNotifier.update((state) => false);
                            if (isSuccess) {
                              if (context.mounted) {
                                informationSnackBar(
                                    context, Icons.check, "Device connected");
                              }
                            } else {
                              if (context.mounted) {
                                informationSnackBar(context, Icons.warning,
                                    "Failed to connect");
                              }
                            }
                          },
                    borderRadius: BorderRadius.circular(10),
                    child: IntrinsicWidth(
                      child: Container(
                        width: 80,
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
