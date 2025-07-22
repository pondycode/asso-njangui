import 'package:flutter/material.dart';
import '../services/database_service.dart';
import '../models/member.dart';

class ContributionSettingsProvider extends ChangeNotifier {
  static const String _defaultDateKey = 'contribution_default_date';
  static const String _defaultHostIdKey = 'contribution_default_host_id';
  static const String _useTodayAsDefaultKey = 'contribution_use_today_as_default';
  
  final DatabaseService _db = DatabaseService.instance;
  
  DateTime? _defaultDate;
  String? _defaultHostId;
  bool _useTodayAsDefault = true;
  
  // Getters
  DateTime? get defaultDate => _defaultDate;
  String? get defaultHostId => _defaultHostId;
  bool get useTodayAsDefault => _useTodayAsDefault;
  
  /// Get the effective default date (either saved date or today if useTodayAsDefault is true)
  DateTime get effectiveDefaultDate {
    if (_useTodayAsDefault) {
      return DateTime.now();
    }
    return _defaultDate ?? DateTime.now();
  }
  
  /// Initialize the provider and load saved settings
  Future<void> initialize() async {
    await _loadSettings();
  }
  
  /// Load saved settings from database
  Future<void> _loadSettings() async {
    try {
      // Load default date setting
      final savedDateMillis = await _db.getSetting<int>(_defaultDateKey);
      if (savedDateMillis != null) {
        _defaultDate = DateTime.fromMillisecondsSinceEpoch(savedDateMillis);
      }
      
      // Load default host ID
      _defaultHostId = await _db.getSetting<String>(_defaultHostIdKey);
      
      // Load use today as default setting
      final useTodayValue = await _db.getSetting<bool>(_useTodayAsDefaultKey);
      if (useTodayValue != null) {
        _useTodayAsDefault = useTodayValue;
      }
      
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to load contribution settings: $e');
    }
  }
  
  /// Set the default date for contributions
  Future<void> setDefaultDate(DateTime? date) async {
    try {
      _defaultDate = date;
      
      if (date != null) {
        await _db.saveSetting(_defaultDateKey, date.millisecondsSinceEpoch);
      } else {
        await _db.deleteSetting(_defaultDateKey);
      }
      
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to save default date: $e');
    }
  }
  
  /// Set the default host for contributions
  Future<void> setDefaultHost(Member? host) async {
    try {
      _defaultHostId = host?.id;
      
      if (host != null) {
        await _db.saveSetting(_defaultHostIdKey, host.id);
      } else {
        await _db.deleteSetting(_defaultHostIdKey);
      }
      
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to save default host: $e');
    }
  }
  
  /// Set whether to use today as default date
  Future<void> setUseTodayAsDefault(bool useToday) async {
    try {
      _useTodayAsDefault = useToday;
      await _db.saveSetting(_useTodayAsDefaultKey, useToday);
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to save use today setting: $e');
    }
  }
  
  /// Clear all default settings
  Future<void> clearAllDefaults() async {
    try {
      await Future.wait([
        _db.deleteSetting(_defaultDateKey),
        _db.deleteSetting(_defaultHostIdKey),
        _db.deleteSetting(_useTodayAsDefaultKey),
      ]);
      
      _defaultDate = null;
      _defaultHostId = null;
      _useTodayAsDefault = true;
      
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to clear default settings: $e');
    }
  }
  
  /// Get default host member object from app state
  Member? getDefaultHost(List<Member> members) {
    if (_defaultHostId == null) return null;
    
    try {
      return members.firstWhere((member) => member.id == _defaultHostId);
    } catch (e) {
      return null;
    }
  }
  
  /// Check if any defaults are set
  bool get hasDefaults {
    return _defaultHostId != null || (!_useTodayAsDefault && _defaultDate != null);
  }
}
