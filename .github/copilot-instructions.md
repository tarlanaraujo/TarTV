<!-- Use this file to provide workspace-specific custom instructions to Copilot. For more details, visit https://code.visualstudio.com/docs/copilot/copilot-customization#_use-a-githubcopilotinstructionsmd-file -->

# TarTV Flutter App - Instruções para o Copilot

Este é um projeto de aplicativo IPTV desenvolvido em Flutter para Android. O app permite conexão via Xtream Codes e listas M3U/M3U8, com player nativo que resolve problemas de CORS.

## Contexto do Projeto

- **Objetivo**: Criar um player IPTV robusto similar ao Smarters Player Lite
- **Foco**: Resolver limitações de CORS encontradas na versão web
- **Arquitetura**: Flutter com Provider para gerenciamento de estado

## Padrões de Código

### Estrutura de Arquivos
- `lib/models/`: Classes de dados (Channel, Movie, Series)
- `lib/services/`: APIs e serviços (Xtream, Auth)
- `lib/screens/`: Interfaces de usuário
- `lib/widgets/`: Componentes reutilizáveis

### Convenções
- Use `const` sempre que possível
- Prefira `StatelessWidget` quando não há estado
- Implemente `dispose()` para limpeza de recursos
- Use `Provider.of<T>(context, listen: false)` para ações

### APIs Xtream Codes
- Base URL: `servidor/player_api.php`
- Parâmetros sempre incluem username e password
- URLs de stream seguem padrões específicos:
  - TV: `/live/user/pass/id.ts`
  - Filme: `/movie/user/pass/id.ext`
  - Série: `/series/user/pass/id.ext`

### Player de Vídeo
- Use `video_player` + `chewie` para interface
- Configure `crossOrigin` e `allowsInlineMediaPlayback`
- Implemente controles customizados se necessário

## Funcionalidades Prioritárias

1. **Login robusto**: Validação Xtream e M3U
2. **Player nativo**: Sem limitações de CORS
3. **Interface intuitiva**: Similar a apps IPTV populares
4. **Performance**: Lazy loading e cache de imagens

## Dependências Principais

```yaml
dependencies:
  flutter: sdk
  provider: ^6.0.5
  http: ^1.1.0
  video_player: ^2.7.2
  chewie: ^1.7.0
  shared_preferences: ^2.2.2
  cached_network_image: ^3.3.0
```

## Considerações Especiais

- Android minSdk 21 para compatibilidade
- Permissões de rede e armazenamento configuradas
- `usesCleartextTraffic="true"` para servidores HTTP
- Tratamento de erros gracioso em todas as APIs

Ao sugerir código, considere sempre a experiência do usuário e a robustez da conexão de rede.
