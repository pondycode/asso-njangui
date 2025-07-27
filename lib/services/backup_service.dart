import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import '../models/member.dart';
import '../models/fund.dart';
import '../models/transaction.dart';
import '../models/loan.dart';
import '../models/contribution.dart';

import 'database_service.dart';

class BackupService {
  static final BackupService _instance = BackupService._internal();
  factory BackupService() => _instance;
  BackupService._internal();

  static BackupService get instance => _instance;

  final DatabaseService _db = DatabaseService.instance;

  /// Create a complete backup of all app data
  Future<BackupResult> createBackup() async {
    try {
      // Get all data from database
      final backupData = await _getAllData();

      // Create backup file content
      final backupContent = {
        'version': '1.0.0',
        'timestamp': DateTime.now().toIso8601String(),
        'app': 'asso_njangui',
        'data': backupData,
      };

      // Convert to JSON
      final jsonString = jsonEncode(backupContent);

      // Save to file
      final file = await _saveBackupFile(jsonString);

      return BackupResult(
        success: true,
        message: 'Backup created successfully',
        filePath: file.path,
        fileSize: await file.length(),
      );
    } catch (e) {
      return BackupResult(
        success: false,
        message: 'Failed to create backup: $e',
      );
    }
  }

  /// Restore data from backup file
  Future<RestoreResult> restoreFromBackup(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        return RestoreResult(success: false, message: 'Backup file not found');
      }

      // Read and parse backup file
      final jsonString = await file.readAsString();
      final backupContent = jsonDecode(jsonString) as Map<String, dynamic>;

      // Validate backup format
      if (!_isValidBackup(backupContent)) {
        return RestoreResult(
          success: false,
          message: 'Invalid backup file format',
        );
      }

      // Extract data
      final data = backupContent['data'] as Map<String, dynamic>;

      // Restore data to database
      await _restoreAllData(data);

      return RestoreResult(
        success: true,
        message: 'Data restored successfully',
        timestamp: backupContent['timestamp'] as String?,
      );
    } catch (e) {
      return RestoreResult(
        success: false,
        message: 'Failed to restore backup: $e',
      );
    }
  }

  /// Share backup file
  Future<void> shareBackup(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await Share.shareXFiles(
          [XFile(filePath)],
          text:
              'Asso Njangui Backup - ${DateTime.now().toString().split(' ')[0]}',
        );
      }
    } catch (e) {
      throw Exception('Failed to share backup: $e');
    }
  }

  /// Get all data from database
  Future<Map<String, dynamic>> _getAllData() async {
    final members = await _db.getAllMembers();
    final funds = await _db.getAllFunds();
    final transactions = await _db.getAllTransactions();
    final loans = await _db.getAllLoans();
    final contributions = await _db.getAllContributions();

    return {
      'members': members.map((m) => _memberToMap(m)).toList(),
      'funds': funds.map((f) => f.toJson()).toList(),
      'transactions': transactions.map((t) => t.toJson()).toList(),
      'loans': loans.map((l) => l.toJson()).toList(),
      'contributions': contributions.map((c) => c.toJson()).toList(),
    };
  }

  // Helper methods for JSON serialization
  Map<String, dynamic> _memberToMap(Member member) {
    return {
      'id': member.id,
      'firstName': member.firstName,
      'lastName': member.lastName,
      'phoneNumber': member.phoneNumber,
      'email': member.email,
      'address': member.address,
      'dateOfBirth': member.dateOfBirth.toIso8601String(),
      'joinDate': member.joinDate.toIso8601String(),
      'status': member.status.name,
      'profileImagePath': member.profileImagePath,
      'nationalId': member.nationalId,
      'occupation': member.occupation,
      'totalSavings': member.totalSavings,
      'totalInvestments': member.totalInvestments,
      'emergencyFund': member.emergencyFund,
      'outstandingLoans': member.outstandingLoans,
      'lastActivityDate': member.lastActivityDate.toIso8601String(),
      'metadata': member.metadata,
    };
  }

  Member _memberFromMap(Map<String, dynamic> map) {
    return Member(
      id: map['id'] as String,
      firstName: map['firstName'] as String,
      lastName: map['lastName'] as String,
      phoneNumber: map['phoneNumber'] as String,
      email: map['email'] as String?,
      address: map['address'] as String?,
      dateOfBirth: DateTime.parse(map['dateOfBirth'] as String),
      joinDate: DateTime.parse(map['joinDate'] as String),
      status: MemberStatus.values.firstWhere(
        (status) => status.name == map['status'],
        orElse: () => MemberStatus.active,
      ),
      profileImagePath: map['profileImagePath'] as String?,
      nationalId: map['nationalId'] as String?,
      occupation: map['occupation'] as String?,
      totalSavings: (map['totalSavings'] as num?)?.toDouble() ?? 0.0,
      totalInvestments: (map['totalInvestments'] as num?)?.toDouble() ?? 0.0,
      emergencyFund: (map['emergencyFund'] as num?)?.toDouble() ?? 0.0,
      outstandingLoans: (map['outstandingLoans'] as num?)?.toDouble() ?? 0.0,
      lastActivityDate: DateTime.parse(map['lastActivityDate'] as String),
      metadata: Map<String, dynamic>.from(map['metadata'] as Map? ?? {}),
    );
  }

  /// Save backup to file
  Future<File> _saveBackupFile(String content) async {
    final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
    final fileName = 'asso_njangui_backup_$timestamp.json';

    Directory directory;
    if (Platform.isAndroid) {
      directory =
          await getExternalStorageDirectory() ??
          await getApplicationDocumentsDirectory();
    } else {
      directory = await getApplicationDocumentsDirectory();
    }

    final file = File('${directory.path}/$fileName');
    await file.writeAsString(content);

    return file;
  }

  /// Validate backup file format
  bool _isValidBackup(Map<String, dynamic> backup) {
    return backup.containsKey('version') &&
        backup.containsKey('timestamp') &&
        backup.containsKey('app') &&
        backup.containsKey('data') &&
        backup['app'] == 'asso_njangui';
  }

  /// Restore all data to database
  Future<void> _restoreAllData(Map<String, dynamic> data) async {
    // Clear existing data
    await _db.clearAllData();

    // Restore members
    if (data.containsKey('members')) {
      final membersList = data['members'] as List<dynamic>;
      for (final memberData in membersList) {
        final member = _memberFromMap(memberData as Map<String, dynamic>);
        await _db.saveMember(member);
      }
    }

    // Restore funds
    if (data.containsKey('funds')) {
      final fundsList = data['funds'] as List<dynamic>;
      for (final fundData in fundsList) {
        final fund = Fund.fromJson(fundData as Map<String, dynamic>);
        await _db.saveFund(fund);
      }
    }

    // Restore transactions
    if (data.containsKey('transactions')) {
      final transactionsList = data['transactions'] as List<dynamic>;
      for (final transactionData in transactionsList) {
        final transaction = Transaction.fromJson(
          transactionData as Map<String, dynamic>,
        );
        await _db.saveTransaction(transaction);
      }
    }

    // Restore loans
    if (data.containsKey('loans')) {
      final loansList = data['loans'] as List<dynamic>;
      for (final loanData in loansList) {
        final loan = Loan.fromJson(loanData as Map<String, dynamic>);
        await _db.saveLoan(loan);
      }
    }

    // Restore contributions
    if (data.containsKey('contributions')) {
      final contributionsList = data['contributions'] as List<dynamic>;
      for (final contributionData in contributionsList) {
        final contribution = Contribution.fromJson(
          contributionData as Map<String, dynamic>,
        );
        await _db.saveContribution(contribution);
      }
    }
  }

  /// Request storage permission
  Future<bool> requestStoragePermission() async {
    if (Platform.isAndroid) {
      final status = await Permission.storage.request();
      return status.isGranted;
    }
    return true; // iOS doesn't need explicit storage permission for app documents
  }

  /// Get backup files list
  Future<List<BackupFileInfo>> getBackupFiles() async {
    try {
      Directory directory;
      if (Platform.isAndroid) {
        directory =
            await getExternalStorageDirectory() ??
            await getApplicationDocumentsDirectory();
      } else {
        directory = await getApplicationDocumentsDirectory();
      }

      final files = directory
          .listSync()
          .where(
            (file) =>
                file.path.contains('asso_njangui_backup_') &&
                file.path.endsWith('.json'),
          )
          .cast<File>()
          .toList();

      final backupFiles = <BackupFileInfo>[];
      for (final file in files) {
        final stat = await file.stat();
        backupFiles.add(
          BackupFileInfo(
            name: file.path.split('/').last,
            path: file.path,
            size: stat.size,
            createdAt: stat.modified,
          ),
        );
      }

      // Sort by creation date (newest first)
      backupFiles.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      return backupFiles;
    } catch (e) {
      return [];
    }
  }
}

class BackupResult {
  final bool success;
  final String message;
  final String? filePath;
  final int? fileSize;

  BackupResult({
    required this.success,
    required this.message,
    this.filePath,
    this.fileSize,
  });
}

class RestoreResult {
  final bool success;
  final String message;
  final String? timestamp;

  RestoreResult({required this.success, required this.message, this.timestamp});
}

class BackupFileInfo {
  final String name;
  final String path;
  final int size;
  final DateTime createdAt;

  BackupFileInfo({
    required this.name,
    required this.path,
    required this.size,
    required this.createdAt,
  });
}
