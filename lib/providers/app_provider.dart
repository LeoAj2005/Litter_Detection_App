import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart'; // REQUIRED for ChangeNotifier & Theme
import 'package:path_provider/path_provider.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/api_service.dart';
import '../services/notification_service.dart';

class AppProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  final NotificationService _notifService = NotificationService();
  final AudioPlayer _audioPlayer = AudioPlayer();

  // ================= SETTINGS =================

  String? _customAudioPath;
  String? _saveDirectory;
  int _pollingInterval = 5; // Default 5 seconds
  bool _autoSaveEnabled = true; // Default On

  // 🔥 NEW: Theme State
  bool _isDarkMode = false;

  // ================= LIVE STATE =================

  Timer? _timer;
  bool _isLive = false;
  Uint8List? _currentImage;
  int _lastStatusCode = 0;
  String _statusMessage = "Ready";

  // ================= LOCAL STATE =================

  List<FileSystemEntity> _savedImages = [];

  // ================= GETTERS =================

  bool get isLive => _isLive;
  Uint8List? get currentImage => _currentImage;
  int get lastStatusCode => _lastStatusCode;
  String get statusMessage => _statusMessage;
  List<FileSystemEntity> get savedImages => _savedImages;
  String? get customAudioPath => _customAudioPath;
  String? get saveDirectory => _saveDirectory;
  int get pollingInterval => _pollingInterval;
  bool get autoSaveEnabled => _autoSaveEnabled;

  // 🔥 NEW: Theme Getter
  bool get isDarkMode => _isDarkMode;

  AppProvider() {
    _loadSettings();
    _notifService.init();
  }

  // ================= LOAD SETTINGS =================

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    // 🔥 Load Theme
    _isDarkMode = prefs.getBool('is_dark_mode') ?? false;

    _customAudioPath = prefs.getString('audio_path');
    _pollingInterval = prefs.getInt('polling_interval') ?? 5;
    _autoSaveEnabled = prefs.getBool('auto_save') ?? true;

    // Use External Storage on Android
    if (Platform.isAndroid) {
      final dir = await getExternalStorageDirectory();
      _saveDirectory = dir?.path;
    } else {
      final dir = await getApplicationDocumentsDirectory();
      _saveDirectory = dir.path;
    }

    await _refreshLocalFiles();
    notifyListeners();
  }

  // ================= THEME LOGIC =================

  Future<void> toggleTheme(bool isDark) async {
    _isDarkMode = isDark;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_dark_mode', isDark);
    notifyListeners();
  }

  // ================= SETTINGS LOGIC =================

  Future<void> setPollingInterval(int seconds) async {
    _pollingInterval = seconds;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('polling_interval', seconds);

    if (_isLive) {
      _stopPolling();
      _startPolling();
    }
    notifyListeners();
  }

  Future<void> toggleAutoSave(bool value) async {
    _autoSaveEnabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('auto_save', value);
    notifyListeners();
  }

  Future<void> setCustomAudio(String path) async {
    _customAudioPath = path;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('audio_path', path);
    notifyListeners();
  }

  // ================= LIVE MODE =================

  void toggleLiveMode(bool active) {
    _isLive = active;
    if (_isLive) {
      _startPolling();
    } else {
      _stopPolling();
    }
    notifyListeners();
  }

  void _startPolling() {
    _fetchAndProcess();
    _timer = Timer.periodic(
      Duration(seconds: _pollingInterval),
      (_) => _fetchAndProcess(),
    );
  }

  void _stopPolling() {
    _timer?.cancel();
    _statusMessage = "Paused";
    notifyListeners();
  }

  Future<void> _fetchAndProcess() async {
    _statusMessage = "Fetching...";
    notifyListeners();

    final response = await _apiService.fetchLatestImage();
    _lastStatusCode = response.statusCode;

    if (response.statusCode == 200 && response.imageData != null) {
      _currentImage = response.imageData;
      _statusMessage = "Litter Detected (200 OK)";

      if (_autoSaveEnabled) {
        await _saveImageLocally(response.imageData!);
      }

      _notifService.showNotification(
        "Litter Detected",
        "New violation captured",
      );
      _playAlarm();
    } else {
      _statusMessage = response.errorMessage ?? "Error $_lastStatusCode";
    }

    notifyListeners();
  }

  Future<void> _playAlarm() async {
    try {
      if (_customAudioPath != null) {
        await _audioPlayer.play(DeviceFileSource(_customAudioPath!));
      }
    } catch (e) {
      debugPrint("Audio Error: $e");
    }
  }

  // ================= LOCAL STORAGE =================

  Future<void> _saveImageLocally(Uint8List bytes) async {
    if (_saveDirectory == null) return;

    final timestamp =
        DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final file = File('$_saveDirectory/litter_$timestamp.jpg');

    await file.writeAsBytes(bytes);
    await _refreshLocalFiles();
  }

  Future<void> deleteImage(File file) async {
    try {
      if (await file.exists()) {
        await file.delete();
        await _refreshLocalFiles();
      }
    } catch (e) {
      debugPrint("Error deleting file: $e");
    }
  }

  Future<void> _refreshLocalFiles() async {
    if (_saveDirectory == null) return;

    final dir = Directory(_saveDirectory!);
    if (await dir.exists()) {
      final files = dir
          .listSync()
          .where((e) => e.path.endsWith('.jpg'))
          .toList();

      files.sort(
        (a, b) =>
            b.statSync().modified.compareTo(a.statSync().modified),
      );

      _savedImages = files;
      notifyListeners();
    }
  }
}
