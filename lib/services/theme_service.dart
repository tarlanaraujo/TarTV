import 'package:flutter/material.dart';

class ThemeService extends ChangeNotifier {
  bool _isDarkMode = true;
  
  bool get isDarkMode => _isDarkMode;
  
  ThemeData get themeData {
    return _isDarkMode ? _darkTheme : _lightTheme;
  }
  
  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }
  
  // Cores do TarSystem
  static const Color _tarSystemBlue = Color(0xFF2B5CB0); // Azul principal do site
  static const Color _tarSystemBlueLight = Color(0xFF4A73C7); // Azul mais claro
  
  static final _darkTheme = ThemeData(
    brightness: Brightness.dark,
    primarySwatch: _createMaterialColor(_tarSystemBlue),
    primaryColor: _tarSystemBlue,
    scaffoldBackgroundColor: const Color(0xFF0F1A2E),
    colorScheme: const ColorScheme.dark(
      primary: _tarSystemBlue,
      secondary: _tarSystemBlueLight,
      surface: Color(0xFF1A2332),
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: Colors.white,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: _tarSystemBlue, // Usar o azul principal mais bonito
      elevation: 4,
      iconTheme: IconThemeData(color: Colors.white),
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        fontFamily: 'Roboto',
      ),
      centerTitle: true,
    ),
    cardTheme: CardThemeData(
      color: const Color(0xFF1A2332),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontFamily: 'Roboto',
      ),
      headlineMedium: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w600,
        fontFamily: 'Roboto',
      ),
      bodyLarge: TextStyle(
        color: Colors.white,
        fontFamily: 'Roboto',
      ),
      bodyMedium: TextStyle(
        color: Colors.white70,
        fontFamily: 'Roboto',
      ),
      labelLarge: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w500,
        fontFamily: 'Roboto',
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _tarSystemBlue,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF1A2332),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: _tarSystemBlue),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey[600]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: _tarSystemBlue, width: 2),
      ),
      labelStyle: const TextStyle(color: Colors.white70),
      hintStyle: const TextStyle(color: Colors.white54),
    ),
  );
  
  static final _lightTheme = ThemeData(
    brightness: Brightness.light,
    primarySwatch: _createMaterialColor(_tarSystemBlue),
    primaryColor: _tarSystemBlue,
    scaffoldBackgroundColor: Colors.grey[50],
    colorScheme: const ColorScheme.light(
      primary: _tarSystemBlue,
      secondary: _tarSystemBlueLight,
      surface: Colors.white,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: Color(0xFF2C2C2C),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: _tarSystemBlue,
      elevation: 2,
      iconTheme: IconThemeData(color: Colors.white),
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        fontFamily: 'Roboto',
      ),
      centerTitle: true,
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        color: Color(0xFF2C2C2C),
        fontWeight: FontWeight.bold,
        fontFamily: 'Roboto',
      ),
      headlineMedium: TextStyle(
        color: Color(0xFF2C2C2C),
        fontWeight: FontWeight.w600,
        fontFamily: 'Roboto',
      ),
      bodyLarge: TextStyle(
        color: Color(0xFF2C2C2C),
        fontFamily: 'Roboto',
      ),
      bodyMedium: TextStyle(
        color: Color(0xFF666666),
        fontFamily: 'Roboto',
      ),
      labelLarge: TextStyle(
        color: Color(0xFF2C2C2C),
        fontWeight: FontWeight.w500,
        fontFamily: 'Roboto',
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _tarSystemBlue,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: _tarSystemBlue),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey[400]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: _tarSystemBlue, width: 2),
      ),
      labelStyle: const TextStyle(color: Color(0xFF666666)),
      hintStyle: const TextStyle(color: Color(0xFF999999)),
    ),
  );
  
  // Função auxiliar para criar MaterialColor (sem usar APIs de cor potencialmente instáveis)
  static MaterialColor _createMaterialColor(Color color) {
    List strengths = <double>[.05];
    final Map<int, Color> swatch = {};
    // Extrai componentes manualmente do valor ARGB (0xAARRGGBB)
    // ignore: deprecated_member_use
    final int r = (color.value >> 16) & 0xFF;
    // ignore: deprecated_member_use
    final int g = (color.value >> 8) & 0xFF;
    // ignore: deprecated_member_use
    final int b = color.value & 0xFF;

    for (int i = 1; i < 10; i++) {
      strengths.add(0.1 * i);
    }
    for (var strength in strengths) {
      final double ds = 0.5 - strength;
      swatch[(strength * 1000).round()] = Color.fromRGBO(
        r + ((ds < 0 ? r : (255 - r)) * ds).round(),
        g + ((ds < 0 ? g : (255 - g)) * ds).round(),
        b + ((ds < 0 ? b : (255 - b)) * ds).round(),
        1,
      );
    }
  // ignore: deprecated_member_use
  return MaterialColor(color.value, swatch);
  }
}
