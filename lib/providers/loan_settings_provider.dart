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
  static final LoanSettingsProvider _instance = LoanSettingsProvider._internal();
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
      final box = await Hive.openBox<LoanSettings>(_boxName);
      final savedSettings = box.get(_settingsKey);
      
      if (savedSettings != null) {
        _settings = savedSettings;
      } else {
        // First time - save default settings
        await _saveSettings(_settings);
      }
    } catch (e) {
      throw Exception('Failed to load loan settings: $e');
    }
  }

  /// Save settings to Hive storage
  Future<void> _saveSettings(LoanSettings settings) async {
    try {
      final box = await Hive.openBox<LoanSettings>(_boxName);
      await box.put(_settingsKey, settings);
    } catch (e) {
      throw Exception('Failed to save loan settings: $e');
    }
  }

  /// Update loan settings
  Future<bool> updateSettings({
    double? defaultMonthlyInterestRate,
    double? minimumInterestRate,
    double? maximumInterestRate,
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
        defaultMonthlyInterestRate: defaultMonthlyInterestRate,
        minimumInterestRate: minimumInterestRate,
        maximumInterestRate: maximumInterestRate,
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
    if (settings.defaultMonthlyInterestRate < 0) {
      return 'Default interest rate cannot be negative';
    }

    if (settings.minimumInterestRate < 0) {
      return 'Minimum interest rate cannot be negative';
    }

    if (settings.maximumInterestRate < settings.minimumInterestRate) {
      return 'Maximum interest rate cannot be less than minimum';
    }

    if (settings.defaultMonthlyInterestRate < settings.minimumInterestRate ||
        settings.defaultMonthlyInterestRate > settings.maximumInterestRate) {
      return 'Default interest rate must be between minimum and maximum rates';
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
      defaultMonthlyInterestRate: 3150.0,
      minimumInterestRate: 1000.0,
      maximumInterestRate: 10000.0,
      allowCustomRates: true,
      minimumLoanTermMonths: 1,
      maximumLoanTermMonths: 60,
      maxLoanToContributionRatio: 3.0,
      minimumContributionMonths: 6,
      updatedBy: updatedBy,
    );
  }

  /// Get current monthly interest rate (main method used by loan service)
  double getCurrentMonthlyInterestRate() {
    return _settings.defaultMonthlyInterestRate;
  }

  /// Check if a custom interest rate is allowed and valid
  bool isCustomRateValid(double rate) {
    if (!_settings.allowCustomRates) return false;
    return rate >= _settings.minimumInterestRate && 
           rate <= _settings.maximumInterestRate;
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
