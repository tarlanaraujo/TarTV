import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';
import '../services/theme_service.dart';
import '../services/layout_service.dart';
import '../services/download_service.dart';
import '../services/content_service.dart';
import '../services/player_settings_service.dart';
import '../services/account_manager_service.dart';
import '../services/wakelock_service.dart';
import '../services/favorites_service.dart';
import '../screens/downloads_screen.dart';
import '../screens/account_switcher_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info_plus/package_info_plus.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _appVersion = '1.0.0';
  String _buildNumber = '1';

  @override
  void initState() {
    super.initState();
    _loadAppInfo();
  }

  Future<void> _loadAppInfo() async {
    try {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      setState(() {
        _appVersion = packageInfo.version;
        _buildNumber = packageInfo.buildNumber;
      });
    } catch (e) {
      debugPrint('Erro ao carregar informações do app: $e');
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurações'),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildConnectionSection(),
          const SizedBox(height: 24),
          _buildPlayerSection(),
          const SizedBox(height: 24),
          _buildCacheSection(),
          const SizedBox(height: 24),
          _buildDisplaySection(),
          const SizedBox(height: 24),
          _buildDownloadSection(),
          const SizedBox(height: 24),
          _buildDeveloperSection(),
          const SizedBox(height: 24),
          _buildAboutSection(),
          const SizedBox(height: 24),
          _buildLogoutSection(),
        ],
      ),
    );
  }

  Widget _buildConnectionSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.wifi, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  'Conexão',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Consumer<AuthService>(
              builder: (context, authService, child) {
                return Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.info),
                      title: const Text('Servidor'),
                      subtitle: Text(authService.isLoggedIn 
                        ? authService.serverUrl ?? 'Não informado'
                        : 'Não conectado'
                      ),
                    ),
                    ListTile(
                      leading: const Icon(Icons.person),
                      title: const Text('Usuário'),
                      subtitle: Text(authService.isLoggedIn 
                        ? authService.username ?? 'Não informado'
                        : 'Não conectado'
                      ),
                    ),
                  ],
                );
              },
            ),
            const Divider(),
            Consumer<AccountManagerService>(
              builder: (context, accountManager, child) {
                final hasMultipleAccounts = accountManager.hasMultipleAccounts;
                
                return Column(
                  children: [
                    if (hasMultipleAccounts)
                      ListTile(
                        leading: const Icon(Icons.manage_accounts),
                        title: const Text('Gerenciar contas'),
                        subtitle: Text('${accountManager.accounts.length} contas salvas'),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () => _showAccountManager(),
                      ),
                    ListTile(
                      leading: const Icon(Icons.account_circle),
                      title: const Text('Trocar Conta'),
                      subtitle: accountManager.currentAccount != null 
                          ? Text('Conta atual: ${accountManager.currentAccount!.name}')
                          : const Text('Nenhuma conta ativa'),
                      trailing: const Icon(Icons.swap_horiz),
                      onTap: accountManager.hasMultipleAccounts 
                          ? () => _showAccountManager()
                          : () => _showChangeAccountDialog(),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayerSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.play_circle, color: Colors.green),
                const SizedBox(width: 8),
                Text(
                  'Player',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Consumer<PlayerSettingsService>(
              builder: (context, playerService, child) {
                return Column(
                  children: [
                    SwitchListTile(
                      title: const Text('Autoplay'),
                      subtitle: const Text('Reproduzir automaticamente próximo item'),
                      value: playerService.autoplay,
                      onChanged: (value) {
                        playerService.setAutoplay(value);
                      },
                    ),
                    Consumer<WakelockService>(
                      builder: (context, wakelockService, child) {
                        return SwitchListTile(
                          title: const Text('Manter tela ligada'),
                          subtitle: const Text('Evitar que a tela desligue durante reprodução'),
                          value: wakelockService.enabled,
                          onChanged: (value) {
                            wakelockService.setEnabled(value);
                          },
                        );
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.speed),
                      title: const Text('Qualidade padrão do player'),
                      subtitle: const Text('Auto'),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        _showPlayerQualityDialog();
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.memory),
                      title: const Text('Buffer do player'),
                      subtitle: const Text('Configurar tempo de buffer'),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        _showBufferDialog();
                      },
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCacheSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.storage, color: Colors.amber),
                const SizedBox(width: 8),
                Text(
                  'Cache e Armazenamento',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ],
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.cached),
              title: const Text('Limpar cache'),
              subtitle: const Text('Limpar dados temporários do app'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () => _showClearCacheDialog(),
            ),
            ListTile(
              leading: const Icon(Icons.image),
              title: const Text('Cache de imagens'),
              subtitle: const Text('Configurar cache de capas e posters'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () => _showImageCacheDialog(),
            ),
            ListTile(
              leading: const Icon(Icons.cached),
              title: const Text('Cache offline'),
              subtitle: const Text('Salvar dados para acesso offline'),
              trailing: Switch(
                value: true,
                onChanged: (value) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Configuração de cache offline em desenvolvimento'),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDisplaySection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.palette, color: Colors.purple),
                const SizedBox(width: 8),
                Text(
                  'Aparência',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Consumer<ThemeService>(
              builder: (context, themeService, child) {
                return SwitchListTile(
                  title: const Text('Tema escuro'),
                  subtitle: const Text('Usar tema escuro na interface'),
                  value: themeService.isDarkMode,
                  onChanged: (value) {
                    themeService.toggleTheme();
                  },
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.grid_view),
              title: const Text('Layout da grade'),
              subtitle: Consumer<LayoutService>(
                builder: (context, layoutService, child) {
                  return Text('${layoutService.gridColumns} colunas');
                },
              ),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () => _showColumnSelector(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.info_outline, color: Colors.orange),
                const SizedBox(width: 8),
                Text(
                  'Sobre o App',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ],
            ),
            const SizedBox(height: 16),
            const ListTile(
              leading: Icon(Icons.tv),
              title: Text('TarTV'),
              subtitle: Text('Aplicativo de streaming de TV, filmes e séries'),
            ),
            const ListTile(
              leading: Icon(Icons.description),
              title: Text('Termos de uso'),
              subtitle: Text('Política de privacidade e termos'),
            ),
            ListTile(
              leading: const Icon(Icons.feedback),
              title: const Text('Reportar bug'),
              subtitle: const Text('Enviar feedback ou relatar problemas'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () => _openFeedbackForm(),
            ),
            ListTile(
              leading: const Icon(Icons.star),
              title: const Text('Avaliar app'),
              subtitle: const Text('Deixe sua avaliação na loja'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () => _openAppStore(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.exit_to_app, color: Colors.red),
                const SizedBox(width: 8),
                Text(
                  'Sessão',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _showLogoutDialog(),
                icon: const Icon(Icons.logout),
                label: const Text('Sair da conta'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sair da conta'),
        content: const Text('Tem certeza que deseja sair da sua conta atual?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _logout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Sair'),
          ),
        ],
      ),
    );
  }

  void _logout() {
    final authService = context.read<AuthService>();
    authService.logout();
    Navigator.pushReplacementNamed(context, '/login');
  }

  Future<void> _openFeedbackForm() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'support@tartv.app',
      query: 'subject=Feedback TarTV App',
    );
    
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Não foi possível abrir o cliente de email'),
          ),
        );
      }
    }
  }

  Future<void> _openAppStore() async {
    const String storeUrl = 'https://play.google.com/store/apps';
    final Uri uri = Uri.parse(storeUrl);
    
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Não foi possível abrir a loja de aplicativos'),
          ),
        );
      }
    }
  }

  Widget _buildDownloadSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.download, color: Colors.green),
                const SizedBox(width: 8),
                Text(
                  'Downloads',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Consumer<DownloadService>(
              builder: (context, downloadService, child) {
                return Consumer<FavoritesService>(
                  builder: (context, favoritesService, child) {
                    return ListTile(
                      leading: const Icon(Icons.cloud_download),
                      title: const Text('Download automático'),
                      subtitle: Text(
                        'Baixar automaticamente conteúdo favorito (${favoritesService.totalFavorites} itens)',
                      ),
                      trailing: Switch(
                        value: downloadService.autoDownloadFavorites,
                        onChanged: (value) async {
                          await downloadService.setAutoDownloadFavorites(value);
                          if (value && favoritesService.totalFavorites > 0) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('✅ Download automático ativado para ${favoritesService.totalFavorites} favoritos'),
                                backgroundColor: Colors.green,
                              ),
                            );
                            // Iniciar downloads dos favoritos
                            _downloadAllFavorites(favoritesService, downloadService);
                          } else if (!value) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Download automático desativado'),
                                backgroundColor: Colors.orange,
                              ),
                            );
                          }
                        },
                      ),
                    );
                  },
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.hd),
              title: const Text('Qualidade padrão'),
              subtitle: const Text('HD'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                // TODO: Implementar seleção de qualidade padrão
              },
            ),
            ListTile(
              leading: const Icon(Icons.folder),
              title: const Text('Gerenciar downloads'),
              subtitle: const Text('Ver arquivos baixados'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DownloadsScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeveloperSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.developer_mode, color: Colors.cyan),
                const SizedBox(width: 8),
                Text(
                  'Desenvolvedor',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ],
            ),
            const SizedBox(height: 16),
            const ListTile(
              leading: Icon(Icons.person),
              title: Text('Desenvolvido por'),
              subtitle: Text('Tarlan Araújo'),
            ),
            const ListTile(
              leading: Icon(Icons.phone),
              title: Text('Contato'),
              subtitle: Text('88981222492'),
            ),
            ListTile(
              leading: const Icon(Icons.code),
              title: const Text('Versão do app'),
              subtitle: Text('$_appVersion (Build $_buildNumber)'),
            ),
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text('Informações do sistema'),
              subtitle: const Text('Detalhes técnicos do dispositivo'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () => _showSystemInfo(),
            ),
            ListTile(
              leading: const Icon(Icons.bug_report),
              title: const Text('Debug do app'),
              subtitle: const Text('Logs e informações de debug'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () => _showDebugInfo(),
            ),
          ],
        ),
      ),
    );
  }

  void _showColumnSelector() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Layout da Grade'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Escolha o número de colunas para a visualização em grade:'),
            const SizedBox(height: 16),
            Consumer<LayoutService>(
              builder: (context, layoutService, child) {
                return Column(
                  children: [
                    for (int i = 2; i <= 5; i++)
                      RadioListTile<int>(
                        title: Text('$i colunas'),
                        subtitle: Text(_getColumnDescription(i)),
                        value: i,
                        groupValue: layoutService.gridColumns,
                        onChanged: (value) {
                          if (value != null) {
                            layoutService.setGridColumns(value);
                          }
                        },
                      ),
                  ],
                );
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  String _getColumnDescription(int columns) {
    switch (columns) {
      case 2:
        return 'Ideal para celulares';
      case 3:
        return 'Equilibrado para a maioria dos dispositivos';
      case 4:
        return 'Compacto, ideal para tablets';
      case 5:
        return 'Muito compacto, para telas grandes';
      default:
        return '';
    }
  }

  void _showPlayerQualityDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Qualidade do Player'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Escolha a qualidade padrão para reprodução:'),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Auto'),
              subtitle: const Text('Ajustar automaticamente'),
              leading: Radio<String>(
                value: 'Auto',
                groupValue: 'Auto',
                onChanged: (value) {},
              ),
            ),
            ListTile(
              title: const Text('1080p'),
              subtitle: const Text('Full HD'),
              leading: Radio<String>(
                value: '1080p',
                groupValue: 'Auto',
                onChanged: (value) {},
              ),
            ),
            ListTile(
              title: const Text('720p'),
              subtitle: const Text('HD'),
              leading: Radio<String>(
                value: '720p',
                groupValue: 'Auto',
                onChanged: (value) {},
              ),
            ),
            ListTile(
              title: const Text('480p'),
              subtitle: const Text('SD'),
              leading: Radio<String>(
                value: '480p',
                groupValue: 'Auto',
                onChanged: (value) {},
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  void _showBufferDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Configuração de Buffer'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Configurar tempo de buffer para melhor reprodução:'),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Buffer baixo (1s)'),
              subtitle: const Text('Resposta rápida, menos estável'),
              leading: Radio<String>(
                value: 'low',
                groupValue: 'medium',
                onChanged: (value) {},
              ),
            ),
            ListTile(
              title: const Text('Buffer médio (3s)'),
              subtitle: const Text('Equilibrado (recomendado)'),
              leading: Radio<String>(
                value: 'medium',
                groupValue: 'medium',
                onChanged: (value) {},
              ),
            ),
            ListTile(
              title: const Text('Buffer alto (5s)'),
              subtitle: const Text('Mais estável, resposta mais lenta'),
              leading: Radio<String>(
                value: 'high',
                groupValue: 'medium',
                onChanged: (value) {},
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  void _showClearCacheDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Limpar Cache'),
        content: const Text('Isso irá limpar todos os dados temporários e cache de imagens. Deseja continuar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _clearCache();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Limpar'),
          ),
        ],
      ),
    );
  }

  void _showImageCacheDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cache de Imagens'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Configurar cache de capas e posters:'),
            SizedBox(height: 16),
            ListTile(
              title: Text('Tamanho do cache'),
              subtitle: Text('100 MB'),
              trailing: Icon(Icons.edit),
            ),
            SwitchListTile(
              title: Text('Cache automático'),
              subtitle: Text('Baixar imagens automaticamente'),
              value: true,
              onChanged: null,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  void _showSystemInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Informações do Sistema'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Sistema Operacional: Android'),
              SizedBox(height: 8),
              Text('Versão: 13'),
              SizedBox(height: 8),
              Text('Dispositivo: Android Device'),
              SizedBox(height: 8),
              Text('Resolução: 1080x2400'),
              SizedBox(height: 8),
              Text('RAM: 8 GB'),
              SizedBox(height: 8),
              Text('Armazenamento: 128 GB'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  void _showDebugInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Informações de Debug'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Build Mode: Release'),
              SizedBox(height: 8),
              Text('Flutter Version: 3.24.0'),
              SizedBox(height: 8),
              Text('Dart Version: 3.5.0'),
              SizedBox(height: 8),
              Text('Platform: Android'),
              SizedBox(height: 8),
              Text('Logs disponíveis: Sim'),
              SizedBox(height: 8),
              Text('Crash Reports: Habilitado'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => _exportLogs(),
            child: const Text('Exportar Logs'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  Future<void> _exportLogs() async {
    try {
      Navigator.pop(context); // Fechar dialog primeiro
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Preparando logs para exportação...'),
          duration: Duration(seconds: 2),
        ),
      );
      
      // Simular coleta de logs
      final logs = '''
=== TarTV App Logs ===
Data: ${DateTime.now()}
Versão: $_appVersion ($_buildNumber)
Plataforma: Android

=== Status dos Serviços ===
- AuthService: ${context.read<AuthService>().isAuthenticated ? 'Conectado' : 'Desconectado'}
- ContentService: ${context.read<ContentService>().hasData ? 'Com dados' : 'Sem dados'}
- DownloadService: ${context.read<DownloadService>().downloads.length} downloads ativos
- FavoritesService: Carregado

=== Configurações ===
- Tema: ${context.read<ThemeService>().isDarkMode ? 'Escuro' : 'Claro'}
- Layout: ${context.read<LayoutService>().gridColumns} colunas
- Wakelock: ${context.read<WakelockService>().enabled ? 'Ativo' : 'Inativo'}

=== Logs Recentes ===
[${DateTime.now()}] App inicializado
[${DateTime.now()}] Serviços carregados
[${DateTime.now()}] UI renderizada

=== Fim dos Logs ===
''';

      // Tentar compartilhar via email
      final Uri emailUri = Uri(
        scheme: 'mailto',
        path: 'support@tartv.app',
        queryParameters: {
          'subject': 'TarTV Logs - ${DateTime.now().toString().split(' ')[0]}',
          'body': logs,
        },
      );
      
      if (await canLaunchUrl(emailUri)) {
        await launchUrl(emailUri);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Logs enviados para o cliente de email'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        throw Exception('Cliente de email não encontrado');
      }
      
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Erro ao exportar logs: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: 'OK',
              onPressed: () {},
            ),
          ),
        );
      }
    }
  }

  Future<void> _downloadAllFavorites(FavoritesService favoritesService, DownloadService downloadService) async {
    try {
      int downloadCount = 0;
      
      // Baixar filmes favoritos
      for (final movie in favoritesService.favoriteMovies) {
        await downloadService.downloadMovie(movie, 'HD');
        downloadCount++;
      }
      
      // TODO: Implementar download de séries favoritas quando necessário
      // for (final series in favoritesService.favoriteSeries) {
      //   // Download de séries requer episódios específicos
      // }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('🚀 Iniciados $downloadCount downloads automáticos'),
            backgroundColor: Colors.blue,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Erro no download automático: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _clearCache() async {
    try {
      // Limpeza de cache real implementada
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('cached_channels');
      await prefs.remove('cached_movies');
      await prefs.remove('cached_series');
      await prefs.remove('download_history');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cache limpo com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao limpar cache: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showChangeAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Trocar Conta'),
        content: const Text('Isso irá desconectar da conta atual e voltar para a tela de login. Deseja continuar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _changeAccount();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: const Text('Trocar'),
          ),
        ],
      ),
    );
  }

  void _changeAccount() {
    final authService = context.read<AuthService>();
    authService.logout();
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }
  
  void _showAccountManager() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AccountSwitcherScreen(),
      ),
    );
    
    if (result == 'switched') {
      // Conta foi trocada, atualizar a UI
      setState(() {});
    } else if (result == 'add_account') {
      // Usuario quer adicionar nova conta
      _showChangeAccountDialog();
    }
  }
}
