import 'package:flutter/material.dart';

class TarLogo extends StatelessWidget {
  final double size;
  final Color? color;
  
  const TarLogo({
    super.key,
    this.size = 80,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final logoColor = color ?? Colors.white;
    
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF2B5CB0), // Azul principal TarSystem
            Color(0xFF1E4080), // Azul mais escuro
          ],
        ),
        borderRadius: BorderRadius.circular(size * 0.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Símbolo # (hashtag)
          Center(
            child: Icon(
              Icons.tag,
              size: size * 0.4,
              color: logoColor,
            ),
          ),
          // TV icon pequeno no canto
          Positioned(
            bottom: size * 0.1,
            right: size * 0.1,
            child: Container(
              padding: EdgeInsets.all(size * 0.05),
              decoration: BoxDecoration(
                color: logoColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(size * 0.05),
              ),
              child: Icon(
                Icons.tv,
                size: size * 0.2,
                color: logoColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
