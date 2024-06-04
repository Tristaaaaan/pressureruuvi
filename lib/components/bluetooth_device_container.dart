import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:pressureruuvi/functions/gather_data.dart';
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
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.black,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  device.advName,
                  style: const TextStyle(fontSize: 20),
                ),
                IconButton(
                  onPressed: () {
                    if (devicesDataInfo[device.advName] == null) {
                      print("Devices data info is null");
                    } else {
                      print(device.advName);
                      print(
                          "Length: ${devicesDataInfo[device.advName]!.length.toString()}");
                    }

                    // for (final data in devicesDataInfo[sensorName]!) {
                    //   for (final datas in data) {
                    //     print(datas.value);
                    //     print(datas.date);
                    //   }
                    // }
                  },
                  icon: const Icon(Icons.file_present),
                ),
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  borderRadius: BorderRadius.circular(5),
                  onTap: onTap,
                  child: IntrinsicWidth(
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Color.fromARGB(255, 194, 194, 194),
                        borderRadius: BorderRadius.all(
                          Radius.circular(5),
                        ),
                      ),
                      padding: const EdgeInsets.all(5),
                      child: isIconClicked
                          ? const Icon(
                              Icons.stop,
                              color: Colors.white,
                            )
                          : const Icon(
                              Icons.play_arrow,
                              color: Colors.white,
                            ),
                    ),
                  ),
                ),
              ],
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
              height: 10,
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
