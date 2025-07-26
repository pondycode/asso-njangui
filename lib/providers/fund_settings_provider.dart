import 'package:flutter/material.dart';
import '../services/database_service.dart';
import '../models/fund.dart';

class FundSettingsProvider extends ChangeNotifier {
  static const String _defaultSavingsAmountKey = 'fund_default_savings_amount';
  static const String _defaultInvestmentAmountKey =
      'fund_default_investment_amount';
  static const String _defaultEmergencyAmountKey =
      'fund_default_emergency_amount';
  static const String _defaultLoanAmountKey = 'fund_default_loan_amount';

  final DatabaseService _db = DatabaseService.instance;

  double _defaultSavingsAmount = 0.0;
  double _defaultInvestmentAmount = 0.0;
  double _defaultEmergencyAmount = 0.0;
  double _defaultLoanAmount = 0.0;

  // Getters
  double get defaultSavingsAmount => _defaultSavingsAmount;
  double get defaultInvestmentAmount => _defaultInvestmentAmount;
  double get defaultEmergencyAmount => _defaultEmergencyAmount;
  double get defaultLoanAmount => _defaultLoanAmount;

  /// Initialize the provider by loading saved settings
  Future<void> initialize() async {
    try {
      // Ensure database is initialized before loading settings
      if (!_db.isInitialized) {
        debugPrint('Database not initialized, skipping fund settings load');
        return;
      }
      await _loadSettings();
    } catch (e) {
      debugPrint('Failed to initialize fund settings: $e');
    }
  }

  /// Load settings from database
  Future<void> _loadSettings() async {
    try {
      final savedSavingsAmount = await _db.getSetting(_defaultSavingsAmountKey);
      if (savedSavingsAmount != null) {
        _defaultSavingsAmount = (savedSavingsAmount as num).toDouble();
      }

      final savedInvestmentAmount = await _db.getSetting(
        _defaultInvestmentAmountKey,
      );
      if (savedInvestmentAmount != null) {
        _defaultInvestmentAmount = (savedInvestmentAmount as num).toDouble();
      }

      final savedEmergencyAmount = await _db.getSetting(
        _defaultEmergencyAmountKey,
      );
      if (savedEmergencyAmount != null) {
        _defaultEmergencyAmount = (savedEmergencyAmount as num).toDouble();
      }

      final savedLoanAmount = await _db.getSetting(_defaultLoanAmountKey);
      if (savedLoanAmount != null) {
        _defaultLoanAmount = (savedLoanAmount as num).toDouble();
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Failed to load fund settings: $e');
    }
  }

  /// Set the default savings amount
  Future<void> setDefaultSavingsAmount(double amount) async {
    try {
      if (!_db.isInitialized) {
        throw Exception('Database not initialized');
      }
      _defaultSavingsAmount = amount;
      await _db.saveSetting(_defaultSavingsAmountKey, amount);
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to save default savings amount: $e');
      rethrow;
    }
  }

  /// Set the default investment amount
  Future<void> setDefaultInvestmentAmount(double amount) async {
    try {
      if (!_db.isInitialized) {
        throw Exception('Database not initialized');
      }
      _defaultInvestmentAmount = amount;
      await _db.saveSetting(_defaultInvestmentAmountKey, amount);
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to save default investment amount: $e');
      rethrow;
    }
  }

  /// Set the default emergency amount
  Future<void> setDefaultEmergencyAmount(double amount) async {
    try {
      if (!_db.isInitialized) {
        throw Exception('Database not initialized');
      }
      _defaultEmergencyAmount = amount;
      await _db.saveSetting(_defaultEmergencyAmountKey, amount);
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to save default emergency amount: $e');
      rethrow;
    }
  }

  /// Set the default loan amount
  Future<void> setDefaultLoanAmount(double amount) async {
    try {
      if (!_db.isInitialized) {
        throw Exception('Database not initialized');
      }
      _defaultLoanAmount = amount;
      await _db.saveSetting(_defaultLoanAmountKey, amount);
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to save default loan amount: $e');
      rethrow;
    }
  }

  /// Get default amount for a specific fund type
  double getDefaultAmountForFund(Fund fund) {
    switch (fund.type) {
      case FundType.savings:
        return _defaultSavingsAmount;
      case FundType.investment:
        return _defaultInvestmentAmount;
      case FundType.emergency:
        return _defaultEmergencyAmount;
      case FundType.loan:
        return _defaultLoanAmount;
    }
  }

  /// Clear all fund settings
  Future<void> clearAllSettings() async {
    try {
      if (!_db.isInitialized) {
        throw Exception('Database not initialized');
      }

      await Future.wait([
        _db.deleteSetting(_defaultSavingsAmountKey),
        _db.deleteSetting(_defaultInvestmentAmountKey),
        _db.deleteSetting(_defaultEmergencyAmountKey),
        _db.deleteSetting(_defaultLoanAmountKey),
      ]);

      _defaultSavingsAmount = 0.0;
      _defaultInvestmentAmount = 0.0;
      _defaultEmergencyAmount = 0.0;
      _defaultLoanAmount = 0.0;

      notifyListeners();
    } catch (e) {
      debugPrint('Failed to clear fund settings: $e');
      rethrow;
    }
  }
}
