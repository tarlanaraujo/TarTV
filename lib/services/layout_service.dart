import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LayoutService extends ChangeNotifier {
  static const String _columnsKey = 'grid_columns';
  static const String _autoDownloadKey = 'auto_download';
  static const String _downloadQualityKey = 'download_quality';
  
  int _gridColumns = 2;
  bool _autoDownload = false;
  String _downloadQuality = 'HD';
  
  int get gridColumns => _gridColumns;
  bool get autoDownload => _autoDownload;
  String get downloadQuality => _downloadQuality;
  
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _gridColumns = prefs.getInt(_columnsKey) ?? 2;
    _autoDownload = prefs.getBool(_autoDownloadKey) ?? false;
    _downloadQuality = prefs.getString(_downloadQualityKey) ?? 'HD';
    notifyListeners();
  }
  
  Future<void> setGridColumns(int columns) async {
    if (columns < 2 || columns > 5) return;
    
    _gridColumns = columns;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_columnsKey, columns);
    notifyListeners();
  }
  
  Future<void> setAutoDownload(bool enabled) async {
    _autoDownload = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_autoDownloadKey, enabled);
    notifyListeners();
  }
  
  Future<void> setDownloadQuality(String quality) async {
    _downloadQuality = quality;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_downloadQualityKey, quality);
    notifyListeners();
  }
  
  // Calcula o aspect ratio baseado no número de colunas
  double getItemAspectRatio() {
    switch (_gridColumns) {
      case 2:
        return 0.75; // Mais alto para 2 colunas
      case 3:
        return 0.8;
      case 4:
        return 0.85;
      case 5:
        return 0.9; // Mais quadrado para 5 colunas
      default:
        return 0.75;
    }
  }
  
  // Calcula o espaçamento baseado no número de colunas
  double getItemSpacing() {
    switch (_gridColumns) {
      case 2:
        return 16.0;
      case 3:
        return 12.0;
      case 4:
        return 8.0;
      case 5:
        return 6.0;
      default:
        return 12.0;
    }
  }
}
