import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/account_manager_service.dart';
import '../services/auth_service.dart';
import '../services/tv_detection_service.dart';
import 'login_screen.dart';
import 'home_screen.dart';
import 'tv_login_screen.dart';
import 'tv_home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      // Aguarda um pouco para garantir que o widget está montado
      await Future.delayed(const Duration(milliseconds: 500));
      
      if (!mounted) return;
      
      // Inicializa serviços de forma segura
      final accountManager = Provider.of<AccountManagerService>(context, listen: false);
      await accountManager.init();
      
      if (!mounted) return;
      
      // Aguarda mais um pouco para garantir estabilidade
      await Future.delayed(const Duration(milliseconds: 1000));
      
      if (!mounted) return;
      
      // Navega para a tela principal
      _navigateToMainScreen();
      
    } catch (e) {
      debugPrint('Erro na inicialização: $e');
      
      // Em caso de erro, navega para login após delay
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) {
        _navigateToLogin();
      }
    }
  }

  void _navigateToMainScreen() {
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final tvService = Provider.of<TvDetectionService>(context, listen: false);
      final isTV = tvService.isAndroidTV;
      
      Widget nextScreen;
      if (authService.isAuthenticated) {
        nextScreen = isTV ? const TvHomeScreen() : const HomeScreen();
      } else {
        nextScreen = isTV ? const TvLoginScreen() : const LoginScreen();
      }
      
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => nextScreen),
      );
    } catch (e) {
      debugPrint('Erro ao navegar: $e');
      _navigateToLogin();
    }
  }
  
  void _navigateToLogin() {
    try {
      final tvService = Provider.of<TvDetectionService>(context, listen: false);
      final isTV = tvService.isAndroidTV;
      
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => isTV ? const TvLoginScreen() : const LoginScreen(),
        ),
      );
    } catch (e) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1a1a1a),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo do app
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.tv,
                color: Colors.white,
                size: 60,
              ),
            ),
            const SizedBox(height: 32),
            
            // Nome do app
            const Text(
              'TarTV',
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            
            // Subtítulo
            const Text(
              'Seu player IPTV',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 48),
            
            // Loading indicator
            const CircularProgressIndicator(
              color: Colors.blue,
            ),
            const SizedBox(height: 16),
            
            const Text(
              'Inicializando...',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}