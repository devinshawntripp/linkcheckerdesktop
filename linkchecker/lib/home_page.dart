import 'package:flutter/material.dart';
import 'package:linkchecker/ExcelDataTable.dart';
import 'file_manager.dart';
import 'bulk_upload_screen.dart'; // Assume this is your screen for handling file upload and processing

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? _processedExcelFilePath;

  @override
  void initState() {
    super.initState();
    _checkForProcessedExcelFile();
  }

  Future<void> _checkForProcessedExcelFile() async {
    String? processedFilePath = await FileManager.getProcessedExcelFilePath();
    setState(() {
      _processedExcelFilePath = processedFilePath;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Excel Data Viewer')),
      body: _processedExcelFilePath == null
          ? Center(
              child: ElevatedButton(
                onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => BulkUploadScreen())).then((_) =>
                    _checkForProcessedExcelFile()), // Refresh the state after returning
                child: Text('Select Excel File'),
              ),
            )
          : ExcelDataTable(
              excelFilePath: _processedExcelFilePath!), // Placeholder widget
    );
  }
}
