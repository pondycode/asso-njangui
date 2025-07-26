import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';
import '../models/app_license.dart';

class LicenseProvider extends ChangeNotifier {
  static const String _boxName = 'license_box';
  static const String _licenseKey = 'app_license';
  
  AppLicense? _currentLicense;
  bool _isLoading = false;
  String? _error;
  String? _deviceId;

  AppLicense? get currentLicense => _currentLicense;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get deviceId => _deviceId;

  /// Check if app is licensed (has valid license)
  bool get isLicensed => _currentLicense?.isValid ?? false;

  /// Check if app is in trial mode
  bool get isTrialMode => _currentLicense?.licenseType == LicenseType.trial;

  /// Check if app has full license
  bool get hasFullLicense => _currentLicense?.licenseType == LicenseType.full;

  /// Check if app has developer license
  bool get isDeveloperMode => _currentLicense?.licenseType == LicenseType.developer;

  /// Get days remaining for trial
  int? get trialDaysRemaining => _currentLicense?.daysRemaining;

  /// Check if a specific feature is available
  bool hasFeature(String featureCode) {
    return _currentLicense?.hasFeature(featureCode) ?? false;
  }

  /// Initialize license system
  Future<void> initialize() async {
    _setLoading(true);
    try {
      // Get device ID
      _deviceId = await _getDeviceId();
      
      // Load existing license
      await _loadLicense();
      
      // If no license exists, create trial
      if (_currentLicense == null) {
        await _createTrialLicense();
      }
      
      // Validate current license
      await _validateLicense();
      
      _clearError();
    } catch (e) {
      _setError('Failed to initialize license system: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Activate license with code
  Future<bool> activateLicense(String licenseCode) async {
    _setLoading(true);
    try {
      // Validate code format
      if (!AppLicense.isValidLicenseCode(licenseCode)) {
        _setError('Invalid license code format');
        return false;
      }

      // Check if it's a valid activation code
      if (!await _validateActivationCode(licenseCode)) {
        _setError('Invalid or expired license code');
        return false;
      }

      // Create license based on code type
      final licenseType = AppLicense.getLicenseTypeFromCode(licenseCode);
      AppLicense newLicense;

      switch (licenseType) {
        case LicenseType.full:
          newLicense = AppLicense.createFull(licenseCode, _deviceId!);
          break;
        case LicenseType.developer:
          newLicense = _createDeveloperLicense(licenseCode);
          break;
        case LicenseType.trial:
          // Trial codes are auto-generated, shouldn't be manually entered
          _setError('Trial codes cannot be manually activated');
          return false;
      }

      // Save new license
      await _saveLicense(newLicense);
      _currentLicense = newLicense;
      
      _clearError();
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to activate license: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Deactivate current license
  Future<void> deactivateLicense() async {
    _setLoading(true);
    try {
      // Create new trial license
      await _createTrialLicense();
      _clearError();
    } catch (e) {
      _setError('Failed to deactivate license: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Extend trial period (developer only)
  Future<bool> extendTrial(int days) async {
    if (!isDeveloperMode) return false;
    
    if (_currentLicense?.licenseType == LicenseType.trial) {
      final extended = _currentLicense!.copyWith(
        expirationDate: _currentLicense!.expirationDate?.add(Duration(days: days)),
      );
      await _saveLicense(extended);
      _currentLicense = extended;
      notifyListeners();
      return true;
    }
    return false;
  }

  /// Get license information for display
  Map<String, dynamic> getLicenseInfo() {
    if (_currentLicense == null) {
      return {
        'status': 'No License',
        'type': 'None',
        'valid': false,
      };
    }

    return {
      'status': _currentLicense!.isValid ? 'Active' : 'Expired',
      'type': _currentLicense!.licenseType.name.toUpperCase(),
      'code': _currentLicense!.licenseCode,
      'activationDate': _currentLicense!.activationDate,
      'expirationDate': _currentLicense!.expirationDate,
      'daysRemaining': _currentLicense!.daysRemaining,
      'features': _currentLicense!.enabledFeatures.length,
      'valid': _currentLicense!.isValid,
    };
  }

  /// Private methods
  Future<void> _loadLicense() async {
    try {
      final box = await Hive.openBox(_boxName);
      final licenseData = box.get(_licenseKey);
      if (licenseData != null) {
        _currentLicense = AppLicense.fromJson(Map<String, dynamic>.from(licenseData));
      }
    } catch (e) {
      debugPrint('Error loading license: $e');
    }
  }

  Future<void> _saveLicense(AppLicense license) async {
    try {
      final box = await Hive.openBox(_boxName);
      await box.put(_licenseKey, license.toJson());
    } catch (e) {
      debugPrint('Error saving license: $e');
      rethrow;
    }
  }

  Future<void> _createTrialLicense() async {
    if (_deviceId == null) return;
    
    final trialLicense = AppLicense.createTrial(_deviceId!);
    await _saveLicense(trialLicense);
    _currentLicense = trialLicense;
    notifyListeners();
  }

  AppLicense _createDeveloperLicense(String licenseCode) {
    return AppLicense(
      licenseCode: licenseCode,
      licenseType: LicenseType.developer,
      activationDate: DateTime.now(),
      expirationDate: null,
      enabledFeatures: FeatureCodes.developerFeatures,
      deviceId: _deviceId!,
      isActive: true,
      metadata: {
        'developer_mode': true,
        'debug_enabled': true,
      },
    );
  }

  Future<String> _getDeviceId() async {
    try {
      final deviceInfo = DeviceInfoPlugin();
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        return androidInfo.id;
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        return iosInfo.identifierForVendor ?? 'unknown-ios';
      } else {
        return 'unknown-platform';
      }
    } catch (e) {
      return 'device-id-error';
    }
  }

  Future<bool> _validateActivationCode(String code) async {
    // In a real app, this would validate against a server
    // For now, we'll use predefined valid codes
    
    final validCodes = [
      'ASSO-2024-FULL-ACCE',
      'ASSO-2024-PREM-IUMS',
      'DEV-MASTER01',
      'DEV-DEBUG123',
    ];
    
    return validCodes.contains(code);
  }

  Future<void> _validateLicense() async {
    if (_currentLicense != null && !_currentLicense!.isValid) {
      // License expired, create new trial
      await _createTrialLicense();
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }
}
