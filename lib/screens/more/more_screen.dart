import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/app_state_provider.dart';

import '../contributions/contribution_screen.dart';
import '../contributions/contribution_list_screen.dart';
import '../settings/contribution_settings_screen.dart';
import '../settings/loan_settings_screen.dart';
import '../settings/user_manual_screen.dart';
import '../penalties/penalties_list_screen.dart';
import '../members/add_member_screen.dart';
import '../funds/create_fund_screen.dart';
import '../loans/loan_application_screen.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.more),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Consumer<AppStateProvider>(
        builder: (context, appState, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildQuickActionsSection(context),
                const SizedBox(height: 24),
                _buildManagementSection(context),
                const SizedBox(height: 24),
                _buildReportsSection(context),
                const SizedBox(height: 24),
                _buildSettingsSection(context),
                const SizedBox(height: 24),
                _buildSystemSection(context, appState),
                const SizedBox(height: 24),
                _buildSupportSection(context),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildQuickActionsSection(BuildContext context) {
    return _buildSection('Quick Actions', Icons.flash_on, Colors.blue, [
      _buildActionTile(
        'Make Contribution',
        'Add money to funds',
        Icons.add_circle,
        Colors.green,
        () => _navigateToContribution(context),
      ),
      _buildActionTile(
        'Add New Member',
        'Register a new member',
        Icons.person_add,
        Colors.blue,
        () => _navigateToAddMember(context),
      ),
      _buildActionTile(
        'Create Fund',
        'Set up a new investment fund',
        Icons.account_balance,
        Colors.purple,
        () => _navigateToCreateFund(context),
      ),
      _buildActionTile(
        'Apply for Loan',
        'Submit a loan application',
        Icons.request_quote,
        Colors.orange,
        () => _navigateToLoanApplication(context),
      ),
    ]);
  }

  Widget _buildManagementSection(BuildContext context) {
    return _buildSection('Management', Icons.manage_accounts, Colors.indigo, [
      _buildActionTile(
        'Member Management',
        'View and manage all members',
        Icons.people,
        Colors.blue,
        () => _showFeatureComingSoon(context, 'Member Management'),
      ),
      _buildActionTile(
        'Fund Administration',
        'Advanced fund operations',
        Icons.admin_panel_settings,
        Colors.green,
        () => _showFeatureComingSoon(context, 'Fund Administration'),
      ),
      _buildActionTile(
        'Loan Management',
        'Process and track loans',
        Icons.assignment,
        Colors.orange,
        () => _showFeatureComingSoon(context, 'Loan Management'),
      ),
      _buildActionTile(
        'Transaction History',
        'View all transactions',
        Icons.history,
        Colors.purple,
        () => _showFeatureComingSoon(context, 'Transaction History'),
      ),
      _buildActionTile(
        'Contribution Management',
        'View and manage contributions',
        Icons.receipt_long,
        Colors.cyan,
        () => _navigateToContributionList(context),
      ),
      _buildActionTile(
        'Penalties Management',
        'Manage member penalties and fines',
        Icons.warning,
        Colors.red,
        () => _navigateToPenaltiesList(context),
      ),
    ]);
  }

  Widget _buildReportsSection(BuildContext context) {
    return _buildSection('Reports & Analytics', Icons.analytics, Colors.teal, [
      _buildActionTile(
        'Financial Reports',
        'Generate financial statements',
        Icons.assessment,
        Colors.blue,
        () => _showFeatureComingSoon(context, 'Financial Reports'),
      ),
      _buildActionTile(
        'Member Reports',
        'Member activity and statistics',
        Icons.person_search,
        Colors.green,
        () => _showFeatureComingSoon(context, 'Member Reports'),
      ),
      _buildActionTile(
        'Fund Performance',
        'Analyze fund performance',
        Icons.trending_up,
        Colors.orange,
        () => _showFeatureComingSoon(context, 'Fund Performance'),
      ),
      _buildActionTile(
        'Export Data',
        'Export data to CSV or PDF',
        Icons.download,
        Colors.purple,
        () => _showExportOptions(context),
      ),
    ]);
  }

  Widget _buildSettingsSection(BuildContext context) {
    return _buildSection('Settings', Icons.settings, Colors.grey, [
      _buildActionTile(
        'User Manual',
        'Complete guide to using the app',
        Icons.help_outline,
        Colors.purple,
        () => _navigateToUserManual(context),
      ),
      _buildActionTile(
        'Contribution Settings',
        'Set default date and host for contributions',
        Icons.account_balance_wallet,
        Colors.blue,
        () => _navigateToContributionSettings(context),
      ),
      _buildActionTile(
        'Loan Settings',
        'Configure loan interest rates and terms',
        Icons.settings_applications,
        Colors.indigo,
        () => _navigateToLoanSettings(context),
      ),
      _buildActionTile(
        'App Settings',
        'Configure application preferences',
        Icons.tune,
        Colors.blueGrey,
        () => _showFeatureComingSoon(context, 'App Settings'),
      ),
      _buildActionTile(
        'User Preferences',
        'Customize your experience',
        Icons.person_outline,
        Colors.green,
        () => _showFeatureComingSoon(context, 'User Preferences'),
      ),
      _buildActionTile(
        'Notifications',
        'Manage notification settings',
        Icons.notifications,
        Colors.orange,
        () => _showFeatureComingSoon(context, 'Notifications'),
      ),
      _buildActionTile(
        'Security',
        'Security and privacy settings',
        Icons.security,
        Colors.red,
        () => _showFeatureComingSoon(context, 'Security Settings'),
      ),
    ]);
  }

  Widget _buildSystemSection(BuildContext context, AppStateProvider appState) {
    return _buildSection('System', Icons.computer, Colors.blueGrey, [
      _buildActionTile(
        'Refresh Data',
        'Update all information',
        Icons.refresh,
        Colors.blue,
        () => _refreshData(context, appState),
      ),
      _buildActionTile(
        'Backup Data',
        'Create data backup',
        Icons.backup,
        Colors.green,
        () => _showFeatureComingSoon(context, 'Data Backup'),
      ),
      _buildActionTile(
        'About',
        'App information and version',
        Icons.info,
        Colors.grey,
        () => _showAboutDialog(context),
      ),
      _buildActionTile(
        'Help & Support',
        'Get help and contact support',
        Icons.help,
        Colors.orange,
        () => _showFeatureComingSoon(context, 'Help & Support'),
      ),
    ]);
  }

  Widget _buildSupportSection(BuildContext context) {
    return _buildSection('Support the Developer', Icons.favorite, Colors.pink, [
      _buildActionTile(
        'Buy me a coffee ☕',
        'Support app development',
        Icons.local_cafe,
        Colors.brown,
        () => _showBuyMeCoffeeDialog(context),
      ),
      _buildActionTile(
        'Rate the App',
        'Leave a review on the app store',
        Icons.star,
        Colors.amber,
        () => _showFeatureComingSoon(context, 'App Rating'),
      ),
      _buildActionTile(
        'Share with Friends',
        'Tell others about this app',
        Icons.share,
        Colors.blue,
        () => _showFeatureComingSoon(context, 'Share App'),
      ),
    ]);
  }

  Widget _buildSection(
    String title,
    IconData icon,
    Color color,
    List<Widget> children,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Card(child: Column(children: children)),
      ],
    );
  }

  Widget _buildActionTile(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  void _navigateToContribution(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ContributionScreen()),
    );
  }

  void _navigateToAddMember(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddMemberScreen()),
    );
  }

  void _navigateToCreateFund(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CreateFundScreen()),
    );
  }

  void _navigateToLoanApplication(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LoanApplicationScreen()),
    );
  }

  void _navigateToContributionList(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ContributionListScreen()),
    );
  }

  void _navigateToPenaltiesList(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PenaltiesListScreen()),
    );
  }

  void _navigateToUserManual(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const UserManualScreen()),
    );
  }

  void _navigateToContributionSettings(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ContributionSettingsScreen(),
      ),
    );
  }

  void _navigateToLoanSettings(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LoanSettingsScreen()),
    );
  }

  void _showFeatureComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature feature coming soon'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _showExportOptions(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export Data'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.table_chart),
              title: const Text('Export to CSV'),
              subtitle: const Text('Spreadsheet format'),
              onTap: () {
                Navigator.pop(context);
                _showFeatureComingSoon(context, 'CSV Export');
              },
            ),
            ListTile(
              leading: const Icon(Icons.picture_as_pdf),
              title: const Text('Export to PDF'),
              subtitle: const Text('Document format'),
              onTap: () {
                Navigator.pop(context);
                _showFeatureComingSoon(context, 'PDF Export');
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _refreshData(BuildContext context, AppStateProvider appState) {
    appState.refresh();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Data refreshed successfully'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.account_balance, size: 32),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('asso_njangui'),
                Text(
                  'Version 1.0.0',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'A comprehensive financial management system for community organizations.',
              ),
              const SizedBox(height: 16),
              const Text(
                'Features:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const Text('• Member management'),
              const Text('• Fund administration'),
              const Text('• Loan processing'),
              const Text('• Financial reporting'),
              const SizedBox(height: 20),
              const Text(
                'Contact Information:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.email, size: 16),
                  const SizedBox(width: 8),
                  const Text('pondycode@outlook.com'),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.phone, size: 16),
                  const SizedBox(width: 8),
                  const Text('+237674667234'),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showBuyMeCoffeeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.local_cafe, size: 32, color: Colors.brown),
            const SizedBox(width: 12),
            const Text(
              'Buy me a coffee ☕',
              style: TextStyle(color: Colors.brown),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Thank you for using our Association Management App! ❤️',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              const Text(
                'If this app has been helpful to you and your organization, consider supporting the developer with a small contribution.',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.brown[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.brown[200]!),
                ),
                child: Column(
                  children: [
                    const Text(
                      '📱 Mobile Money',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.brown,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.phone, color: Colors.brown),
                        const SizedBox(width: 8),
                        Expanded(
                          child: SelectableText(
                            '+237674667234',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.brown,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.copy, color: Colors.brown),
                          onPressed: () => _copyPhoneNumber(context),
                          tooltip: 'Copy phone number',
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'MTN Mobile Money / Orange Money',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.brown,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                '💡 Suggested amounts:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  _buildAmountChip('2,500 CFA', '☕ Coffee'),
                  _buildAmountChip('3,500 CFA', '🥐 Snack'),
                  _buildAmountChip('4,500 CFA', '🍕 Meal'),
                  _buildAmountChip('5,000 CFA', '❤️ Generous'),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Your support helps maintain and improve this app for everyone! 🙏',
                style: TextStyle(
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Maybe Later'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
              _copyPhoneNumber(context);
            },
            icon: const Icon(Icons.copy),
            label: const Text('Copy Number'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.brown,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountChip(String amount, String description) {
    return Chip(
      label: Text('$amount $description', style: const TextStyle(fontSize: 12)),
      backgroundColor: Colors.brown[100],
      labelStyle: const TextStyle(color: Colors.brown),
    );
  }

  void _copyPhoneNumber(BuildContext context) {
    Clipboard.setData(const ClipboardData(text: '+237674667234'));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Phone number copied to clipboard! 📋'),
        backgroundColor: Colors.brown,
        duration: Duration(seconds: 2),
      ),
    );
  }
}
