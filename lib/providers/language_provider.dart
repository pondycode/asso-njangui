import 'package:flutter/material.dart';
import '../services/database_service.dart';

class LanguageProvider extends ChangeNotifier {
  static const String _languageKey = 'selected_language';
  static const String _defaultLanguage = 'fr'; // Default to French
  
  final DatabaseService _db = DatabaseService.instance;
  
  Locale _currentLocale = const Locale(_defaultLanguage);
  
  Locale get currentLocale => _currentLocale;
  
  String get currentLanguageCode => _currentLocale.languageCode;
  
  bool get isFrench => _currentLocale.languageCode == 'fr';
  bool get isEnglish => _currentLocale.languageCode == 'en';
  
  /// Initialize the language provider and load saved language preference
  Future<void> initialize() async {
    await _loadSavedLanguage();
  }
  
  /// Load the saved language preference from database
  Future<void> _loadSavedLanguage() async {
    try {
      final savedLanguage = await _db.getSetting<String>(_languageKey);
      if (savedLanguage != null && (savedLanguage == 'en' || savedLanguage == 'fr')) {
        _currentLocale = Locale(savedLanguage);
        notifyListeners();
      }
    } catch (e) {
      // If there's an error loading the saved language, use default
      _currentLocale = const Locale(_defaultLanguage);
    }
  }
  
  /// Change the current language and save the preference
  Future<void> changeLanguage(String languageCode) async {
    if (languageCode != 'en' && languageCode != 'fr') {
      throw ArgumentError('Unsupported language code: $languageCode');
    }
    
    if (_currentLocale.languageCode != languageCode) {
      _currentLocale = Locale(languageCode);
      await _saveLanguagePreference(languageCode);
      notifyListeners();
    }
  }
  
  /// Toggle between French and English
  Future<void> toggleLanguage() async {
    final newLanguage = _currentLocale.languageCode == 'fr' ? 'en' : 'fr';
    await changeLanguage(newLanguage);
  }
  
  /// Save the language preference to database
  Future<void> _saveLanguagePreference(String languageCode) async {
    try {
      await _db.saveSetting(_languageKey, languageCode);
    } catch (e) {
      // Handle error silently - the language change will still work for this session
      debugPrint('Failed to save language preference: $e');
    }
  }
  
  /// Get the display name for the current language
  String getCurrentLanguageDisplayName() {
    switch (_currentLocale.languageCode) {
      case 'fr':
        return 'Français';
      case 'en':
        return 'English';
      default:
        return 'Français';
    }
  }
  
  /// Get the display name for the other language (for toggle button)
  String getOtherLanguageDisplayName() {
    switch (_currentLocale.languageCode) {
      case 'fr':
        return 'English';
      case 'en':
        return 'Français';
      default:
        return 'English';
    }
  }
}
