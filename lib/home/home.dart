import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pressureruvvi/functions/bluetooth_listener.dart';

class Home extends ConsumerWidget {
  const Home({super.key});

  // final BluetoothListener _bluetoothListener = BluetoothListener();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bluetoothDevices = ref.watch(bluetoothDevicesProvider);

    return RefreshIndicator(
      onRefresh: () async {
        // Perform the refresh operation
        return ref.refresh(bluetoothDevicesProvider);
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Bluetooth"),
          centerTitle: true,
        ),
        body: Center(
          child: Column(
            children: [
              bluetoothDevices.when(
                data: (data) {
                  return Expanded(
                    child: ListView.separated(
                      separatorBuilder: (context, index) {
                        return const Divider();
                      },
                      itemCount: data.length,
                      itemBuilder: (context, index) {
                        final device = data[index];
                        return IntrinsicHeight(
                          child: Container(
                            margin: const EdgeInsets.all(10),
                            padding: const EdgeInsets.symmetric(
                                vertical: 5, horizontal: 5),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  children: [
                                    Text(device.advName),
                                    Text("${device.remoteId}"),
                                  ],
                                ),
                                InkWell(
                                  onTap: () async {
                                    final isSuccess = await ref
                                        .read(bluetoothProviders)
                                        .connectToDevice(device);

                                    if (isSuccess) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text("Device Connected"),
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
                                        color: device.isDisconnected
                                            ? Colors.blueAccent
                                            : Colors.redAccent,
                                      ),
                                      child: device.isDisconnected
                                          ? const Text(
                                              'Connect',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 16),
                                            )
                                          : const Text(
                                              'Disconnect',
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
                      },
                    ),
                  );
                },
                error: (error, stackTrace) => Text(error.toString()),
                loading: () => const CircularProgressIndicator(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
