import 'package:flutter/material.dart';

class ProfileProvider extends ChangeNotifier {
  String _name = 'Ramesh Patel';
  String _village = 'Ranpur, Gujarat';
  String _farmSize = '4.5 Acres';
  String _language = 'English';
  String? _photoPath;
  bool _notificationsEnabled = true;

  String get name => _name;
  String get village => _village;
  String get farmSize => _farmSize;
  String get language => _language;
  String? get photoPath => _photoPath;
  bool get notificationsEnabled => _notificationsEnabled;

  void updateProfile({
    required String name,
    required String village,
    required String farmSize,
  }) {
    _name = name;
    _village = village;
    _farmSize = farmSize;
    notifyListeners();
  }

  void updateLanguage(String lang) {
    _language = lang;
    notifyListeners();
  }

  void updatePhoto(String? path) {
    _photoPath = path;
    notifyListeners();
  }

  void toggleNotifications(bool isOn) {
    _notificationsEnabled = isOn;
    notifyListeners();
  }
}
