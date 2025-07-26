import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../providers/license_provider.dart';
import '../screens/settings/license_activation_screen.dart';

/// Widget that wraps features and shows restriction dialog if not licensed
class FeatureRestrictionWidget extends StatelessWidget {
  final String featureCode;
  final Widget child;
  final String? customMessage;
  final bool showUpgradeButton;

  const FeatureRestrictionWidget({
    super.key,
    required this.featureCode,
    required this.child,
    this.customMessage,
    this.showUpgradeButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<LicenseProvider>(
      builder: (context, licenseProvider, _) {
        final hasFeature = licenseProvider.hasFeature(featureCode);

        if (hasFeature) {
          return child;
        }

        // Feature is restricted - wrap with GestureDetector to show dialog
        return GestureDetector(
          onTap: () => _showRestrictionDialog(context, licenseProvider),
          child: Stack(
            children: [
              // Disabled/grayed out child
              Opacity(opacity: 0.5, child: AbsorbPointer(child: child)),
              // Lock overlay
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: Icon(Icons.lock, size: 32, color: Colors.red),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showRestrictionDialog(
    BuildContext context,
    LicenseProvider licenseProvider,
  ) {
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.lock, color: Colors.red, size: 32),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                l10n.featureRestricted,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              customMessage ?? l10n.featureRestrictedMessage,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            _buildLicenseStatusCard(context, licenseProvider, l10n),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          if (showUpgradeButton) ...[
            OutlinedButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LicenseActivationScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.local_cafe),
              label: Text(l10n.buyMeACoffee),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.brown,
                side: const BorderSide(color: Colors.brown),
              ),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LicenseActivationScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.upgrade),
              label: Text(l10n.upgradeToFull),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLicenseStatusCard(
    BuildContext context,
    LicenseProvider provider,
    AppLocalizations l10n,
  ) {
    final licenseInfo = provider.getLicenseInfo();
    final isValid = licenseInfo['valid'] as bool;
    final type = licenseInfo['type'] as String;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isValid ? Colors.blue.shade50 : Colors.red.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isValid ? Colors.blue.shade200 : Colors.red.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isValid ? Icons.info : Icons.warning,
                color: isValid ? Colors.blue : Colors.red,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                l10n.licenseStatus,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _getLicenseStatusDescription(type, licenseInfo, l10n),
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }

  String _getLicenseStatusDescription(
    String type,
    Map<String, dynamic> info,
    AppLocalizations l10n,
  ) {
    switch (type.toLowerCase()) {
      case 'trial':
        final days = info['daysRemaining'] as int?;
        if (days != null && days > 0) {
          return '${l10n.trialVersion} - ${l10n.daysRemaining(days)}';
        } else {
          return l10n.trialExpiredMessage;
        }
      case 'full':
        return '${l10n.fullVersion} - ${l10n.unlimitedAccess}';
      case 'developer':
        return '${l10n.developerVersion} - ${l10n.unlimitedAccess}';
      default:
        return 'No valid license';
    }
  }
}

/// Compact widget for showing trial limitations
class TrialLimitationBanner extends StatefulWidget {
  final String? customMessage;

  const TrialLimitationBanner({super.key, this.customMessage});

  @override
  State<TrialLimitationBanner> createState() => _TrialLimitationBannerState();
}

class _TrialLimitationBannerState extends State<TrialLimitationBanner> {
  bool _isDismissed = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (_isDismissed) {
      return const SizedBox.shrink();
    }

    return Consumer<LicenseProvider>(
      builder: (context, licenseProvider, child) {
        if (!licenseProvider.isTrialMode) {
          return const SizedBox.shrink();
        }

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.orange.shade50,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: Colors.orange.shade200, width: 0.5),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: Colors.orange.shade700, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.customMessage ?? l10n.trialLimitationsMessage,
                  style: TextStyle(fontSize: 11, color: Colors.orange.shade700),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LicenseActivationScreen(),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.local_cafe,
                        size: 12,
                        color: Colors.orange.shade800,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Upgrade',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange.shade800,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 4),
              InkWell(
                onTap: () {
                  setState(() {
                    _isDismissed = true;
                  });
                },
                child: Icon(
                  Icons.close,
                  size: 14,
                  color: Colors.orange.shade600,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Ultra-compact trial banner for minimal screen space usage
class CompactTrialBanner extends StatefulWidget {
  const CompactTrialBanner({super.key});

  @override
  State<CompactTrialBanner> createState() => _CompactTrialBannerState();
}

class _CompactTrialBannerState extends State<CompactTrialBanner> {
  bool _isDismissed = false;

  @override
  Widget build(BuildContext context) {
    if (_isDismissed) {
      return const SizedBox.shrink();
    }

    return Consumer<LicenseProvider>(
      builder: (context, licenseProvider, child) {
        if (!licenseProvider.isTrialMode) {
          return const SizedBox.shrink();
        }

        final daysLeft = licenseProvider.trialDaysRemaining ?? 0;

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          color: Colors.orange.shade100,
          child: Row(
            children: [
              Icon(Icons.schedule, size: 14, color: Colors.orange.shade800),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Trial: $daysLeft days left',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.orange.shade800,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LicenseActivationScreen(),
                    ),
                  );
                },
                child: Text(
                  'Upgrade',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.orange.shade900,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: () {
                  setState(() {
                    _isDismissed = true;
                  });
                },
                child: Icon(
                  Icons.close,
                  size: 12,
                  color: Colors.orange.shade700,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Widget that completely hides features if not licensed
class FeatureGate extends StatelessWidget {
  final String featureCode;
  final Widget child;
  final Widget? fallback;

  const FeatureGate({
    super.key,
    required this.featureCode,
    required this.child,
    this.fallback,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<LicenseProvider>(
      builder: (context, licenseProvider, _) {
        final hasFeature = licenseProvider.hasFeature(featureCode);

        if (hasFeature) {
          return child;
        }

        return fallback ?? const SizedBox.shrink();
      },
    );
  }
}

/// Mixin for screens that need license checking
mixin LicenseCheckMixin<T extends StatefulWidget> on State<T> {
  bool checkFeatureAccess(String featureCode) {
    final licenseProvider = Provider.of<LicenseProvider>(
      context,
      listen: false,
    );
    return licenseProvider.hasFeature(featureCode);
  }

  void showFeatureRestrictionDialog(
    String featureCode, {
    String? customMessage,
  }) {
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.lock, color: Colors.red),
            const SizedBox(width: 8),
            Text(l10n.featureRestricted),
          ],
        ),
        content: Text(customMessage ?? l10n.featureRestrictedMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const LicenseActivationScreen(),
                ),
              );
            },
            child: Text(l10n.upgradeToFull),
          ),
        ],
      ),
    );
  }

  void requireFeatureAccess(
    String featureCode,
    VoidCallback onAccess, {
    String? customMessage,
  }) {
    if (checkFeatureAccess(featureCode)) {
      onAccess();
    } else {
      showFeatureRestrictionDialog(featureCode, customMessage: customMessage);
    }
  }
}
