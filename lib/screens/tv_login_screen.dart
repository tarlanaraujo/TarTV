import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../widgets/tv_focusable_widgets.dart';
import '../widgets/tv_navigation_wrapper.dart';

/// Tela de login otimizada para Android TV
class TvLoginScreen extends StatefulWidget {
  const TvLoginScreen({super.key});

  @override
  State<TvLoginScreen> createState() => _TvLoginScreenState();
}

class _TvLoginScreenState extends State<TvLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _serverController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  int _selectedMethod = 0; // 0: Xtream, 1: M3U URL

  final _serverFocusNode = FocusNode();
  final _usernameFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _connectButtonFocusNode = FocusNode();

  @override
  void dispose() {
    _serverController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _serverFocusNode.dispose();
    _usernameFocusNode.dispose();
    _passwordFocusNode.dispose();
    _connectButtonFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TvNavigationWrapper(
      handleBack: false,
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF0D47A1),
                Color(0xFF1565C0),
                Color(0xFF1976D2),
              ],
            ),
          ),
          child: Row(
            children: [
              // Logo e informações à esquerda
              Expanded(
                flex: 2,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.tv,
                        size: 120,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'TarTV',
                        style: TextStyle(
                          fontSize: 56,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Seu player IPTV completo',
                        style: TextStyle(
                          fontSize: 22,
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                      const SizedBox(height: 48),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.gamepad_outlined,
                              color: Colors.white.withOpacity(0.8),
                              size: 28,
                            ),
                            const SizedBox(width: 16),
                            Text(
                              'Use o controle remoto para navegar',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white.withOpacity(0.8),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Formulário à direita
              Expanded(
                flex: 3,
                child: Center(
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 500),
                    margin: const EdgeInsets.all(48),
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.95),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: FocusTraversalGroup(
                        policy: OrderedTraversalPolicy(),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Text(
                              'Conectar',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0D47A1),
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 32),
                            
                            // Seleção de método
                            Row(
                              children: [
                                Expanded(
                                  child: FocusTraversalOrder(
                                    order: const NumericFocusOrder(0),
                                    child: _buildMethodButton(
                                      'Xtream Codes',
                                      Icons.cloud,
                                      0,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: FocusTraversalOrder(
                                    order: const NumericFocusOrder(1),
                                    child: _buildMethodButton(
                                      'URL M3U',
                                      Icons.link,
                                      1,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            
                            // Campos do formulário
                            if (_selectedMethod == 0) ...[
                              FocusTraversalOrder(
                                order: const NumericFocusOrder(2),
                                child: TvFocusableTextField(
                                  controller: _serverController,
                                  focusNode: _serverFocusNode,
                                  labelText: 'Servidor/Host',
                                  hintText: 'http://exemplo.com:8080',
                                  prefixIcon: const Icon(Icons.dns),
                                  autofocus: true,
                                  validator: (v) =>
                                      v?.isEmpty == true ? 'Digite o servidor' : null,
                                ),
                              ),
                              const SizedBox(height: 16),
                              FocusTraversalOrder(
                                order: const NumericFocusOrder(3),
                                child: TvFocusableTextField(
                                  controller: _usernameController,
                                  focusNode: _usernameFocusNode,
                                  labelText: 'Usuário',
                                  prefixIcon: const Icon(Icons.person),
                                  validator: (v) =>
                                      v?.isEmpty == true ? 'Digite o usuário' : null,
                                ),
                              ),
                              const SizedBox(height: 16),
                              FocusTraversalOrder(
                                order: const NumericFocusOrder(4),
                                child: TvFocusableTextField(
                                  controller: _passwordController,
                                  focusNode: _passwordFocusNode,
                                  labelText: 'Senha',
                                  prefixIcon: const Icon(Icons.lock),
                                  obscureText: true,
                                  validator: (v) =>
                                      v?.isEmpty == true ? 'Digite a senha' : null,
                                ),
                              ),
                            ] else ...[
                              FocusTraversalOrder(
                                order: const NumericFocusOrder(2),
                                child: TvFocusableTextField(
                                  controller: _serverController,
                                  focusNode: _serverFocusNode,
                                  labelText: 'URL da Lista M3U',
                                  hintText: 'http://exemplo.com/lista.m3u',
                                  prefixIcon: const Icon(Icons.link),
                                  autofocus: true,
                                  validator: (v) =>
                                      v?.isEmpty == true ? 'Digite a URL' : null,
                                ),
                              ),
                            ],
                            
                            const SizedBox(height: 32),
                            
                            // Botão conectar
                            FocusTraversalOrder(
                              order: const NumericFocusOrder(5),
                              child: TvFocusableButton(
                                focusNode: _connectButtonFocusNode,
                                onPressed: _isLoading ? null : _handleLogin,
                                backgroundColor: const Color(0xFF1565C0),
                                focusedBackgroundColor: const Color(0xFF0D47A1),
                                padding: const EdgeInsets.symmetric(vertical: 20),
                                child: _isLoading
                                    ? const SizedBox(
                                        height: 24,
                                        width: 24,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.login, color: Colors.white),
                                          SizedBox(width: 12),
                                          Text(
                                            'Conectar',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMethodButton(String title, IconData icon, int index) {
    final isSelected = _selectedMethod == index;
    
    return TvFocusableButton(
      onPressed: () => setState(() => _selectedMethod = index),
      backgroundColor: isSelected
          ? const Color(0xFF1565C0)
          : Colors.grey.shade200,
      focusedBackgroundColor: const Color(0xFF0D47A1),
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: isSelected ? Colors.white : Colors.grey.shade700,
            size: 22,
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? Colors.white : Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      bool success = false;

      if (_selectedMethod == 0) {
        success = await authService.loginXtream(
          _serverController.text.trim(),
          _usernameController.text.trim(),
          _passwordController.text.trim(),
        );
      } else {
        success = await authService.loginM3UUrl(_serverController.text.trim());
      }

      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Login realizado com sucesso!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Erro ao conectar. Verifique os dados.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
