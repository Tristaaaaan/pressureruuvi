import 'dart:convert';

import 'package:csv/csv.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';

class PressureData {
  final int date;
  final List<int> value;
  PressureData({
    required this.date,
    required this.value,
  });
}

Future<void> requestPermissions() async {
  if (await Permission.manageExternalStorage.isGranted) {
  } else {
    await Permission.manageExternalStorage.request();
  }
  // Requesting permission for accessing the storage

  var status = await Permission.manageExternalStorage.request();
  // You can also request multiple permissions at once like this:
  // var status = await [Permission.storage, Permission.camera].request();
  // Then handle each permission status accordingly.
  if (status.isGranted) {
    // Permission granted, proceed with accessing the storage
  } else if (status.isDenied) {
    // Permission denied
  } else if (status.isPermanentlyDenied) {
    // Permission permanently denied, ask the user to enable it in settings
  }
}

Future<bool> checkPermissionStatus() async {
  // Checking permission status for accessing the storage
  var status = await Permission.manageExternalStorage.status;

  return status.isGranted;
}

Future<String> get _localFile async {
  // final path = await _localPath;

  final String fileName = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());

  return '$fileName.csv';
}

Future<void> exportCSV(List<PressureData> pressureList) async {
  List<List<dynamic>> rows = [];

  for (var map in pressureList) {
    // if (map.value.length == 128) {
    //   List<int?> pressureReading = [];
    //   int offset = 50000;
    //   // CALCULATE

    //   for (int i = 0; i < map.value.length - 4; i += 4) {
    //     // Combine two bytes to form a 16-bit unsigned integer (little-endian)
    //     int pressureRaw = map.value[i] + (map.value[i + 1] << 8);
    //     int? pressure;

    //     if (pressureRaw == 0xFFFF) {
    //       // Indicate invalid or unavailable data
    //       pressure = null;
    //     } else {
    //       pressure = pressureRaw + offset;
    //     }

    //     pressureReading.add(pressure);
    //   }

    //   // END

    //   List<dynamic> row = [map.date];
    //   row.addAll(pressureReading);
    //   rows.add(row);
    // }

    List<int> pressureReadings = [];
    if (map.value.length != 128) {
      throw ArgumentError("Invalid data length, expected 128 bytes");
    } else {
      // Convert the list of integers to bytes
      List<int> data = map.value;

      // Define the number of readings and size of each chunk in bytes
      int numReadings = 31;
      int chunkSize = 4;

      // Iterate over the data to extract each pressure reading
      for (int i = 0; i < numReadings; i++) {
        int startIndex = i * chunkSize;
        List<int> pressureBytes = data.sublist(startIndex + 2, startIndex + 4);

        // Convert bytes to integer (assuming big-endian format)
        int pressure = 0;
        for (int byte in pressureBytes) {
          pressure = (pressure << 8) | byte;
        }

        // Adjust pressure value according to the sensor's encoding formula, if necessary
        int pressureAdjusted = pressure + 50000; // Example adjustment

        pressureReadings.add(pressureAdjusted);
      }

      List<dynamic> row = [map.date];
      row.addAll(pressureReadings);
      rows.add(row);
    }
  }

  String csv = const ListToCsvConverter().convert(rows);

  if (!await FlutterFileDialog.isPickDirectorySupported()) {
    print("Picking directory not supported");
    return;
  }

  final pickedDirectory = await FlutterFileDialog.pickDirectory();

  if (pickedDirectory != null) {
    final filePath = await FlutterFileDialog.saveFileToDirectory(
      directory: pickedDirectory,
      data: utf8.encode(csv), // Encode CSV string to bytes
      mimeType: "text/csv", // Set MIME type for CSV files
      fileName: await _localFile, // Set CSV file name
      replace: true,
    );
    print("CSV file exported successfully to: $filePath");
  } else {
    print("Export canceled or failed.");
  }
}

// Future<String> get _localPath async {
//   final directory =
//       await getExternalStorageDirectory(); // await getApplicationDocumentsDirectory();

//   return directory!.path;
// }

// Future<File> get _localFile async {
//   final path = await _localPath;

//   final String fileName = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());

//   return File('$path/$fileName.csv');
// }
