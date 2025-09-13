import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/epg_models.dart';

class EPGService extends ChangeNotifier {
  List<EPGProgram> _programs = [];
  final Map<String, List<EPGProgram>> _channelPrograms = {};
  bool _isLoading = false;
  String? _errorMessage;
  
  List<EPGProgram> get programs => _programs;
  Map<String, List<EPGProgram>> get channelPrograms => _channelPrograms;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  
  /// Carrega EPG para um canal específico
  Future<void> loadEPGForChannel(String channelId, String serverUrl, String username, String password) async {
    _setLoading(true);
    _errorMessage = null;
    
    try {
      final url = '$serverUrl/player_api.php?username=$username&password=$password&action=get_simple_data_table&stream_id=$channelId';
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['epg_listings'] != null) {
          final programsList = data['epg_listings'] as List;
          final programs = programsList.map((p) => EPGProgram.fromJson(p)).toList();
          
          _channelPrograms[channelId] = programs;
          _programs.addAll(programs);
          
          notifyListeners();
        }
      }
    } catch (e) {
      _errorMessage = 'Erro ao carregar EPG: $e';
      debugPrint(_errorMessage);
    } finally {
      _setLoading(false);
    }
  }
  
  /// Carrega EPG completo
  Future<void> loadFullEPG(String serverUrl, String username, String password) async {
    _setLoading(true);
    _errorMessage = null;
    
    try {
      final url = '$serverUrl/player_api.php?username=$username&password=$password&action=get_simple_data_table';
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['epg_listings'] != null) {
          final programsList = data['epg_listings'] as List;
          _programs = programsList.map((p) => EPGProgram.fromJson(p)).toList();
          
          // Agrupar por canal
          _channelPrograms.clear();
          for (final program in _programs) {
            if (!_channelPrograms.containsKey(program.channelId)) {
              _channelPrograms[program.channelId] = [];
            }
            _channelPrograms[program.channelId]!.add(program);
          }
          
          // Ordenar programas por horário
          _channelPrograms.forEach((channelId, programs) {
            programs.sort((a, b) => a.startTime.compareTo(b.startTime));
          });
          
          notifyListeners();
        }
      }
    } catch (e) {
      _errorMessage = 'Erro ao carregar EPG completo: $e';
      debugPrint(_errorMessage);
    } finally {
      _setLoading(false);
    }
  }
  
  /// Obtém programa atual para um canal
  EPGProgram? getCurrentProgram(String channelId) {
    final programs = _channelPrograms[channelId];
    if (programs == null || programs.isEmpty) return null;
    
    final now = DateTime.now();
    
    for (final program in programs) {
      if (program.startTime.isBefore(now) && program.endTime.isAfter(now)) {
        return program;
      }
    }
    
    return null;
  }
  
  /// Obtém próximo programa para um canal
  EPGProgram? getNextProgram(String channelId) {
    final programs = _channelPrograms[channelId];
    if (programs == null || programs.isEmpty) return null;
    
    final now = DateTime.now();
    
    for (final program in programs) {
      if (program.startTime.isAfter(now)) {
        return program;
      }
    }
    
    return null;
  }
  
  /// Obtém programas do dia para um canal
  List<EPGProgram> getTodayPrograms(String channelId) {
    final programs = _channelPrograms[channelId];
    if (programs == null || programs.isEmpty) return [];
    
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    
    return programs.where((program) {
      return program.startTime.isAfter(startOfDay) && 
             program.startTime.isBefore(endOfDay);
    }).toList();
  }
  
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
  
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
  
  void clearEPG() {
    _programs.clear();
    _channelPrograms.clear();
    notifyListeners();
  }
}
