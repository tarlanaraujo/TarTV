import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/account_manager_service.dart';
import '../services/auth_service.dart';

class AccountSwitcherScreen extends StatelessWidget {
  const AccountSwitcherScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contas Salvas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => Navigator.pop(context, 'add_account'),
            tooltip: 'Adicionar nova conta',
          ),
        ],
      ),
      body: Consumer2<AccountManagerService, AuthService>(
        builder: (context, accountManager, authService, child) {
          final accounts = accountManager.accounts;
          final currentAccount = accountManager.currentAccount;

          if (accounts.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.account_circle_outlined,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Nenhuma conta salva',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Faça login para salvar sua primeira conta',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: accounts.length,
            itemBuilder: (context, index) {
              final account = accounts[index];
              final isCurrentAccount = currentAccount?.id == account.id;

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 4),
                color: isCurrentAccount ? Theme.of(context).primaryColor.withValues(alpha: 0.1) : null,
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: isCurrentAccount 
                        ? Theme.of(context).primaryColor 
                        : Colors.grey,
                    child: Text(
                      account.name.isNotEmpty ? account.name[0].toUpperCase() : '?',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(
                    account.name,
                    style: TextStyle(
                      fontWeight: isCurrentAccount ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Usuário: ${account.username}',
                        style: const TextStyle(fontSize: 12),
                      ),
                      Text(
                        'Servidor: ${_formatServerUrl(account.serverUrl)}',
                        style: const TextStyle(fontSize: 12),
                      ),
                      Text(
                        'Último acesso: ${_formatLastUsed(account.lastUsed)}',
                        style: const TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isCurrentAccount)
                        const Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: 20,
                        ),
                      const SizedBox(width: 8),
                      PopupMenuButton<String>(
                        onSelected: (action) => _handleAccountAction(
                          context,
                          action,
                          account,
                          accountManager,
                          authService,
                        ),
                        itemBuilder: (context) => [
                          if (!isCurrentAccount)
                            const PopupMenuItem(
                              value: 'switch',
                              child: ListTile(
                                leading: Icon(Icons.swap_horiz),
                                title: Text('Trocar para esta conta'),
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                          const PopupMenuItem(
                            value: 'rename',
                            child: ListTile(
                              leading: Icon(Icons.edit),
                              title: Text('Renomear'),
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                          PopupMenuItem(
                            value: 'delete',
                            child: ListTile(
                              leading: Icon(
                                Icons.delete,
                                color: Colors.red[400],
                              ),
                              title: Text(
                                'Remover',
                                style: TextStyle(color: Colors.red[400]),
                              ),
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  onTap: isCurrentAccount
                      ? null
                      : () => _switchAccount(context, account, accountManager, authService),
                ),
              );
            },
          );
        },
      ),
    );
  }

  String _formatServerUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.host;
    } catch (e) {
      return url.length > 30 ? '${url.substring(0, 30)}...' : url;
    }
  }

  String _formatLastUsed(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays} dia${difference.inDays > 1 ? 's' : ''} atrás';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hora${difference.inHours > 1 ? 's' : ''} atrás';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minuto${difference.inMinutes > 1 ? 's' : ''} atrás';
    } else {
      return 'Agora mesmo';
    }
  }

  void _handleAccountAction(
    BuildContext context,
    String action,
    AccountData account,
    AccountManagerService accountManager,
    AuthService authService,
  ) {
    switch (action) {
      case 'switch':
        _switchAccount(context, account, accountManager, authService);
        break;
      case 'rename':
        _renameAccount(context, account, accountManager);
        break;
      case 'delete':
        _deleteAccount(context, account, accountManager);
        break;
    }
  }

  void _switchAccount(
    BuildContext context,
    AccountData account,
    AccountManagerService accountManager,
    AuthService authService,
  ) async {
    try {
      // Mostrar loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('Trocando conta...'),
            ],
          ),
        ),
      );

      final success = await authService.switchAccount(account.id);
      
      if (context.mounted) {
        Navigator.pop(context); // Fechar loading
        
        if (success) {
          // Forçar atualização completa da UI
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✅ Conta trocada para: ${account.name}'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
          
          // Aguardar um pouco e then navegar
          await Future.delayed(const Duration(milliseconds: 500));
          
          if (context.mounted) {
            // Voltar para home e resetar navegação
            Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('❌ Erro ao trocar conta'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context); // Fechar loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _renameAccount(
    BuildContext context,
    AccountData account,
    AccountManagerService accountManager,
  ) {
    final controller = TextEditingController(text: account.name);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Renomear Conta'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Nome da conta',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              final newName = controller.text.trim();
              if (newName.isNotEmpty && newName != account.name) {
                await accountManager.updateAccountName(account.id, newName);
              }
              if (context.mounted) {
                Navigator.pop(context);
              }
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  void _deleteAccount(
    BuildContext context,
    AccountData account,
    AccountManagerService accountManager,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remover Conta'),
        content: Text(
          'Tem certeza que deseja remover a conta "${account.name}"?\n\n'
          'Esta ação não pode ser desfeita.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              await accountManager.removeAccount(account.id);
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Conta "${account.name}" removida'),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Remover'),
          ),
        ],
      ),
    );
  }
}
