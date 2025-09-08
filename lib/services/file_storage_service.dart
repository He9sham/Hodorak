import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

class FileStorageService {
  static const String _fileName = 'attendance_calendar.json';

  /// Get the file path for storing data
  Future<File> _getFile() async {
    final directory = await getApplicationDocumentsDirectory();
    final dirPath = directory.path;
    final file = File('$dirPath/$_fileName');
    // Ensure directory exists (it should, but defensive)
    if (!await file.parent.exists()) {
      await file.parent.create(recursive: true);
    }
    return file;
  }

  /// Save data to file
  Future<void> saveData(Map<String, dynamic> data) async {
    try {
      final file = await _getFile();
      final jsonString = jsonEncode(data);
      await file.writeAsString(jsonString);
    } catch (e) {
      print('Error saving data to file: $e');
      rethrow;
    }
  }

  /// Load data from file
  Future<Map<String, dynamic>> loadData() async {
    try {
      final file = await _getFile();
      if (await file.exists()) {
        final jsonString = await file.readAsString();
        return Map<String, dynamic>.from(jsonDecode(jsonString));
      }
      return {};
    } catch (e) {
      print('Error loading data from file: $e');
      return {};
    }
  }

  /// Clear all data
  Future<void> clearData() async {
    try {
      final file = await _getFile();
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      print('Error clearing data: $e');
    }
  }

  /// Check if file exists
  Future<bool> fileExists() async {
    try {
      final file = await _getFile();
      return await file.exists();
    } catch (e) {
      return false;
    }
  }
}
