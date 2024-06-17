import 'dart:convert';
import 'dart:typed_data';

import 'package:csv/csv.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pressureruuvi/model/pressure_data_model.dart';

// Ask permission status on Android 12 and below
Future<void> requestPermissions() async {
  if (await Permission.manageExternalStorage.isGranted) {
  } else {
    await Permission.manageExternalStorage.request();
  }
  // Requesting permission for accessing the storage

  var status = await Permission.manageExternalStorage.request();

  if (status.isGranted) {
    // Permission granted, proceed with accessing the storage
  } else if (status.isDenied) {
    // Permission denied
  } else if (status.isPermanentlyDenied) {
    // Permission permanently denied, ask the user to enable it in settings
  }
}

// Check permission status on Android 12 and below
Future<bool> checkPermissionStatus() async {
  // Checking permission status for accessing the storage
  var status = await Permission.manageExternalStorage.status;

  return status.isGranted;
}

Future<String> _localFile(String remoteId, String deviceName) async {
  final String fileName = deviceName +
      remoteId +
      DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());

  return '$fileName.csv';
}

// Exporting a list of data from PressureData to a CSV file
Future<bool> exportCSV(
    List<PressureData> pressureList, String remoteId, String deviceName) async {
  List<List<dynamic>> rows = [];

  for (var map in pressureList) {
    List<double> pressureReadings = [];
    if (map.value.length != 128) {
      return false;
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
    return false;
  }

  final pickedDirectory = await FlutterFileDialog.pickDirectory();

  if (pickedDirectory != null) {
    await FlutterFileDialog.saveFileToDirectory(
      directory: pickedDirectory,
      data: utf8.encode(csv), // Encode CSV string to bytes
      mimeType: "text/csv", // Set MIME type for CSV files
      fileName: await _localFile(remoteId, deviceName), // Set CSV file name
      replace: true,
    );
    return true;
  } else {
    return false;
  }
}
