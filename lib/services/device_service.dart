import 'package:flutter/foundation.dart';
import '../utils/logger.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:math'; // adicionada para sqrt

enum DeviceType {
  mobile,
  tablet, 
  tv,
  unknown
}

class DeviceService extends ChangeNotifier {
  static DeviceType? _deviceType;
  static bool? _isAndroidTV;
  static bool? _hasPhysicalKeyboard;

  static DeviceType get deviceType {
    try {
      _deviceType ??= _detectDeviceType();
      return _deviceType!;
    } catch (e) {
  AppLogger.e('DeviceService', 'Erro ao detectar tipo de dispositivo: $e');
      return DeviceType.mobile; // Fallback seguro
    }
  }

  static bool get isAndroidTV {
    try {
      _isAndroidTV ??= _detectAndroidTV();
      return _isAndroidTV!;
    } catch (e) {
  AppLogger.e('DeviceService', 'Erro ao detectar Android TV: $e');
      return false; // Fallback seguro
    }
  }

  static bool get isMobile => deviceType == DeviceType.mobile;
  static bool get isTablet => deviceType == DeviceType.tablet;
  static bool get isTV => deviceType == DeviceType.tv || isAndroidTV;

  static bool get hasPhysicalKeyboard {
    _hasPhysicalKeyboard ??= _detectPhysicalKeyboard();
    return _hasPhysicalKeyboard!;
  }

  // Detecta o tipo de dispositivo baseado no tamanho da tela
  static DeviceType _detectDeviceType() {
    if (!kIsWeb && Platform.isAndroid) {
      // No Android, vamos usar a densidade e tamanho da tela
      final window = WidgetsBinding.instance.platformDispatcher.views.first;
      final size = window.physicalSize / window.devicePixelRatio;
      final diagonal = _calculateDiagonal(size.width, size.height);
      
      if (diagonal >= 10.0) {
        return DeviceType.tv;
      } else if (diagonal >= 7.0) {
        return DeviceType.tablet;
      } else {
        return DeviceType.mobile;
      }
    }
    return DeviceType.unknown;
  }

  // Detecta especificamente Android TV
  static bool _detectAndroidTV() {
    if (!kIsWeb && Platform.isAndroid) {
      try {
        // Detecção simplificada baseada no tamanho da tela
        final window = WidgetsBinding.instance.platformDispatcher.views.first;
        final size = window.physicalSize / window.devicePixelRatio;
        final diagonal = _calculateDiagonal(size.width, size.height);
        
        // Se a diagonal é muito grande, provavelmente é uma TV
        return diagonal >= 10.0;
      } catch (e) {
  AppLogger.e('DeviceService', 'Erro na detecção de Android TV: $e');
        return false;
      }
    }
    return false;
  }

  // Detecta se tem teclado físico (controlador remoto)
  static bool _detectPhysicalKeyboard() {
    // Em Android TV, geralmente há controle remoto
    return isAndroidTV;
  }

  static double _calculateDiagonal(double width, double height) {
    // Correção: usar raiz quadrada para calcular a diagonal real em pixels e converter para 'inches' aproximado
    return sqrt(width * width + height * height) / 160.0; // 160dpi referência aproximada
  }

  // Configurações específicas por dispositivo
  static double getGridColumns() {
    switch (deviceType) {
      case DeviceType.mobile:
        return 2;
      case DeviceType.tablet:
        return 3;
      case DeviceType.tv:
        return 4;
      default:
        return 2;
    }
  }

  static double getItemSpacing() {
    return isTV ? 12.0 : 8.0;
  }

  static EdgeInsets getContentPadding() {
    if (isTV) {
      return const EdgeInsets.symmetric(horizontal: 48.0, vertical: 32.0);
    } else {
      return const EdgeInsets.all(16.0);
    }
  }

  static double getFontSize({required double mobile, required double tv}) {
    return isTV ? tv : mobile;
  }

  static double getIconSize({required double mobile, required double tv}) {
    return isTV ? tv : mobile;
  }
}
