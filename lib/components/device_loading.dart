import 'package:flutter/material.dart';
import 'package:pressureruvvi/components/skeleton.dart';
import 'package:shimmer/shimmer.dart';

class BluetoothDevicesLoading extends StatelessWidget {
  const BluetoothDevicesLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[400]!,
      highlightColor: Colors.grey[300]!,
      child: ListView.separated(
        itemCount: 5,
        separatorBuilder: (context, index) => const SizedBox(
          height: 12,
        ),
        itemBuilder: (context, index) {
          return Container(
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
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Skeleton(
                  height: 15,
                  width: 150,
                ),
                SizedBox(
                  height: 10,
                ),
                Skeleton(
                  height: 18,
                  width: double.infinity,
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
