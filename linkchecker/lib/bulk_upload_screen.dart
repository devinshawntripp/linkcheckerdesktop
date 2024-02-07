import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:excel/excel.dart';
import 'package:linkchecker/table_screen.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart'; // Make sure to import

class BulkUploadScreen extends StatefulWidget {
  @override
  _BulkUploadScreenState createState() => _BulkUploadScreenState();
}

class _BulkUploadScreenState extends State<BulkUploadScreen> {
  List<Map<String, dynamic>> _excelData = [];
  int _maxLinks = 0;

  Future<void> _pickAndProcessExcelFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      File file = File(result.files.single.path!);
      var bytes = file.readAsBytesSync();
      var excel = Excel.decodeBytes(bytes);
      _processExcelData(excel);
    }
  }

  int max(int a, int b) {
    var maxFound = a;
    if (a < b) {
      maxFound = b;
    }
    return maxFound;
  }

  bool isDigit(int rune) => rune ^ 0x30 <= 9;

  void _processExcelData(Excel excel) {
    var sheet = excel.tables[excel.tables.keys.first];
    if (sheet == null) return;

    List<String?> headers = sheet.rows[0]
        .map((cell) => cell?.value.toString())
        .toList(); // Extracting headers as strings
    Map<String, String> abbreviationToMoneySite = {};
    var rows = sheet.rows;
    print(rows.isNotEmpty);

    if (rows.isNotEmpty) {
      // Assume the first row contains headers
      var headers = rows.first;
      print(headers.map((cell) => cell?.value.toString()).toList());
      int abbreviationsColumnIndex = headers.indexWhere((cell) =>
          cell?.value.toString().trim().toLowerCase() == "abbreviation");
      print(abbreviationsColumnIndex);

      // If "Abbreviations" column found and there's a column before it
      if (abbreviationsColumnIndex > 0) {
        // Ensure there is a column before "Abbreviations"
        int moneySiteColumnIndex = abbreviationsColumnIndex -
            1; // Column immediately before "Abbreviations"
        var moneySiteHeader = headers[moneySiteColumnIndex]?.value;
        print('Money Site Header: $moneySiteHeader'); // For debugging

        // The abbreviations and their corresponding money sites are assumed to be in the same row
        for (int i = 1; i < rows.length; i++) {
          // Start from the second row
          var row = rows[i];
          var moneySite = row[moneySiteColumnIndex]?.value;
          var abbreviation = row[abbreviationsColumnIndex]?.value;
          if (abbreviation != null && moneySite != null) {
            abbreviationToMoneySite[abbreviation.toString().toLowerCase()] =
                moneySite.toString();
          }
        }
      }
    }

    // Continue with your logic, now having a map of abbreviations to money sites
    print('Abbreviation to Money Site Map: $abbreviationToMoneySite');

    List<Map<String, dynamic>> tempData = [];
    int maxLinks = 0;

    // Start processing from the second row, assuming the first row is headers
    for (var row in sheet.rows.skip(1)) {
      var pbnName = row[0]?.value;
      if (pbnName == null || pbnName.toString().isEmpty)
        break; // If PBN name is missing, stop processing

      List<String> links = [];
      for (int i = 2; i < row.length; i++) {
        // Assuming link indicators start from the 3rd column
        var cellValue = row[i]?.value;

        print('Cellvalue $cellValue of type ${cellValue.runtimeType}');
        if (cellValue is IntCellValue && cellValue == 1) {
          print('Found link indicator int');
        } else if (cellValue is double && cellValue == 1.0) {
          print('Found link indicator double');
        } else if (cellValue.toString() == "1") {
          // Safely check for string "1"
          print('Found link indicator string');
        }

        // Direct comparison without explicit casting, as Dart handles type promotion
        if (cellValue is IntCellValue && cellValue.toString() == "1") {
          print(
              'Found link indicator'); // This confirms the cellValue is 1 and the type check is not needed

          var abbreviationHeader = headers[i];
          print('abbreviationHeader $abbreviationHeader'); // Should now print

          if (abbreviationHeader != null) {
            var moneySite =
                abbreviationToMoneySite[abbreviationHeader.toLowerCase()];
            if (moneySite != null) {
              links.add(
                  moneySite); // This should correctly add the money site to links
            }
          }
        }
      }
      // row[1]?.value ??

      tempData.add({
        'PBN Name': pbnName.toString(),
        'Category': 'No Category Set',
        'Links': links,
        'Total Links': links.length,
      });

      maxLinks = max(maxLinks, links.length);
    }

    setState(() {
      _excelData = tempData;
      _maxLinks = maxLinks;
    });

    // Navigate to TableScreen with the processed data
    if (mounted) {
      // Check to ensure setState is called on a mounted widget
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) =>
            TableScreen(excelData: _excelData, maxLinks: _maxLinks),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Excel Data Viewer')),
      body: Center(
        child: _excelData.isEmpty
            ? ElevatedButton(
                onPressed: _pickAndProcessExcelFile,
                child: Text('Select Excel File'),
              )
            : ListView(
                children:
                    _excelData.map((data) => Text(data.toString())).toList(),
              ),
      ),
    );
  }
}
