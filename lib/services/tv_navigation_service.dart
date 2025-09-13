import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'device_service.dart';

class TVNavigationService extends ChangeNotifier {
  static const double _focusScale = 1.1;
  static const Duration _focusAnimationDuration = Duration(milliseconds: 200);
  
  int _currentFocusIndex = 0;
  int get currentFocusIndex => _currentFocusIndex;
  
  // Cores específicas para TV
  static const Color tvFocusColor = Color(0xFF2196F3);
  static const Color tvSelectedColor = Color(0xFF1976D2);
  
  void setFocusIndex(int index) {
    _currentFocusIndex = index;
    notifyListeners();
  }

  // Widget wrapper para itens focáveis na TV
  Widget buildFocusableItem({
    required Widget child,
    required int index,
    required VoidCallback onPressed,
    bool autofocus = false,
  }) {
    if (!DeviceService.isTV) {
      // Permitir também GestureDetector para consistência
      return GestureDetector(
        onTap: onPressed,
        child: child,
      );
    }

    // Na TV, usa Focus widget com animação + suporte a clique
    return Focus(
      autofocus: autofocus,
      onFocusChange: (hasFocus) {
        if (hasFocus) {
          setFocusIndex(index);
        }
      },
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.select ||
              event.logicalKey == LogicalKeyboardKey.enter ||
              event.logicalKey == LogicalKeyboardKey.space) {
            onPressed();
            return KeyEventResult.handled;
          }
        }
        return KeyEventResult.ignored;
      },
      child: Builder(
        builder: (context) {
          final hasFocus = Focus.of(context).hasFocus;
          return GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: onPressed, // Permite clique com mouse / toque no emulador
            child: AnimatedContainer(
              duration: _focusAnimationDuration,
              curve: Curves.easeInOut,
              transform: Matrix4.identity()..scale(hasFocus ? _focusScale : 1.0),
              child: Container(
                decoration: BoxDecoration(
                  border: hasFocus 
                    ? Border.all(color: tvFocusColor, width: 3)
                    : null,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: hasFocus ? [
                    BoxShadow(
                      color: tvFocusColor.withValues(alpha: 0.3),
                      blurRadius: 10,
                      spreadRadius: 2,
                    )
                  ] : null,
                ),
                child: child,
              ),
            ),
          );
        },
      ),
    );
  }

  // Bottom Navigation especial para TV
  Widget buildTVBottomNavigation({
    required int currentIndex,
    required List<BottomNavigationBarItem> items,
    required Function(int) onTap,
  }) {
    if (!DeviceService.isTV) {
      // Celular usa BottomNavigationBar normal
      return BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: currentIndex,
        onTap: onTap,
        items: items,
      );
    }

    // TV usa navegação horizontal personalizada
    return Container(
      height: 80,
      color: Colors.blue.shade800,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          final isSelected = currentIndex == index;
          
          return buildFocusableItem(
            index: index + 1000, // Offset para evitar conflitos
            onPressed: () => onTap(index),
            autofocus: index == 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: isSelected ? tvSelectedColor : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    (item.icon as Icon).icon,
                    color: Colors.white,
                    size: DeviceService.getIconSize(mobile: 24, tv: 32),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.label!,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: DeviceService.getFontSize(mobile: 12, tv: 14),
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // GridView específico para TV com navegação
  Widget buildTVGrid({
    required int itemCount,
    required Widget Function(BuildContext, int) itemBuilder,
    int? crossAxisCount,
  }) {
    final columns = crossAxisCount ?? DeviceService.getGridColumns().toInt();
    
    if (!DeviceService.isTV) {
      // Celular usa GridView normal
      return GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columns,
          childAspectRatio: 0.7,
          crossAxisSpacing: DeviceService.getItemSpacing(),
          mainAxisSpacing: DeviceService.getItemSpacing(),
        ),
        padding: DeviceService.getContentPadding(),
        itemCount: itemCount,
        itemBuilder: itemBuilder,
      );
    }

    // TV usa GridView com navegação por setas
    return Padding(
      padding: DeviceService.getContentPadding(),
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columns,
          childAspectRatio: 0.7,
          crossAxisSpacing: DeviceService.getItemSpacing(),
          mainAxisSpacing: DeviceService.getItemSpacing(),
        ),
        itemCount: itemCount,
        itemBuilder: (context, index) {
          return buildFocusableItem(
            index: index,
            onPressed: () {
              // O comportamento de seleção será definido pelo item
            },
            autofocus: index == 0,
            child: itemBuilder(context, index),
          );
        },
      ),
    );
  }

  // ListView especial para TV
  Widget buildTVList({
    required int itemCount,
    required Widget Function(BuildContext, int) itemBuilder,
  }) {
    if (!DeviceService.isTV) {
      return ListView.builder(
        padding: DeviceService.getContentPadding(),
        itemCount: itemCount,
        itemBuilder: itemBuilder,
      );
    }

    return Padding(
      padding: DeviceService.getContentPadding(),
      child: ListView.builder(
        itemCount: itemCount,
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.only(bottom: DeviceService.getItemSpacing()),
            child: buildFocusableItem(
              index: index,
              onPressed: () {
                // Comportamento definido pelo item
              },
              autofocus: index == 0,
              child: itemBuilder(context, index),
            ),
          );
        },
      ),
    );
  }
}
