// In FileManager.dart
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class FileManager {
  // Existing methods...

  static Future<String?> getProcessedExcelFilePath() async {
    final directory = await getApplicationDocumentsDirectory();
    final filePath = "${directory.path}/processed_excel.xlsx";
    final file = File(filePath);
    return await file.exists() ? filePath : null;
  }
}
