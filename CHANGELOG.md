# Changelog

Todas as mudanças notáveis neste projeto serão documentadas neste arquivo.

O formato é baseado em [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
e este projeto adere ao [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2025-09-12

### Adicionado
- 🎥 **Sistema IPTV Completo**
  - Suporte a Xtream Codes API
  - Suporte a playlists M3U (URL e arquivo local)
  - Player de vídeo nativo com controles customizados
  - Categorização automática de conteúdo

- 📱 **Interface de Usuário**
  - Tela inicial com navegação por abas (Canais, Filmes, Séries, Favoritos, Downloads)
  - Tela de login com múltiplos métodos de autenticação
  - Telas de detalhes para filmes e séries
  - Sistema de busca global
  - Configurações avançadas

- ⭐ **Sistema de Favoritos**
  - Favoritos para canais ao vivo
  - Favoritos para filmes
  - Favoritos para séries
  - Persistência local com SharedPreferences
  - Interface visual com ícones de coração

- 📥 **Sistema de Downloads**
  - Download de filmes em múltiplas qualidades (HD, SD, Mobile)
  - Download de episódios de séries
  - Gerenciador de downloads com progresso em tempo real
  - Histórico de downloads
  - Suporte a pausar/retomar/cancelar downloads

- 🔐 **Autenticação Multi-Conta**
  - Gerenciamento de múltiplas contas IPTV
  - Troca rápida entre contas
  - Persistência segura de credenciais
  - Suporte a renomear e excluir contas

- 📺 **Processamento M3U Avançado**
  - Parser completo de arquivos M3U/M3U8
  - Extração automática de metadados (logos, categorias, EPG IDs)
  - Validação de formato M3U
  - Suporte a arquivos locais e URLs

- 🎨 **Recursos Visuais**
  - Interface Material Design 3
  - Modo escuro/claro
  - Imagens de backdrop e posters
  - Placeholders para conteúdo sem imagem
  - Animações e transições suaves

- 🔧 **Configurações e Personalização**
  - Configurações de reprodução
  - Gerenciamento de cache
  - Configurações de download
  - Limpeza de dados
  - Informações da aplicação

### Implementações Técnicas

#### Arquitetura
- **Padrão Provider**: Gerenciamento de estado reativo
- **Separação de Responsabilidades**: Services, Screens, Models, Widgets
- **Dependency Injection**: Injeção automática de dependências entre services

#### Services Implementados
- `AuthService`: Gerenciamento de autenticação e sessões
- `ContentService`: Carregamento e cache de conteúdo IPTV
- `DownloadService`: Sistema completo de downloads
- `FavoritesService`: Gerenciamento de favoritos
- `AccountManagerService`: Múltiplas contas IPTV
- `M3UParserService`: Processamento de playlists M3U
- `EPGService`: Electronic Program Guide (preparado para futuras implementações)
- `CategoryService`: Gerenciamento de categorias
- `ThemeService`: Temas e personalização visual
- `LayoutService`: Configurações de layout
- `PlayerSettingsService`: Configurações do player de vídeo

#### Modelos de Dados
- `Channel`: Modelo para canais ao vivo
- `Movie`: Modelo para filmes
- `Series`: Modelo para séries e temporadas
- `Episode`: Modelo para episódios
- `DownloadItem`: Modelo para itens em download
- `AccountData`: Modelo para dados de contas

#### Compatibilidade
- **Flutter Web**: Suporte completo com tratamento de limitações CORS
- **Android**: APK otimizado com permissões adequadas
- **Armazenamento**: Suporte a armazenamento externo no Android

### Corrigido
- 🐛 **Sistema de Downloads**
  - Problema de downloads não aparecendo na fila corrigido
  - Logs detalhados para debugging implementados
  - Notificações corretas do Provider implementadas

- 🐛 **Sistema de Favoritos**
  - Botões de favorito adicionados em todas as telas necessárias
  - Funcionalidade completa para canais, filmes e séries
  - Persistência de favoritos entre sessões

- 🐛 **Processamento M3U**
  - Parser completo implementado substituindo implementação temporária
  - Validação robusta de formato M3U
  - Extração correta de metadados

### Melhorado
- 🚀 **Performance**: Cache inteligente de conteúdo e imagens
- 🎯 **UX**: Feedback visual em todas as ações do usuário
- 🔍 **Debug**: Logs detalhados em todos os services críticos
- 📱 **Responsividade**: Interface adaptável a diferentes tamanhos de tela

### Tecnologias Utilizadas
- Flutter 3.19.0+
- Dart 3.1.0+
- Provider 6.1.2 (State Management)
- HTTP 1.1.0 (Networking)
- Video Player 2.8.6 + Chewie 1.8.0 (Video Playback)
- SharedPreferences 2.2.2 (Local Storage)
- CachedNetworkImage 3.3.1 (Image Caching)
- File Picker 8.0.3 (File Selection)
- Permission Handler 11.3.1 (Android Permissions)

## [Próximas Versões - Roadmap]

### [1.1.0] - Planejado
- 📡 **EPG Completo**: Guia eletrônico de programação
- 🔄 **Sincronização**: Backup e restore de favoritos na nuvem
- 🎛️ **Player Avançado**: Controles de velocidade, legendas, áudio
- 📊 **Estatísticas**: Histórico de visualização e estatísticas de uso

### [1.2.0] - Planejado
- 📺 **Android TV**: Interface otimizada para TV
- 🎮 **Controle Remoto**: Suporte a controles remotos
- 👨‍👩‍👧‍👦 **Perfis**: Múltiplos perfis de usuário
- 🔒 **Controle Parental**: Restrições por idade e conteúdo

---

## Formato das Versões

### Adicionado
Para novas funcionalidades.

### Modificado
Para mudanças em funcionalidades existentes.

### Obsoleto
Para funcionalidades que serão removidas em breve.

### Removido
Para funcionalidades removidas nesta versão.

### Corrigido
Para correções de bugs.

### Segurança
Para correções relacionadas à vulnerabilidades.
