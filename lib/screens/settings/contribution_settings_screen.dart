import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/contribution_settings_provider.dart';
import '../../providers/app_state_provider.dart';
import '../../models/member.dart';

class ContributionSettingsScreen extends StatefulWidget {
  const ContributionSettingsScreen({super.key});

  @override
  State<ContributionSettingsScreen> createState() =>
      _ContributionSettingsScreenState();
}

class _ContributionSettingsScreenState
    extends State<ContributionSettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contribution Settings'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.restore),
            tooltip: 'Reset to defaults',
            onPressed: _showResetDialog,
          ),
        ],
      ),
      body: Consumer2<ContributionSettingsProvider, AppStateProvider>(
        builder: (context, settingsProvider, appState, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderCard(),
                const SizedBox(height: 16),
                _buildDateSettingsCard(settingsProvider),
                const SizedBox(height: 16),
                _buildHostSettingsCard(settingsProvider, appState),
                const SizedBox(height: 16),
                _buildPreviewCard(settingsProvider, appState),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.settings,
                    color: Colors.blue[700],
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Default Contribution Settings',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Set default values to speed up contribution entry',
                        style: TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateSettingsCard(ContributionSettingsProvider settingsProvider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.date_range, color: Colors.green[700]),
                const SizedBox(width: 8),
                const Text(
                  'Default Date',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Always use today\'s date'),
              subtitle: const Text(
                'Automatically set date to today for new contributions',
              ),
              value: settingsProvider.useTodayAsDefault,
              onChanged: (value) {
                settingsProvider.setUseTodayAsDefault(value);
              },
            ),
            if (!settingsProvider.useTodayAsDefault) ...[
              const Divider(),
              ListTile(
                leading: const Icon(Icons.calendar_today),
                title: const Text('Fixed Default Date'),
                subtitle: Text(
                  settingsProvider.defaultDate != null
                      ? DateFormat(
                          'EEEE, MMM dd, yyyy',
                        ).format(settingsProvider.defaultDate!)
                      : 'No date selected',
                ),
                trailing: const Icon(Icons.edit),
                onTap: () => _selectDefaultDate(settingsProvider),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHostSettingsCard(
    ContributionSettingsProvider settingsProvider,
    AppStateProvider appState,
  ) {
    final defaultHost = settingsProvider.getDefaultHost(appState.members);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.person, color: Colors.orange[700]),
                const SizedBox(width: 8),
                const Text(
                  'Default Host',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Select a member to be the default host for contributions',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: CircleAvatar(
                backgroundColor: defaultHost != null
                    ? Colors.orange[100]
                    : Colors.grey[200],
                child: Icon(
                  defaultHost != null ? Icons.person : Icons.person_outline,
                  color: defaultHost != null
                      ? Colors.orange[700]
                      : Colors.grey[600],
                ),
              ),
              title: Text(defaultHost?.fullName ?? 'No default host selected'),
              subtitle: defaultHost != null
                  ? Text(
                      '${defaultHost.email} • Member since ${DateFormat('MMM yyyy').format(defaultHost.joinDate)}',
                    )
                  : const Text('Tap to select a default host'),
              trailing: const Icon(Icons.edit),
              onTap: () => _selectDefaultHost(settingsProvider, appState),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewCard(
    ContributionSettingsProvider settingsProvider,
    AppStateProvider appState,
  ) {
    final defaultHost = settingsProvider.getDefaultHost(appState.members);
    final effectiveDate = settingsProvider.effectiveDefaultDate;

    return Card(
      color: Colors.blue[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.preview, color: Colors.blue[700]),
                const SizedBox(width: 8),
                const Text(
                  'Preview',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'This is how new contributions will be pre-filled:',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.date_range,
                        size: 16,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Date: ${DateFormat('EEEE, MMM dd, yyyy').format(effectiveDate)}',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.person, size: 16, color: Colors.grey),
                      const SizedBox(width: 8),
                      Text(
                        'Host: ${defaultHost?.fullName ?? 'Not set'}',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDefaultDate(
    ContributionSettingsProvider settingsProvider,
  ) async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: settingsProvider.defaultDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      helpText: 'Select default date for contributions',
    );

    if (selectedDate != null) {
      await settingsProvider.setDefaultDate(selectedDate);
    }
  }

  Future<void> _selectDefaultHost(
    ContributionSettingsProvider settingsProvider,
    AppStateProvider appState,
  ) async {
    final activeMembers = appState.activeMembers;

    if (activeMembers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No active members available to select as host'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final selectedHost = await showDialog<Member?>(
      context: context,
      builder: (context) =>
          _buildHostSelectionDialog(activeMembers, settingsProvider),
    );

    if (selectedHost != null) {
      await settingsProvider.setDefaultHost(selectedHost);
    }
  }

  Widget _buildHostSelectionDialog(
    List<Member> members,
    ContributionSettingsProvider settingsProvider,
  ) {
    return AlertDialog(
      title: const Text('Select Default Host'),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: members.length + 1, // +1 for "None" option
          itemBuilder: (context, index) {
            if (index == 0) {
              // "None" option
              return ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Colors.grey,
                  child: Icon(Icons.clear, color: Colors.white),
                ),
                title: const Text('None'),
                subtitle: const Text('No default host'),
                onTap: () => Navigator.pop(context, null),
              );
            }

            final member = members[index - 1];
            final isSelected = settingsProvider.defaultHostId == member.id;

            return ListTile(
              leading: CircleAvatar(
                backgroundColor: isSelected
                    ? Colors.blue[100]
                    : Colors.grey[200],
                child: Icon(
                  Icons.person,
                  color: isSelected ? Colors.blue[700] : Colors.grey[600],
                ),
              ),
              title: Text(member.fullName),
              subtitle: Text(member.email ?? 'No email'),
              trailing: isSelected
                  ? const Icon(Icons.check, color: Colors.blue)
                  : null,
              onTap: () => Navigator.pop(context, member),
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ],
    );
  }

  void _showResetDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Settings'),
        content: const Text(
          'Are you sure you want to reset all contribution settings to their default values?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final navigator = Navigator.of(context);
              final messenger = ScaffoldMessenger.of(context);

              await context
                  .read<ContributionSettingsProvider>()
                  .clearAllDefaults();

              navigator.pop();
              messenger.showSnackBar(
                const SnackBar(
                  content: Text('Settings reset to defaults'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Reset', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
