import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _serverController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  int _selectedMethod = 0; // 0: Xtream, 1: M3U URL, 2: M3U File
  String? _selectedFilePath;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1565C0),
              Color(0xFF0D47A1),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height - 
                            MediaQuery.of(context).padding.top - 
                            MediaQuery.of(context).padding.bottom - 48,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                // Logo/Title
                const Icon(
                  Icons.tv,
                  size: 80,
                  color: Colors.white,
                ),
                const SizedBox(height: 16),
                const Text(
                  'TarTV',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Seu player IPTV completo',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 48),
                
                // Method Selection
                Container(
                  decoration: BoxDecoration(
                    // ignore: deprecated_member_use
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      _buildMethodTab('Xtream Codes', 0),
                      _buildMethodTab('URL M3U', 1),
                      _buildMethodTab('Arquivo M3U', 2),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                
                // Form
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    // ignore: deprecated_member_use
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        if (_selectedMethod == 0) ..._buildXtreamForm(),
                        if (_selectedMethod == 1) ..._buildM3UUrlForm(),
                        if (_selectedMethod == 2) ..._buildM3UFileForm(),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _handleLogin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: const Color(0xFF1565C0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: _isLoading
                                ? const CircularProgressIndicator()
                                : const Text(
                                    'Conectar',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
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
    );
  }

  Widget _buildMethodTab(String title, int index) {
    final isSelected = _selectedMethod == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedMethod = index),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          // ignore: deprecated_member_use
          color: isSelected ? Colors.white.withOpacity(0.2) : null,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white70,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  List<Widget> _buildXtreamForm() {
    return [
      TextFormField(
        controller: _serverController,
        decoration: const InputDecoration(
          labelText: 'Servidor/Host',
          hintText: 'http://exemplo.com:8080',
          prefixIcon: Icon(Icons.dns),
          border: OutlineInputBorder(),
        ),
        validator: (value) => value?.isEmpty == true ? 'Digite o servidor' : null,
      ),
      const SizedBox(height: 16),
      TextFormField(
        controller: _usernameController,
        decoration: const InputDecoration(
          labelText: 'Usuário',
          prefixIcon: Icon(Icons.person),
          border: OutlineInputBorder(),
        ),
        validator: (value) => value?.isEmpty == true ? 'Digite o usuário' : null,
      ),
      const SizedBox(height: 16),
      TextFormField(
        controller: _passwordController,
        decoration: const InputDecoration(
          labelText: 'Senha',
          prefixIcon: Icon(Icons.lock),
          border: OutlineInputBorder(),
        ),
        obscureText: true,
        validator: (value) => value?.isEmpty == true ? 'Digite a senha' : null,
      ),
    ];
  }

  List<Widget> _buildM3UUrlForm() {
    return [
      TextFormField(
        controller: _serverController,
        decoration: const InputDecoration(
          labelText: 'URL da Lista M3U',
          hintText: 'http://exemplo.com/lista.m3u',
          prefixIcon: Icon(Icons.link),
          border: OutlineInputBorder(),
        ),
        validator: (value) => value?.isEmpty == true ? 'Digite a URL' : null,
      ),
    ];
  }

  List<Widget> _buildM3UFileForm() {
    return [
      GestureDetector(
        onTap: _selectM3UFile,
        child: Container(
          width: double.infinity,
          height: 100,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white54),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _selectedFilePath != null ? Icons.check_circle : Icons.file_upload,
                size: 32,
                color: _selectedFilePath != null ? Colors.green : Colors.white54,
              ),
              const SizedBox(height: 8),
              Text(
                _selectedFilePath != null 
                    ? 'Arquivo selecionado: ${_selectedFilePath!.split('/').last}'
                    : 'Toque para selecionar arquivo M3U',
                style: TextStyle(
                  color: _selectedFilePath != null ? Colors.green : Colors.white70,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    ];
  }

  Future<void> _selectM3UFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['m3u', 'm3u8', 'txt'],
        allowMultiple: false,
      );
      
      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        setState(() {
          _selectedFilePath = file.path ?? file.name;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao selecionar arquivo: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      bool success = false;

      switch (_selectedMethod) {
        case 0: // Xtream Codes
          success = await authService.loginXtream(
            _serverController.text.trim(),
            _usernameController.text.trim(),
            _passwordController.text.trim(),
          );
          break;
        case 1: // M3U URL
          success = await authService.loginM3UUrl(_serverController.text.trim());
          break;
        case 2: // M3U File
          if (_selectedFilePath?.isNotEmpty == true) {
            success = await authService.loginM3UFile(_selectedFilePath!);
            if (!success) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Erro ao processar arquivo M3U. Verifique se o arquivo é válido.'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
              return;
            }
          } else {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Por favor, selecione um arquivo M3U primeiro'),
                  backgroundColor: Colors.orange,
                ),
              );
            }
            return;
          }
          break;
      }

      if (success) {
        // Login bem-sucedido, o Consumer na main.dart vai mudar para HomeScreen
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
              content: Text('Erro ao conectar. Verifique os dados e tente novamente.'),
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
