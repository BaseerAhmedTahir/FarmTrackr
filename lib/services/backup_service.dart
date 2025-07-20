import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:goat_tracker/services/base_service.dart';
import 'package:goat_tracker/models/goat.dart';
import 'package:goat_tracker/models/sale.dart';
import 'package:goat_tracker/models/expense.dart';
import 'package:goat_tracker/models/caretaker.dart';

class BackupService extends BaseService {
  static const String _backupFolder = 'backups';

  Future<String> createBackup() async {
    final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
    final backupData = await _gatherBackupData();
    final backupJson = jsonEncode(backupData);
    final backupFile = await _saveBackupFile(backupJson, timestamp);
    return backupFile.path;
  }

  Future<void> restoreFromBackup(String filePath) async {
    final file = File(filePath);
    if (!await file.exists()) {
      throw Exception('Backup file not found');
    }

    final backupJson = await file.readAsString();
    final backupData = jsonDecode(backupJson) as Map<String, dynamic>;

    await _restoreData(backupData);
  }

  Future<void> shareBackup(String backupPath) async {
    final file = File(backupPath);
    if (!await file.exists()) {
      throw Exception('Backup file not found');
    }

    await Share.shareXFiles([XFile(backupPath)], 
      text: 'Goat Tracker Backup ${DateTime.now().toLocal()}');
  }

  Future<Map<String, dynamic>> _gatherBackupData() async {
    final goats = await supabase.from('goats').select();
    final sales = await supabase.from('sales').select();
    final expenses = await supabase.from('expenses').select();
    final caretakers = await supabase.from('caretakers').select();
    final settings = await supabase.from('settings').select();

    return {
      'version': 1,
      'timestamp': DateTime.now().toIso8601String(),
      'data': {
        'goats': goats,
        'sales': sales,
        'expenses': expenses,
        'caretakers': caretakers,
        'settings': settings,
      }
    };
  }

  Future<File> _saveBackupFile(String content, String timestamp) async {
    final dir = await _getBackupDirectory();
    final fileName = 'goat_tracker_backup_$timestamp.json';
    final file = File('${dir.path}/$fileName');
    await file.writeAsString(content);
    return file;
  }

  Future<void> _restoreData(Map<String, dynamic> backupData) async {
    if (backupData['version'] != 1) {
      throw Exception('Unsupported backup version');
    }

    final data = backupData['data'] as Map<String, dynamic>;

    // Clear existing data
    await supabase.from('sales').delete().neq('id', '0');
    await supabase.from('expenses').delete().neq('id', '0');
    await supabase.from('goats').delete().neq('id', '0');
    await supabase.from('caretakers').delete().neq('id', '0');
    await supabase.from('settings').delete().neq('id', '0');

    // Restore data
    if (data['caretakers'] != null) {
      await supabase.from('caretakers').insert(data['caretakers']);
    }
    if (data['goats'] != null) {
      await supabase.from('goats').insert(data['goats']);
    }
    if (data['sales'] != null) {
      await supabase.from('sales').insert(data['sales']);
    }
    if (data['expenses'] != null) {
      await supabase.from('expenses').insert(data['expenses']);
    }
    if (data['settings'] != null) {
      await supabase.from('settings').insert(data['settings']);
    }
  }

  Future<Directory> _getBackupDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final backupDir = Directory('${appDir.path}/$_backupFolder');
    
    if (!await backupDir.exists()) {
      await backupDir.create(recursive: true);
    }
    
    return backupDir;
  }

  Future<List<FileSystemEntity>> listBackups() async {
    final dir = await _getBackupDirectory();
    final files = await dir.list().toList();
    return files.where((file) => 
      file.path.endsWith('.json') && 
      file.path.contains('goat_tracker_backup')
    ).toList();
  }

  Future<void> deleteBackup(String filePath) async {
    final file = File(filePath);
    if (await file.exists()) {
      await file.delete();
    }
  }
}
