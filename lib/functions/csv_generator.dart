import 'dart:convert';

import 'package:csv/csv.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';

Future<void> requestPermissions() async {
  // Requesting permission for accessing the storage
  var status = await Permission.storage.request();
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
  var status = await Permission.storage.status;

  return status.isGranted;
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

Future<String> get _localFile async {
  // final path = await _localPath;

  final String fileName = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());

  return '$fileName.csv';
}

void exportCSV(List<Map<String, dynamic>> list) async {
  List<List<dynamic>> rows = [];
  rows.add(["devices"]);

  for (var map in list) {
    rows.add([map["devices"]]);
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
