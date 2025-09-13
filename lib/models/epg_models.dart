class EPGProgram {
  final String id;
  final String channelId;
  final String title;
  final String? description;
  final DateTime startTime;
  final DateTime endTime;
  final String? category;
  final String? rating;
  final String? imageUrl;
  
  EPGProgram({
    required this.id,
    required this.channelId,
    required this.title,
    this.description,
    required this.startTime,
    required this.endTime,
    this.category,
    this.rating,
    this.imageUrl,
  });
  
  factory EPGProgram.fromJson(Map<String, dynamic> json) {
    return EPGProgram(
      id: json['id']?.toString() ?? '',
      channelId: json['epg_channel_id']?.toString() ?? '',
      title: json['title'] ?? '',
      description: json['description'],
      startTime: DateTime.parse(json['start'] ?? DateTime.now().toIso8601String()),
      endTime: DateTime.parse(json['stop'] ?? DateTime.now().toIso8601String()),
      category: json['category'],
      rating: json['rating'],
      imageUrl: json['image'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'epg_channel_id': channelId,
      'title': title,
      'description': description,
      'start': startTime.toIso8601String(),
      'stop': endTime.toIso8601String(),
      'category': category,
      'rating': rating,
      'image': imageUrl,
    };
  }
  
  /// Duração do programa em minutos
  int get durationInMinutes {
    return endTime.difference(startTime).inMinutes;
  }
  
  /// Verifica se o programa está acontecendo agora
  bool get isLive {
    final now = DateTime.now();
    return startTime.isBefore(now) && endTime.isAfter(now);
  }
  
  /// Verifica se o programa já passou
  bool get hasEnded {
    return endTime.isBefore(DateTime.now());
  }
  
  /// Verifica se o programa ainda vai começar
  bool get isUpcoming {
    return startTime.isAfter(DateTime.now());
  }
  
  /// Progresso do programa (0.0 a 1.0)
  double get progress {
    if (!isLive) return hasEnded ? 1.0 : 0.0;
    
    final total = endTime.difference(startTime).inMilliseconds;
    final elapsed = DateTime.now().difference(startTime).inMilliseconds;
    
    return (elapsed / total).clamp(0.0, 1.0);
  }
  
  /// Tempo restante em minutos (para programas ao vivo)
  int get remainingMinutes {
    if (!isLive) return 0;
    return endTime.difference(DateTime.now()).inMinutes;
  }
}

class EPGData {
  final String channelId;
  final String channelName;
  final List<EPGProgram> programs;
  
  EPGData({
    required this.channelId,
    required this.channelName,
    required this.programs,
  });
  
  /// Programa atual
  EPGProgram? get currentProgram {
    final now = DateTime.now();
    
    for (final program in programs) {
      if (program.startTime.isBefore(now) && program.endTime.isAfter(now)) {
        return program;
      }
    }
    
    return null;
  }
  
  /// Próximo programa
  EPGProgram? get nextProgram {
    final now = DateTime.now();
    
    for (final program in programs) {
      if (program.startTime.isAfter(now)) {
        return program;
      }
    }
    
    return null;
  }
  
  /// Programas do dia
  List<EPGProgram> get todayPrograms {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    
    return programs.where((program) {
      return program.startTime.isAfter(startOfDay) && 
             program.startTime.isBefore(endOfDay);
    }).toList();
  }
}
