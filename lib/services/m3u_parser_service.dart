import 'package:flutter/widgets.dart';
import '../models/media_models.dart';

class M3UParserService {
  /// Parseia conteúdo M3U e converte em lista de canais
  static List<Channel> parseM3UContent(String content) {
    final List<Channel> channels = [];
    final lines = content.split('\n');
    
    String? currentExtInf;
    String? currentTvgId;
    String? currentTvgLogo;
    String? currentGroupTitle;
    
    for (int i = 0; i < lines.length; i++) {
      final line = lines[i].trim();
      
      if (line.startsWith('#EXTINF:')) {
        // Parse da linha EXTINF
        currentExtInf = line;
        
        // Extrair informações da linha EXTINF
        final extinf = _parseExtInf(line);
        currentTvgId = extinf['tvg-id'];
        currentTvgLogo = extinf['tvg-logo'];
        currentGroupTitle = extinf['group-title'];
        
      } else if (line.isNotEmpty && 
                 !line.startsWith('#') && 
                 currentExtInf != null) {
        // Esta linha contém a URL do stream
        final streamUrl = line;
        
        // Extrair nome do canal da linha EXTINF
        final channelName = _extractChannelName(currentExtInf);
        
        // Criar o canal usando o modelo correto
        final channel = Channel(
          id: currentTvgId ?? DateTime.now().millisecondsSinceEpoch.toString(),
          name: channelName,
          url: streamUrl, // Usando 'url' em vez de 'streamUrl'
          logo: currentTvgLogo,
          category: currentGroupTitle ?? 'Sem Categoria', // Usando 'category' em vez de 'categoryId'
          epgId: currentTvgId, // Usando 'epgId' em vez de 'epgChannelId'
        );
        
        channels.add(channel);
        
        // Reset para próximo canal
        currentExtInf = null;
        currentTvgId = null;
        currentTvgLogo = null;
        currentGroupTitle = null;
      }
    }
    
    debugPrint('M3U Parser: ${channels.length} canais encontrados');
    return channels;
  }
  
  /// Extrai informações da linha EXTINF
  static Map<String, String> _parseExtInf(String extinf) {
    final Map<String, String> attributes = {};
    
    // Regex para extrair atributos como tvg-id="", tvg-name="", etc.
    final RegExp attrRegex = RegExp(r'(\w+(?:-\w+)*)="([^"]*)"');
    final matches = attrRegex.allMatches(extinf);
    
    for (final match in matches) {
      final key = match.group(1);
      final value = match.group(2);
      if (key != null && value != null) {
        attributes[key] = value;
      }
    }
    
    return attributes;
  }
  
  /// Extrai o nome do canal da linha EXTINF
  static String _extractChannelName(String extinf) {
    // O nome do canal geralmente vem depois da última vírgula
    final commaIndex = extinf.lastIndexOf(',');
    if (commaIndex != -1 && commaIndex < extinf.length - 1) {
      return extinf.substring(commaIndex + 1).trim();
    }
    
    // Fallback: tentar extrair de tvg-name se existir
    final tvgNameMatch = RegExp(r'tvg-name="([^"]*)"').firstMatch(extinf);
    if (tvgNameMatch != null) {
      return tvgNameMatch.group(1) ?? 'Canal sem nome';
    }
    
    return 'Canal sem nome';
  }
  
  /// Agrupa canais por categoria
  static Map<String, List<Channel>> groupChannelsByCategory(List<Channel> channels) {
    final Map<String, List<Channel>> grouped = {};
    
    for (final channel in channels) {
      final category = channel.category; // Usar 'category' em vez de 'categoryId'
      if (!grouped.containsKey(category)) {
        grouped[category] = [];
      }
      grouped[category]!.add(channel);
    }
    
    return grouped;
  }
  
  /// Valida se o conteúdo é um M3U válido
  static bool isValidM3U(String content) {
    if (content.isEmpty) return false;
    
    final lines = content.split('\n');
    
    // Deve começar com #EXTM3U
    if (lines.isEmpty || !lines.first.trim().startsWith('#EXTM3U')) {
      return false;
    }
    
    // Deve ter pelo menos uma entrada EXTINF
    return content.contains('#EXTINF:');
  }
}
