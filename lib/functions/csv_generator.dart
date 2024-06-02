import 'dart:convert';
import 'dart:typed_data';

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
  final String fileName = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());

  return '$fileName.csv';
}

Future<String> exportCSV(List<PressureData> pressureList) async {
  List<List<dynamic>> rows = [];
  String? statement;
  for (var map in pressureList) {
    List<double> pressureReadings = [];
    if (map.value.length != 128) {
      throw ArgumentError("Invalid data length, expected 128 bytes");
    } else {
      // Convert the list of integers to bytes
      List<int> data = map.value;
      Uint8List receivedData = Uint8List.fromList(data);
      ByteData byteData = ByteData.sublistView(receivedData);

      // Extracting float values from byteData
      for (int i = 0; i < 31; i++) {
        pressureReadings
            .add(byteData.getFloat32(i * 4, Endian.little).toDouble());
      }
      // Extracting the last int value as a double
      pressureReadings.add(byteData.getInt32(31 * 4, Endian.little).toDouble());

      // Creating a row with date and pressure readings
      List<dynamic> row = [map.date];
      row.addAll(pressureReadings);
      rows.add(row);
    }
  }

  String csv = const ListToCsvConverter().convert(rows);

  if (!await FlutterFileDialog.isPickDirectorySupported()) {
    const String statement = "Selected directory is not supported";
    return statement;
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
    statement = "CSV file exported successfully to: $filePath";
  } else {
    statement = "Export failed";
  }

  return statement;
}
