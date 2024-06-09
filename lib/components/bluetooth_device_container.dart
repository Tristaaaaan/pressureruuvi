import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:pressureruuvi/components/information_snackbar.dart';
import 'package:pressureruuvi/functions/csv_generator.dart';
import 'package:pressureruuvi/functions/gather_data.dart';
import 'package:pressureruuvi/home/ruuvi_devices.dart';
import 'package:pressureruuvi/services/state_provider.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';

class BluetoothDeviceContainer extends ConsumerWidget {
  final void Function() onTap;
  final BluetoothDevice device;

  BluetoothDeviceContainer({
    super.key,
    required this.onTap,
    required this.device,
  });
  final StopWatchTimer stopWatchTimer = StopWatchTimer();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final devicesList = ref.watch(devicesListProvider);
    final clickedIcons = ref.watch(clickedIconProvider);
    final isIconClicked = clickedIcons[device.advName] ?? false;
    final devicesDataInfo = ref.watch(devicesDataProvider);
    final stopWatchTimer =
        ref.watch(stopWatchTimerProvider(device.advName).notifier).state;

    if (isIconClicked) {
      stopWatchTimer.onStartTimer();
    } else {
      stopWatchTimer.onResetTimer();
    }

    return IntrinsicHeight(
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(
              color: isIconClicked ? Colors.red : Colors.grey,
              // Color of the border
              width: 7, // Width of the border
            ),
          ),
          borderRadius: const BorderRadius.all(
            Radius.circular(15),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(children: [
                  InkWell(
                    borderRadius: BorderRadius.circular(5),
                    onTap: onTap,
                    child: IntrinsicWidth(
                      child: isIconClicked
                          ? Icon(
                              Icons.stop,
                              color: isIconClicked ? Colors.red : Colors.grey,
                            )
                          : Icon(
                              Icons.play_arrow,
                              color: isIconClicked ? Colors.red : Colors.grey,
                            ),
                    ),
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  Text(
                    device.advName,
                    style: const TextStyle(fontSize: 20),
                  ),
                ]),
                IconButton(
                  onPressed: () async {
                    if (devicesDataInfo[device.advName] == null) {
                      print("Devices data info is null");
                    } else {
                      print(device.advName);
                      print(
                          "Length: ${devicesDataInfo[device.advName]!.length.toString()}");
                      List<PressureData> flattenedList =
                          devicesDataInfo[device.advName]!
                              .expand((i) => i)
                              .toList();

                      if (devicesList.isEmpty) {
                        final bool success = await exportCSV(
                          flattenedList,
                          device.remoteId.toString(),
                          device.advName,
                        );

                        if (success) {
                          if (context.mounted) {
                            informationSnackBar(context, Icons.info,
                                "Data exported successfully");
                          }
                          ref.read(devicesDataProvider.notifier).update(
                                (state) => {
                                  ...state,
                                  device.advName: <List<
                                      PressureData>>[], // Set to an empty list of lists
                                },
                              );
                        } else {
                          if (context.mounted) {
                            informationSnackBar(
                              context,
                              Icons.warning,
                              "Failed to export data",
                            );
                          }
                        }
                      } else {
                        informationSnackBar(context, Icons.warning,
                            "Exporting of data is not possible when other sensors are still collecting data. Kindly stop them and try again");
                      }
                    }
                  },
                  icon: Icon(
                    Icons.save_alt_rounded,
                    color: isIconClicked ? Colors.black : Colors.grey,
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 5,
            ),
            const Divider(
              thickness: 1,
            ),
            const SizedBox(
              height: 5,
            ),
            Row(
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
                  stream: stopWatchTimer.rawTime,
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
            const SizedBox(
              height: 5,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Data Length",
                    style: TextStyle(
                        color: Color.fromARGB(255, 82, 82, 82), fontSize: 12)),
                const SizedBox(
                  width: 10,
                ),
                isIconClicked
                    ? LoadingAnimationWidget.stretchedDots(
                        color: const Color.fromARGB(255, 82, 82, 82),
                        size: 25,
                      )
                    : Text(
                        devicesDataInfo[device.advName]?.length.toString() ??
                            '0',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
