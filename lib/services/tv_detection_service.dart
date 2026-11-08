import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';

/// Serviço para detectar se o app está rodando em Android TV
/// e gerenciar configurações específicas para TV
class TvDetectionService extends ChangeNotifier {
  static final TvDetectionService _instance = TvDetectionService._internal();
  factory TvDetectionService() => _instance;
  TvDetectionService._internal();

  bool _isAndroidTV = false;
  bool _initialized = false;
  bool _forceTvMode = false;

  bool get isAndroidTV => _isAndroidTV || _forceTvMode;
  bool get initialized => _initialized;

  /// Escala de fonte para TV (visualização à distância)
  double get fontScale => isAndroidTV ? 1.2 : 1.0;

  /// Tamanho mínimo de elementos tocáveis/focáveis
  double get minTouchTarget => isAndroidTV ? 48.0 : 44.0;

  /// Padding padrão para cards na TV
  double get cardPadding => isAndroidTV ? 16.0 : 12.0;

  /// Tamanho do destaque de foco
  double get focusBorderWidth => isAndroidTV ? 3.0 : 2.0;

  /// Inicializa o serviço detectando o tipo de dispositivo
  Future<void> init() async {
    if (_initialized) return;

    try {
      if (Platform.isAndroid) {
        _isAndroidTV = await _checkIsAndroidTV();
      }
    } catch (e) {
      debugPrint('Erro ao detectar Android TV: $e');
      _isAndroidTV = false;
    }

    _initialized = true;
    notifyListeners();
    
    debugPrint('📺 TvDetectionService: isAndroidTV=$_isAndroidTV');
  }

  /// Verifica se é Android TV usando características do sistema
  Future<bool> _checkIsAndroidTV() async {
    try {
      // Método 1: Verificar se tem leanback feature
      const platform = MethodChannel('com.tartv.app/platform');
      
      try {
        final result = await platform.invokeMethod<bool>('isAndroidTV');
        if (result == true) return true;
      } catch (e) {
        // Canal não disponível, usar fallback
        debugPrint('Canal de plataforma não disponível, usando fallback');
      }

      // Método 2: Verificar características do dispositivo via sistema
      // TVs geralmente não têm touchscreen como feature obrigatória
      // e têm resolução específica
      
      return false;
    } catch (e) {
      debugPrint('Erro ao verificar Android TV: $e');
      return false;
    }
  }

  /// Força modo TV (útil para testes)
  void setForceTvMode(bool force) {
    _forceTvMode = force;
    notifyListeners();
    debugPrint('📺 Modo TV forçado: $force');
  }

  /// Verifica se deve usar navegação por D-pad
  bool get useDpadNavigation => isAndroidTV;

  /// Retorna o tema de cores para foco na TV
  TvFocusColors get focusColors => const TvFocusColors(
    focusedBorder: Color(0xFF2196F3),
    focusedBackground: Color(0x332196F3),
    unfocusedBorder: Color(0x00000000),
    pressedBackground: Color(0x552196F3),
  );
}

/// Cores para estados de foco na TV
class TvFocusColors {
  final Color focusedBorder;
  final Color focusedBackground;
  final Color unfocusedBorder;
  final Color pressedBackground;

  const TvFocusColors({
    required this.focusedBorder,
    required this.focusedBackground,
    required this.unfocusedBorder,
    required this.pressedBackground,
  });
}
