import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import '../../services/backup_service.dart';
import '../../providers/app_state_provider.dart';

class BackupRestoreScreen extends StatefulWidget {
  const BackupRestoreScreen({super.key});

  @override
  State<BackupRestoreScreen> createState() => _BackupRestoreScreenState();
}

class _BackupRestoreScreenState extends State<BackupRestoreScreen> {
  final BackupService _backupService = BackupService.instance;
  bool _isLoading = false;
  List<BackupFileInfo> _backupFiles = [];

  @override
  void initState() {
    super.initState();
    _loadBackupFiles();
  }

  Future<void> _loadBackupFiles() async {
    final files = await _backupService.getBackupFiles();
    setState(() {
      _backupFiles = files;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Backup & Restore'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBackupSection(),
            const SizedBox(height: 24),
            _buildRestoreSection(),
            const SizedBox(height: 24),
            _buildBackupFilesList(),
          ],
        ),
      ),
    );
  }

  Widget _buildBackupSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.backup,
                    color: Colors.green,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Create Backup',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'Create a complete backup of all your data including members, funds, transactions, loans, and contributions.',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _createBackup,
                icon: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.backup),
                label: Text(
                  _isLoading ? 'Creating Backup...' : 'Create Backup',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRestoreSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.restore,
                    color: Colors.blue,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Restore from Backup',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'Restore your data from a backup file. This will replace all current data.',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _selectBackupFile,
                icon: const Icon(Icons.file_open),
                label: const Text('Select Backup File'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackupFilesList() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.folder,
                    color: Colors.orange,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Backup Files',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                IconButton(
                  onPressed: _loadBackupFiles,
                  icon: const Icon(Icons.refresh),
                  tooltip: 'Refresh',
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_backupFiles.isEmpty)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Center(
                  child: Text(
                    'No backup files found',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _backupFiles.length,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) {
                  final backup = _backupFiles[index];
                  return _buildBackupFileItem(backup);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackupFileItem(BackupFileInfo backup) {
    final sizeInMB = (backup.size / (1024 * 1024)).toStringAsFixed(2);

    return ListTile(
      leading: const Icon(Icons.insert_drive_file, color: Colors.blue),
      title: Text(
        backup.name
            .replaceAll('asso_njangui_backup_', '')
            .replaceAll('.json', ''),
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Created: ${DateFormat('MMM dd, yyyy HH:mm').format(backup.createdAt)}',
          ),
          Text('Size: $sizeInMB MB'),
        ],
      ),
      trailing: PopupMenuButton<String>(
        onSelected: (value) {
          switch (value) {
            case 'restore':
              _restoreFromFile(backup.path);
              break;
            case 'share':
              _shareBackup(backup.path);
              break;
          }
        },
        itemBuilder: (context) => [
          const PopupMenuItem(
            value: 'restore',
            child: Row(
              children: [
                Icon(Icons.restore, size: 20),
                SizedBox(width: 8),
                Text('Restore'),
              ],
            ),
          ),
          const PopupMenuItem(
            value: 'share',
            child: Row(
              children: [
                Icon(Icons.share, size: 20),
                SizedBox(width: 8),
                Text('Share'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _createBackup() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Request storage permission
      final hasPermission = await _backupService.requestStoragePermission();
      if (!hasPermission) {
        _showMessage(
          'Storage permission required to create backup',
          isError: true,
        );
        return;
      }

      final result = await _backupService.createBackup();

      if (result.success) {
        _showMessage('Backup created successfully!');
        await _loadBackupFiles(); // Refresh the list

        // Show option to share
        _showShareBackupDialog(result.filePath!);
      } else {
        _showMessage(result.message, isError: true);
      }
    } catch (e) {
      _showMessage('Error creating backup: $e', isError: true);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _selectBackupFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result != null && result.files.single.path != null) {
        final filePath = result.files.single.path!;
        await _restoreFromFile(filePath);
      }
    } catch (e) {
      _showMessage('Error selecting file: $e', isError: true);
    }
  }

  Future<void> _restoreFromFile(String filePath) async {
    // Show confirmation dialog
    final confirmed = await _showRestoreConfirmationDialog();
    if (!confirmed) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await _backupService.restoreFromBackup(filePath);

      if (result.success) {
        _showMessage('Data restored successfully!');

        // Refresh app state
        if (mounted) {
          context.read<AppStateProvider>().refresh();
        }
      } else {
        _showMessage(result.message, isError: true);
      }
    } catch (e) {
      _showMessage('Error restoring backup: $e', isError: true);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _shareBackup(String filePath) async {
    try {
      await _backupService.shareBackup(filePath);
    } catch (e) {
      _showMessage('Error sharing backup: $e', isError: true);
    }
  }

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: Duration(seconds: isError ? 4 : 3),
      ),
    );
  }

  void _showShareBackupDialog(String filePath) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Text('Backup Created'),
          ],
        ),
        content: const Text(
          'Your backup has been created successfully. Would you like to share it?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Later'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _shareBackup(filePath);
            },
            icon: const Icon(Icons.share),
            label: const Text('Share'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Future<bool> _showRestoreConfirmationDialog() async {
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.warning, color: Colors.orange),
                SizedBox(width: 8),
                Text('Confirm Restore'),
              ],
            ),
            content: const Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'This will replace ALL current data with the backup data.',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 12),
                Text(
                  'This action cannot be undone. Make sure you have a current backup if needed.',
                ),
                SizedBox(height: 12),
                Text(
                  'Are you sure you want to continue?',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Restore'),
              ),
            ],
          ),
        ) ??
        false;
  }
}
