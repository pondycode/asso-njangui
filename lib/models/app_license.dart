import 'package:hive/hive.dart';
import 'package:equatable/equatable.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

part 'app_license.g.dart';

@HiveType(typeId: 10)
class AppLicense extends Equatable {
  @HiveField(0)
  final String licenseCode;

  @HiveField(1)
  final LicenseType licenseType;

  @HiveField(2)
  final DateTime activationDate;

  @HiveField(3)
  final DateTime? expirationDate;

  @HiveField(4)
  final List<String> enabledFeatures;

  @HiveField(5)
  final String deviceId;

  @HiveField(6)
  final bool isActive;

  @HiveField(7)
  final Map<String, dynamic> metadata;

  const AppLicense({
    required this.licenseCode,
    required this.licenseType,
    required this.activationDate,
    this.expirationDate,
    required this.enabledFeatures,
    required this.deviceId,
    this.isActive = true,
    this.metadata = const {},
  });

  /// Check if license is currently valid
  bool get isValid {
    if (!isActive) return false;
    if (expirationDate != null && DateTime.now().isAfter(expirationDate!)) {
      return false;
    }
    return true;
  }

  /// Check if a specific feature is enabled
  bool hasFeature(String featureCode) {
    return isValid && enabledFeatures.contains(featureCode);
  }

  /// Get days remaining until expiration
  int? get daysRemaining {
    if (expirationDate == null) return null;
    final now = DateTime.now();
    if (now.isAfter(expirationDate!)) return 0;
    return expirationDate!.difference(now).inDays;
  }

  /// Create trial license (30 days)
  factory AppLicense.createTrial(String deviceId) {
    final now = DateTime.now();
    final trialCode = _generateTrialCode(deviceId, now);
    
    return AppLicense(
      licenseCode: trialCode,
      licenseType: LicenseType.trial,
      activationDate: now,
      expirationDate: now.add(const Duration(days: 30)),
      enabledFeatures: FeatureCodes.trialFeatures,
      deviceId: deviceId,
      isActive: true,
      metadata: {
        'trial_days': 30,
        'created_automatically': true,
      },
    );
  }

  /// Create full license
  factory AppLicense.createFull(String licenseCode, String deviceId) {
    return AppLicense(
      licenseCode: licenseCode,
      licenseType: LicenseType.full,
      activationDate: DateTime.now(),
      expirationDate: null, // No expiration for full license
      enabledFeatures: FeatureCodes.allFeatures,
      deviceId: deviceId,
      isActive: true,
      metadata: {
        'license_level': 'full',
        'unlimited_access': true,
      },
    );
  }

  /// Generate trial code based on device ID and date
  static String _generateTrialCode(String deviceId, DateTime date) {
    final input = '$deviceId-${date.millisecondsSinceEpoch}';
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return 'TRIAL-${digest.toString().substring(0, 8).toUpperCase()}';
  }

  /// Validate license code format and authenticity
  static bool isValidLicenseCode(String code) {
    if (code.isEmpty) return false;
    
    // Trial codes
    if (code.startsWith('TRIAL-')) {
      return code.length == 14 && RegExp(r'^TRIAL-[A-F0-9]{8}$').hasMatch(code);
    }
    
    // Full license codes (format: ASSO-XXXX-XXXX-XXXX)
    if (code.startsWith('ASSO-')) {
      return RegExp(r'^ASSO-[A-Z0-9]{4}-[A-Z0-9]{4}-[A-Z0-9]{4}$').hasMatch(code);
    }
    
    // Developer codes
    if (code.startsWith('DEV-')) {
      return RegExp(r'^DEV-[A-Z0-9]{8}$').hasMatch(code);
    }
    
    return false;
  }

  /// Determine license type from code
  static LicenseType getLicenseTypeFromCode(String code) {
    if (code.startsWith('TRIAL-')) return LicenseType.trial;
    if (code.startsWith('DEV-')) return LicenseType.developer;
    if (code.startsWith('ASSO-')) return LicenseType.full;
    return LicenseType.trial;
  }

  AppLicense copyWith({
    String? licenseCode,
    LicenseType? licenseType,
    DateTime? activationDate,
    DateTime? expirationDate,
    List<String>? enabledFeatures,
    String? deviceId,
    bool? isActive,
    Map<String, dynamic>? metadata,
  }) {
    return AppLicense(
      licenseCode: licenseCode ?? this.licenseCode,
      licenseType: licenseType ?? this.licenseType,
      activationDate: activationDate ?? this.activationDate,
      expirationDate: expirationDate ?? this.expirationDate,
      enabledFeatures: enabledFeatures ?? this.enabledFeatures,
      deviceId: deviceId ?? this.deviceId,
      isActive: isActive ?? this.isActive,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  List<Object?> get props => [
        licenseCode,
        licenseType,
        activationDate,
        expirationDate,
        enabledFeatures,
        deviceId,
        isActive,
        metadata,
      ];

  Map<String, dynamic> toJson() {
    return {
      'licenseCode': licenseCode,
      'licenseType': licenseType.name,
      'activationDate': activationDate.toIso8601String(),
      'expirationDate': expirationDate?.toIso8601String(),
      'enabledFeatures': enabledFeatures,
      'deviceId': deviceId,
      'isActive': isActive,
      'metadata': metadata,
    };
  }

  factory AppLicense.fromJson(Map<String, dynamic> json) {
    return AppLicense(
      licenseCode: json['licenseCode'] ?? '',
      licenseType: LicenseType.values.firstWhere(
        (e) => e.name == json['licenseType'],
        orElse: () => LicenseType.trial,
      ),
      activationDate: DateTime.parse(json['activationDate']),
      expirationDate: json['expirationDate'] != null
          ? DateTime.parse(json['expirationDate'])
          : null,
      enabledFeatures: List<String>.from(json['enabledFeatures'] ?? []),
      deviceId: json['deviceId'] ?? '',
      isActive: json['isActive'] ?? false,
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
    );
  }

  @override
  String toString() {
    return 'AppLicense(code: $licenseCode, type: $licenseType, valid: $isValid)';
  }
}

@HiveType(typeId: 11)
enum LicenseType {
  @HiveField(0)
  trial,
  @HiveField(1)
  full,
  @HiveField(2)
  developer,
}

/// Feature codes for different app functionalities
class FeatureCodes {
  // Core features (always available)
  static const String memberManagement = 'MEMBER_MGMT';
  static const String basicContributions = 'BASIC_CONTRIB';
  static const String basicReports = 'BASIC_REPORTS';

  // Premium features (require full license)
  static const String loanManagement = 'LOAN_MGMT';
  static const String advancedReports = 'ADV_REPORTS';
  static const String dataExport = 'DATA_EXPORT';
  static const String multiCurrency = 'MULTI_CURRENCY';
  static const String penalties = 'PENALTIES';
  static const String bulkOperations = 'BULK_OPS';

  // Developer features
  static const String debugMode = 'DEBUG_MODE';
  static const String apiAccess = 'API_ACCESS';

  /// Features available in trial version
  static const List<String> trialFeatures = [
    memberManagement,
    basicContributions,
    basicReports,
    loanManagement, // Limited loan functionality
  ];

  /// All features available in full version
  static const List<String> allFeatures = [
    memberManagement,
    basicContributions,
    basicReports,
    loanManagement,
    advancedReports,
    dataExport,
    multiCurrency,
    penalties,
    bulkOperations,
  ];

  /// Developer-only features
  static const List<String> developerFeatures = [
    ...allFeatures,
    debugMode,
    apiAccess,
  ];

  /// Get feature display name
  static String getFeatureName(String code) {
    switch (code) {
      case memberManagement:
        return 'Member Management';
      case basicContributions:
        return 'Basic Contributions';
      case basicReports:
        return 'Basic Reports';
      case loanManagement:
        return 'Loan Management';
      case advancedReports:
        return 'Advanced Reports';
      case dataExport:
        return 'Data Export';
      case multiCurrency:
        return 'Multi-Currency';
      case penalties:
        return 'Penalties & Fines';
      case bulkOperations:
        return 'Bulk Operations';
      case debugMode:
        return 'Debug Mode';
      case apiAccess:
        return 'API Access';
      default:
        return 'Unknown Feature';
    }
  }
}
