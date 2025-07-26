import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/license_provider.dart';
import '../../models/app_license.dart';

class LicenseActivationScreen extends StatefulWidget {
  const LicenseActivationScreen({super.key});

  @override
  State<LicenseActivationScreen> createState() =>
      _LicenseActivationScreenState();
}

class _LicenseActivationScreenState extends State<LicenseActivationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _licenseCodeController = TextEditingController();
  bool _isActivating = false;

  @override
  void dispose() {
    _licenseCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.licenseActivation),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Consumer<LicenseProvider>(
        builder: (context, licenseProvider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCurrentLicenseCard(context, licenseProvider, l10n),
                const SizedBox(height: 24),
                _buildActivationForm(context, licenseProvider, l10n),
                const SizedBox(height: 24),
                _buildFeaturesList(context, licenseProvider, l10n),
                const SizedBox(height: 24),
                _buildContactSection(context, l10n),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCurrentLicenseCard(
    BuildContext context,
    LicenseProvider provider,
    AppLocalizations l10n,
  ) {
    final licenseInfo = provider.getLicenseInfo();
    final isValid = licenseInfo['valid'] as bool;

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isValid ? Icons.check_circle : Icons.error,
                  color: isValid ? Colors.green : Colors.red,
                  size: 32,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.licenseStatus,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        _getLicenseStatusText(licenseInfo, l10n),
                        style: TextStyle(
                          fontSize: 14,
                          color: isValid ? Colors.green : Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildLicenseDetails(licenseInfo, l10n),
          ],
        ),
      ),
    );
  }

  Widget _buildLicenseDetails(
    Map<String, dynamic> info,
    AppLocalizations l10n,
  ) {
    return Column(
      children: [
        _buildDetailRow(l10n.currentLicense, info['type'] ?? 'None'),
        if (info['code'] != null) _buildDetailRow('Code', info['code']),
        if (info['activationDate'] != null)
          _buildDetailRow(
            l10n.activationDate,
            _formatDate(info['activationDate']),
          ),
        if (info['expirationDate'] != null)
          _buildDetailRow(
            l10n.expirationDate,
            _formatDate(info['expirationDate']),
          ),
        if (info['daysRemaining'] != null)
          _buildDetailRow('Days Remaining', '${info['daysRemaining']} days'),
        _buildDetailRow(l10n.enabledFeatures, '${info['features']} features'),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(value, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildActivationForm(
    BuildContext context,
    LicenseProvider provider,
    AppLocalizations l10n,
  ) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.licenseActivation,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _licenseCodeController,
                decoration: InputDecoration(
                  labelText: l10n.enterLicenseCode,
                  hintText: l10n.licenseCodeHint,
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.vpn_key),
                ),
                textCapitalization: TextCapitalization.characters,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a license code';
                  }
                  if (!AppLicense.isValidLicenseCode(value)) {
                    return l10n.invalidLicenseCode;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isActivating
                      ? null
                      : () => _activateLicense(provider, l10n),
                  icon: _isActivating
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.lock_open),
                  label: Text(l10n.activateLicense),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              if (provider.error != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error, color: Colors.red.shade700),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          provider.error!,
                          style: TextStyle(color: Colors.red.shade700),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeaturesList(
    BuildContext context,
    LicenseProvider provider,
    AppLocalizations l10n,
  ) {
    final currentFeatures = provider.currentLicense?.enabledFeatures ?? [];

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.enabledFeatures,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...FeatureCodes.allFeatures.map((feature) {
              final isEnabled = currentFeatures.contains(feature);
              return ListTile(
                leading: Icon(
                  isEnabled ? Icons.check_circle : Icons.cancel,
                  color: isEnabled ? Colors.green : Colors.grey,
                ),
                title: Text(FeatureCodes.getFeatureName(feature)),
                trailing: isEnabled
                    ? const Icon(Icons.lock_open, color: Colors.green)
                    : const Icon(Icons.lock, color: Colors.grey),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildContactSection(BuildContext context, AppLocalizations l10n) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.local_cafe, color: Colors.brown, size: 24),
                const SizedBox(width: 8),
                Text(
                  l10n.contactForLicense,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Need a license code? Support the developer and get your full license!',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.brown.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.brown.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info, color: Colors.brown.shade700, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'License Pricing',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.brown.shade700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '• Full License: 10,000 CFA (one-time payment)\n'
                    '• Includes all premium features\n'
                    '• Unlimited members and transactions\n'
                    '• Lifetime updates and support',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.brown.shade600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _showBuyMeCoffeeDialog(context),
                icon: const Icon(Icons.local_cafe),
                label: Text(l10n.buyMeACoffee),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.brown,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Back to More Screen'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.brown,
                  side: BorderSide(color: Colors.brown.shade300),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _activateLicense(
    LicenseProvider provider,
    AppLocalizations l10n,
  ) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isActivating = true;
    });

    final success = await provider.activateLicense(
      _licenseCodeController.text.trim(),
    );

    setState(() {
      _isActivating = false;
    });

    if (success) {
      _licenseCodeController.clear();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.licenseActivatedSuccessfully),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  String _getLicenseStatusText(
    Map<String, dynamic> info,
    AppLocalizations l10n,
  ) {
    final type = info['type'] as String;
    final isValid = info['valid'] as bool;

    if (!isValid) return l10n.licenseExpired;

    switch (type.toLowerCase()) {
      case 'trial':
        final days = info['daysRemaining'] as int?;
        return days != null ? l10n.daysRemaining(days) : l10n.trialVersion;
      case 'full':
        return l10n.fullVersion;
      case 'developer':
        return l10n.developerVersion;
      default:
        return 'Unknown';
    }
  }

  String _formatDate(dynamic date) {
    if (date is DateTime) {
      return '${date.day}/${date.month}/${date.year}';
    }
    return date.toString();
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
              Text(
                'To get your full license, please contact the developer with your payment and device information.',
                style: const TextStyle(fontSize: 14),
              ),
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
                  color: Colors.brown.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.brown.shade200),
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
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.vpn_key,
                          color: Colors.green.shade700,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'License Purchase',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Send 10,000 CFA with message: "LICENSE REQUEST" and your device info. You\'ll receive your license code within 24 hours.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.green.shade600,
                      ),
                    ),
                  ],
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
      'Hello! I would like to purchase a full license for the Association Management App. Please send me the license code after payment confirmation.',
    );
    final whatsappUrl = 'https://wa.me/$phoneNumber?text=$message';

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
      'Hello! I want to purchase a full license for the Association Management App. Please send me payment details.',
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
}
