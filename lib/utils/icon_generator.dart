import 'dart:io';
import 'logger.dart';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

class IconGenerator {
  static Future<void> generateAppIcons() async {
    const sizes = [
      {'folder': 'mipmap-hdpi', 'size': 72},
      {'folder': 'mipmap-mdpi', 'size': 48},
      {'folder': 'mipmap-xhdpi', 'size': 96},
      {'folder': 'mipmap-xxhdpi', 'size': 144},
      {'folder': 'mipmap-xxxhdpi', 'size': 192},
    ];

    for (final sizeInfo in sizes) {
      await _generateIcon(
        sizeInfo['size'] as int,
        'android/app/src/main/res/${sizeInfo['folder']}/ic_launcher.png',
      );
    }

    // Gerar ícones para web também
    await _generateIcon(192, 'web/icons/Icon-192.png');
    await _generateIcon(512, 'web/icons/Icon-512.png');
    await _generateIcon(192, 'web/icons/Icon-maskable-192.png');
    await _generateIcon(512, 'web/icons/Icon-maskable-512.png');
  }

  static Future<void> _generateIcon(int size, String outputPath) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    
    // Fundo com gradiente azul TarSystem
    final gradient = ui.Gradient.linear(
      const Offset(0, 0),
      Offset(size.toDouble(), size.toDouble()),
      [
        const Color(0xFF2B5CB0), // Azul principal TarSystem
        const Color(0xFF1E4080), // Azul mais escuro
      ],
    );
    
    final paint = Paint()
      ..shader = gradient
      ..style = PaintingStyle.fill;
    
    // Desenhar fundo circular/quadrado com bordas arredondadas
    final rect = Rect.fromLTWH(0, 0, size.toDouble(), size.toDouble());
    final radius = size * 0.15; // 15% de border radius
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, Radius.circular(radius)),
      paint,
    );
    
    // Desenhar sombra interna para profundidade
    final shadowPaint = Paint()
  ..color = Colors.black.withValues(alpha: 0.2)
      ..style = PaintingStyle.fill;
    
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(2, 2, size - 4.0, size - 4.0),
        Radius.circular(radius - 2),
      ),
      shadowPaint,
    );
    
    // Desenhar o símbolo # (hashtag)
    final hashPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = size * 0.08 // 8% da largura
      ..strokeCap = StrokeCap.round;
    
    final center = size / 2;
    final hashSize = size * 0.4; // 40% do tamanho
    final lineOffset = hashSize * 0.3;
    
    // Linhas verticais do #
    canvas.drawLine(
      Offset(center - lineOffset, center - hashSize / 2),
      Offset(center - lineOffset, center + hashSize / 2),
      hashPaint,
    );
    canvas.drawLine(
      Offset(center + lineOffset, center - hashSize / 2),
      Offset(center + lineOffset, center + hashSize / 2),
      hashPaint,
    );
    
    // Linhas horizontais do #
    canvas.drawLine(
      Offset(center - hashSize / 2, center - lineOffset),
      Offset(center + hashSize / 2, center - lineOffset),
      hashPaint,
    );
    canvas.drawLine(
      Offset(center - hashSize / 2, center + lineOffset),
      Offset(center + hashSize / 2, center + lineOffset),
      hashPaint,
    );
    
    // Desenhar mini ícone TV no canto inferior direito
    final tvSize = size * 0.15;
    final tvPaint = Paint()
  ..color = Colors.white.withValues(alpha: 0.8)
      ..style = PaintingStyle.fill;
    
    final tvRect = Rect.fromLTWH(
      size - tvSize - size * 0.1,
      size - tvSize - size * 0.1,
      tvSize,
      tvSize * 0.7,
    );
    
    canvas.drawRRect(
      RRect.fromRectAndRadius(tvRect, Radius.circular(tvSize * 0.1)),
      tvPaint,
    );
    
    // Antena da TV
    final antennaPath = Path();
    antennaPath.moveTo(tvRect.center.dx - tvSize * 0.2, tvRect.top);
    antennaPath.lineTo(tvRect.center.dx - tvSize * 0.3, tvRect.top - tvSize * 0.3);
    antennaPath.moveTo(tvRect.center.dx + tvSize * 0.2, tvRect.top);
    antennaPath.lineTo(tvRect.center.dx + tvSize * 0.3, tvRect.top - tvSize * 0.3);
    
    final antennaPaint = Paint()
  ..color = Colors.white.withValues(alpha: 0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size * 0.01;
    
    canvas.drawPath(antennaPath, antennaPaint);
    
    final picture = recorder.endRecording();
    final img = await picture.toImage(size, size);
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
    
    if (byteData != null) {
      final file = File(outputPath);
      await file.parent.create(recursive: true);
      await file.writeAsBytes(byteData.buffer.asUint8List());
  AppLogger.i('IconGenerator', 'Ícone gerado: $outputPath');
    }
  }
}
