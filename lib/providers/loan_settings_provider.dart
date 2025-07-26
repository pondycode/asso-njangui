import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import '../models/loan_settings.dart';

class LoanSettingsProvider extends ChangeNotifier {
  static const String _boxName = 'loan_settings';
  static const String _settingsKey = 'current_settings';

  LoanSettings _settings = LoanSettings.defaultSettings();
  bool _isLoading = false;
  String? _error;

  LoanSettings get settings => _settings;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Singleton pattern
  static final LoanSettingsProvider _instance =
      LoanSettingsProvider._internal();
  factory LoanSettingsProvider() => _instance;
  LoanSettingsProvider._internal();

  /// Initialize the provider and load settings from storage
  Future<void> initialize() async {
    _setLoading(true);
    try {
      await _loadSettings();
      _clearError();
    } catch (e) {
      _setError('Failed to initialize loan settings: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Load settings from Hive storage
  Future<void> _loadSettings() async {
    try {
      // Add retry logic for box opening
      Box<LoanSettings>? box;
      for (int i = 0; i < 3; i++) {
        try {
          box = await Hive.openBox<LoanSettings>(_boxName);
          break;
        } catch (e) {
          if (i == 2) rethrow; // Last attempt, rethrow the error
          await Future.delayed(Duration(milliseconds: 100 * (i + 1)));
        }
      }

      if (box == null) {
        throw Exception('Failed to open loan settings box after retries');
      }

      final savedSettings = box.get(_settingsKey);

      if (savedSettings != null) {
        _settings = savedSettings;
      } else {
        // First time - save default settings
        await _saveSettings(_settings);
      }
    } catch (e) {
      debugPrint('Failed to load loan settings, using defaults: $e');
      // Don't throw, just use default settings
      _settings = LoanSettings.defaultSettings();
    }
  }

  /// Save settings to Hive storage
  Future<void> _saveSettings(LoanSettings settings) async {
    try {
      // Add retry logic for box opening
      Box<LoanSettings>? box;
      for (int i = 0; i < 3; i++) {
        try {
          box = await Hive.openBox<LoanSettings>(_boxName);
          break;
        } catch (e) {
          if (i == 2) rethrow; // Last attempt, rethrow the error
          await Future.delayed(Duration(milliseconds: 100 * (i + 1)));
        }
      }

      if (box == null) {
        throw Exception('Failed to open loan settings box after retries');
      }

      await box.put(_settingsKey, settings);
    } catch (e) {
      debugPrint('Failed to save loan settings: $e');
      throw Exception('Failed to save loan settings: $e');
    }
  }

  /// Update loan settings
  Future<bool> updateSettings({
    double? monthlyInterestRatePercentage,
    double? minimumInterestRatePercentage,
    double? maximumInterestRatePercentage,
    bool? allowCustomRates,
    int? minimumLoanTermMonths,
    int? maximumLoanTermMonths,
    double? maxLoanToContributionRatio,
    int? minimumContributionMonths,
    String? updatedBy,
  }) async {
    _setLoading(true);
    try {
      // Validate settings
      final newSettings = _settings.copyWith(
        monthlyInterestRatePercentage: monthlyInterestRatePercentage,
        minimumInterestRatePercentage: minimumInterestRatePercentage,
        maximumInterestRatePercentage: maximumInterestRatePercentage,
        allowCustomRates: allowCustomRates,
        minimumLoanTermMonths: minimumLoanTermMonths,
        maximumLoanTermMonths: maximumLoanTermMonths,
        maxLoanToContributionRatio: maxLoanToContributionRatio,
        minimumContributionMonths: minimumContributionMonths,
        lastUpdated: DateTime.now(),
        updatedBy: updatedBy ?? 'System',
      );

      // Validate the new settings
      final validationError = _validateSettings(newSettings);
      if (validationError != null) {
        _setError(validationError);
        return false;
      }

      // Save and update
      await _saveSettings(newSettings);
      _settings = newSettings;
      _clearError();
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to update settings: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Validate loan settings
  String? _validateSettings(LoanSettings settings) {
    if (settings.monthlyInterestRatePercentage < 0) {
      return 'Monthly interest rate percentage cannot be negative';
    }

    if (settings.minimumInterestRatePercentage < 0) {
      return 'Minimum interest rate percentage cannot be negative';
    }

    if (settings.maximumInterestRatePercentage <
        settings.minimumInterestRatePercentage) {
      return 'Maximum interest rate percentage cannot be less than minimum';
    }

    if (settings.monthlyInterestRatePercentage <
            settings.minimumInterestRatePercentage ||
        settings.monthlyInterestRatePercentage >
            settings.maximumInterestRatePercentage) {
      return 'Monthly interest rate percentage must be between minimum and maximum rates';
    }

    if (settings.minimumLoanTermMonths < 1) {
      return 'Minimum loan term must be at least 1 month';
    }

    if (settings.maximumLoanTermMonths < settings.minimumLoanTermMonths) {
      return 'Maximum loan term cannot be less than minimum';
    }

    if (settings.maxLoanToContributionRatio <= 0) {
      return 'Loan to contribution ratio must be positive';
    }

    if (settings.minimumContributionMonths < 0) {
      return 'Minimum contribution months cannot be negative';
    }

    return null;
  }

  /// Reset settings to default
  Future<bool> resetToDefaults({String? updatedBy}) async {
    return await updateSettings(
      monthlyInterestRatePercentage: 5.0,
      minimumInterestRatePercentage: 1.0,
      maximumInterestRatePercentage: 20.0,
      allowCustomRates: true,
      minimumLoanTermMonths: 1,
      maximumLoanTermMonths: 60,
      maxLoanToContributionRatio: 3.0,
      minimumContributionMonths: 6,
      updatedBy: updatedBy,
    );
  }

  /// Get current monthly interest rate percentage (main method used by loan service)
  double getCurrentMonthlyInterestRatePercentage() {
    return _settings.monthlyInterestRatePercentage;
  }

  /// Calculate monthly interest for a given principal amount
  double calculateMonthlyInterest(double principalAmount) {
    return _settings.calculateMonthlyInterest(principalAmount);
  }

  /// Check if a custom interest rate percentage is allowed and valid
  bool isCustomRatePercentageValid(double ratePercentage) {
    if (!_settings.allowCustomRates) return false;
    return ratePercentage >= _settings.minimumInterestRatePercentage &&
        ratePercentage <= _settings.maximumInterestRatePercentage;
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
