import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/app_state_provider.dart';
import '../../providers/license_provider.dart';

import '../contributions/contribution_list_screen.dart';
import '../settings/contribution_settings_screen.dart';
import '../settings/fund_settings_screen.dart';
import '../settings/loan_settings_screen.dart';
import '../settings/user_manual_screen.dart';
import '../settings/license_activation_screen.dart';
import '../penalties/penalties_list_screen.dart';

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
                _buildProminentSupportSection(context),
                const SizedBox(height: 24),
                _buildManagementSection(context),
                const SizedBox(height: 24),
                _buildReportsSection(context),
                const SizedBox(height: 24),
                _buildSettingsSection(context),
                const SizedBox(height: 24),
                _buildSystemSection(context, appState),
                const SizedBox(height: 24),
                _buildLicenseSection(context),
                const SizedBox(height: 24),
                _buildSupportSection(context),
              ],
            ),
          );
        },
      ),
    );
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
        'Configure percentage-based interest rates and terms',
        Icons.settings_applications,
        Colors.indigo,
        () => _navigateToLoanSettings(context),
      ),
      _buildActionTile(
        'Fund Settings',
        'Set default amounts for fund contributions',
        Icons.account_balance,
        Colors.green,
        () => _navigateToFundSettings(context),
      ),
      Consumer<LicenseProvider>(
        builder: (context, licenseProvider, child) {
          final l10n = AppLocalizations.of(context)!;
          final licenseInfo = licenseProvider.getLicenseInfo();
          final statusText = licenseProvider.isTrialMode
              ? 'Trial - ${licenseInfo['daysRemaining'] ?? 0} days left'
              : licenseProvider.hasFullLicense
              ? 'Full License Active'
              : 'License Required';

          return _buildActionTile(
            l10n.licenseActivation,
            statusText,
            Icons.vpn_key,
            licenseProvider.isLicensed ? Colors.green : Colors.orange,
            () => _navigateToLicenseActivation(context),
          );
        },
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

  Widget _buildProminentSupportSection(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.brown.shade400, Colors.brown.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.brown.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.local_cafe,
                  size: 32,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.supportDeveloper,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.supportAppDevelopment,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _showBuyMeCoffeeDialog(context),
              icon: const Icon(Icons.local_cafe, size: 24),
              label: Text(
                l10n.buyMeACoffee,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.brown.shade700,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            l10n.supportAppMessage,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withValues(alpha: 0.8),
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLicenseSection(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return _buildSection(l10n.licenseRestrictions, Icons.gavel, Colors.red, [
      _buildActionTile(
        l10n.personalUseOnly,
        l10n.personalUseDescription,
        Icons.person,
        Colors.green,
        () => _showLicenseDialog(context),
      ),
      _buildActionTile(
        l10n.commercialProhibited,
        l10n.commercialDescription,
        Icons.business,
        Colors.red,
        () => _showLicenseDialog(context),
      ),
      _buildActionTile(
        l10n.contactForCommercial,
        l10n.contactForCommercialDescription,
        Icons.email,
        Colors.blue,
        () => _showBuyMeCoffeeDialog(context),
      ),
    ]);
  }

  Widget _buildSupportSection(BuildContext context) {
    return _buildSection('Additional Support', Icons.favorite, Colors.pink, [
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

  void _navigateToFundSettings(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const FundSettingsScreen()),
    );
  }

  void _navigateToLicenseActivation(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LicenseActivationScreen()),
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
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.local_cafe, size: 32, color: Colors.brown),
            const SizedBox(width: 12),
            Text(
              l10n.buyMeACoffee,
              style: const TextStyle(color: Colors.brown),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.thankYouMessage, style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 16),
              Text(l10n.supportMessage, style: const TextStyle(fontSize: 14)),
              const SizedBox(height: 20),
              Text(
                l10n.chooseContactMethod,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              _buildContactOptions(context, l10n),
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
                    Text(
                      l10n.mobileMoneyDetails,
                      style: const TextStyle(
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
                        const Expanded(
                          child: SelectableText(
                            '+237674667234',
                            style: TextStyle(
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
                    Text(
                      l10n.mtnOrangeMoney,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.brown,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.suggestedAmounts,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  _buildAmountChip('2,500 CFA', l10n.coffeeAmount),
                  _buildAmountChip('3,500 CFA', l10n.snackAmount),
                  _buildAmountChip('4,500 CFA', l10n.mealAmount),
                  _buildAmountChip('5,000 CFA', l10n.generousAmount),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                l10n.supportAppMessage,
                style: const TextStyle(
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
            child: Text(l10n.maybeLater),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
              _copyPhoneNumber(context);
            },
            icon: const Icon(Icons.copy),
            label: Text(l10n.copyNumber),
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
    final l10n = AppLocalizations.of(context)!;
    Clipboard.setData(const ClipboardData(text: '+237674667234'));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.phoneNumberCopied),
        backgroundColor: Colors.brown,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Widget _buildContactOptions(BuildContext context, AppLocalizations l10n) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildContactButton(
          context,
          l10n.whatsappContact,
          Icons.chat,
          Colors.green,
          () => _launchWhatsApp(context, l10n),
        ),
        _buildContactButton(
          context,
          l10n.phoneCallContact,
          Icons.phone,
          Colors.blue,
          () => _launchPhoneCall(context, l10n),
        ),
        _buildContactButton(
          context,
          l10n.smsContact,
          Icons.sms,
          Colors.orange,
          () => _launchSMS(context, l10n),
        ),
      ],
    );
  }

  Widget _buildContactButton(
    BuildContext context,
    String label,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: ElevatedButton.icon(
          onPressed: onPressed,
          icon: Icon(icon, size: 20),
          label: Text(
            label,
            style: const TextStyle(fontSize: 12),
            textAlign: TextAlign.center,
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _launchWhatsApp(
    BuildContext context,
    AppLocalizations l10n,
  ) async {
    final phoneNumber = '+237674667234';
    final message = Uri.encodeComponent(
      '${l10n.thankYouMessage}\n\n${l10n.supportMessage}',
    );
    final whatsappUrl = 'https://wa.me/$phoneNumber?text=$message';

    if (!context.mounted) return;
    _showLoadingSnackBar(context, l10n.openingWhatsApp);

    try {
      final uri = Uri.parse(whatsappUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          _showErrorSnackBar(context, l10n.couldNotLaunch('WhatsApp'));
        }
      }
    } catch (e) {
      if (context.mounted) {
        _showErrorSnackBar(context, l10n.couldNotLaunch('WhatsApp'));
      }
    }
  }

  Future<void> _launchPhoneCall(
    BuildContext context,
    AppLocalizations l10n,
  ) async {
    final phoneNumber = '+237674667234';
    final phoneUrl = 'tel:$phoneNumber';

    if (!context.mounted) return;
    _showLoadingSnackBar(context, l10n.openingPhone);

    try {
      final uri = Uri.parse(phoneUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        if (context.mounted) {
          _showErrorSnackBar(
            context,
            l10n.couldNotLaunch(l10n.phoneCallContact),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        _showErrorSnackBar(context, l10n.couldNotLaunch(l10n.phoneCallContact));
      }
    }
  }

  Future<void> _launchSMS(BuildContext context, AppLocalizations l10n) async {
    final phoneNumber = '+237674667234';
    final message = Uri.encodeComponent(
      '${l10n.thankYouMessage}\n\n${l10n.supportMessage}',
    );
    final smsUrl = 'sms:$phoneNumber?body=$message';

    if (!context.mounted) return;
    _showLoadingSnackBar(context, l10n.openingSMS);

    try {
      final uri = Uri.parse(smsUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        if (context.mounted) {
          _showErrorSnackBar(context, l10n.couldNotLaunch('SMS'));
        }
      }
    } catch (e) {
      if (context.mounted) {
        _showErrorSnackBar(context, l10n.couldNotLaunch('SMS'));
      }
    }
  }

  void _showLoadingSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.blue,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showLicenseDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.gavel, size: 32, color: Colors.red),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                l10n.licenseRestrictions,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildLicenseItem(
                l10n.personalUseOnly,
                l10n.personalUseDescription,
                Icons.person,
                Colors.green,
              ),
              const SizedBox(height: 16),
              _buildLicenseItem(
                l10n.commercialProhibited,
                l10n.commercialDescription,
                Icons.business,
                Colors.red,
              ),
              const SizedBox(height: 16),
              _buildLicenseItem(
                l10n.modificationRestricted,
                l10n.modificationDescription,
                Icons.code,
                Colors.orange,
              ),
              const SizedBox(height: 16),
              _buildLicenseItem(
                l10n.supportRequired,
                l10n.supportRequiredDescription,
                Icons.favorite,
                Colors.pink,
              ),
              const SizedBox(height: 16),
              _buildLicenseItem(
                l10n.licenseViolation,
                l10n.licenseViolationDescription,
                Icons.warning,
                Colors.red,
              ),
              const SizedBox(height: 16),
              _buildLicenseItem(
                l10n.contactForCommercial,
                l10n.contactForCommercialDescription,
                Icons.email,
                Colors.blue,
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Text(
                  l10n.agreeToTerms,
                  style: const TextStyle(
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.understandRestrictions),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _showBuyMeCoffeeDialog(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.brown,
              foregroundColor: Colors.white,
            ),
            child: Text(l10n.contactForCommercial.split(' ')[0]), // "Contact"
          ),
        ],
      ),
    );
  }

  Widget _buildLicenseItem(
    String title,
    String description,
    IconData icon,
    Color color,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: color,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(description, style: const TextStyle(fontSize: 12)),
            ],
          ),
        ),
      ],
    );
  }
}
