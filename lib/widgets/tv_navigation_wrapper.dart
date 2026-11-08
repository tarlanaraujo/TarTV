import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Wrapper que gerencia navegação por D-pad em Android TV
/// Intercepta eventos de teclado/controle e gerencia foco
class TvNavigationWrapper extends StatefulWidget {
  final Widget child;
  final VoidCallback? onBackPressed;
  final bool handleBack;

  const TvNavigationWrapper({
    super.key,
    required this.child,
    this.onBackPressed,
    this.handleBack = true,
  });

  @override
  State<TvNavigationWrapper> createState() => _TvNavigationWrapperState();
}

class _TvNavigationWrapperState extends State<TvNavigationWrapper> {
  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: <LogicalKeySet, Intent>{
        // Navegação D-pad
        LogicalKeySet(LogicalKeyboardKey.arrowUp): const DirectionalFocusIntent(TraversalDirection.up),
        LogicalKeySet(LogicalKeyboardKey.arrowDown): const DirectionalFocusIntent(TraversalDirection.down),
        LogicalKeySet(LogicalKeyboardKey.arrowLeft): const DirectionalFocusIntent(TraversalDirection.left),
        LogicalKeySet(LogicalKeyboardKey.arrowRight): const DirectionalFocusIntent(TraversalDirection.right),
        
        // Botão voltar
        LogicalKeySet(LogicalKeyboardKey.goBack): const _BackIntent(),
        LogicalKeySet(LogicalKeyboardKey.escape): const _BackIntent(),
        LogicalKeySet(LogicalKeyboardKey.browserBack): const _BackIntent(),
      },
      child: Actions(
        actions: <Type, Action<Intent>>{
          DirectionalFocusIntent: DirectionalFocusAction(),
          _BackIntent: CallbackAction<_BackIntent>(
            onInvoke: (_) {
              if (widget.handleBack) {
                if (widget.onBackPressed != null) {
                  widget.onBackPressed!();
                } else {
                  Navigator.of(context).maybePop();
                }
              }
              return null;
            },
          ),
        },
        child: FocusTraversalGroup(
          policy: ReadingOrderTraversalPolicy(),
          child: widget.child,
        ),
      ),
    );
  }
}

class _BackIntent extends Intent {
  const _BackIntent();
}

/// Widget que gerencia grupo de foco para listas horizontais (estilo Netflix)
class TvHorizontalFocusGroup extends StatelessWidget {
  final List<Widget> children;
  final double itemWidth;
  final double itemHeight;
  final EdgeInsetsGeometry? padding;
  final String? title;
  final ScrollController? scrollController;

  const TvHorizontalFocusGroup({
    super.key,
    required this.children,
    this.itemWidth = 180,
    this.itemHeight = 260,
    this.padding,
    this.title,
    this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return FocusTraversalGroup(
      policy: OrderedTraversalPolicy(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (title != null)
            Padding(
              padding: const EdgeInsets.only(left: 16, bottom: 12, top: 8),
              child: Text(
                title!,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          SizedBox(
            height: itemHeight,
            child: ListView.builder(
              controller: scrollController,
              scrollDirection: Axis.horizontal,
              padding: padding ?? const EdgeInsets.symmetric(horizontal: 12),
              itemCount: children.length,
              itemBuilder: (context, index) {
                return SizedBox(
                  width: itemWidth,
                  child: FocusTraversalOrder(
                    order: NumericFocusOrder(index.toDouble()),
                    child: children[index],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Widget que gerencia grupo de foco para grids
class TvGridFocusGroup extends StatelessWidget {
  final List<Widget> children;
  final int crossAxisCount;
  final double childAspectRatio;
  final double mainAxisSpacing;
  final double crossAxisSpacing;
  final EdgeInsetsGeometry? padding;
  final ScrollController? scrollController;

  const TvGridFocusGroup({
    super.key,
    required this.children,
    this.crossAxisCount = 5,
    this.childAspectRatio = 0.7,
    this.mainAxisSpacing = 12,
    this.crossAxisSpacing = 12,
    this.padding,
    this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return FocusTraversalGroup(
      policy: ReadingOrderTraversalPolicy(),
      child: GridView.builder(
        controller: scrollController,
        padding: padding ?? const EdgeInsets.all(16),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          childAspectRatio: childAspectRatio,
          mainAxisSpacing: mainAxisSpacing,
          crossAxisSpacing: crossAxisSpacing,
        ),
        itemCount: children.length,
        itemBuilder: (context, index) {
          return FocusTraversalOrder(
            order: NumericFocusOrder(index.toDouble()),
            child: children[index],
          );
        },
      ),
    );
  }
}

/// Sidebar de navegação para TV
class TvNavigationRail extends StatefulWidget {
  final List<TvNavigationRailItem> items;
  final int selectedIndex;
  final ValueChanged<int>? onItemSelected;
  final Widget? header;
  final Widget? footer;

  const TvNavigationRail({
    super.key,
    required this.items,
    required this.selectedIndex,
    this.onItemSelected,
    this.header,
    this.footer,
  });

  @override
  State<TvNavigationRail> createState() => _TvNavigationRailState();
}

class _TvNavigationRailState extends State<TvNavigationRail> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      width: 200,
      color: theme.colorScheme.surface,
      child: FocusTraversalGroup(
        policy: OrderedTraversalPolicy(),
        child: Column(
          children: [
            if (widget.header != null) ...[
              widget.header!,
              const SizedBox(height: 16),
            ],
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: widget.items.length,
                itemBuilder: (context, index) {
                  final item = widget.items[index];
                  final isSelected = index == widget.selectedIndex;
                  
                  return FocusTraversalOrder(
                    order: NumericFocusOrder(index.toDouble()),
                    child: _TvNavigationRailItemWidget(
                      item: item,
                      isSelected: isSelected,
                      onSelect: () => widget.onItemSelected?.call(index),
                      autofocus: index == 0,
                    ),
                  );
                },
              ),
            ),
            if (widget.footer != null) ...[
              const SizedBox(height: 16),
              widget.footer!,
            ],
          ],
        ),
      ),
    );
  }
}

class TvNavigationRailItem {
  final IconData icon;
  final IconData? selectedIcon;
  final String label;

  const TvNavigationRailItem({
    required this.icon,
    this.selectedIcon,
    required this.label,
  });
}

class _TvNavigationRailItemWidget extends StatefulWidget {
  final TvNavigationRailItem item;
  final bool isSelected;
  final VoidCallback? onSelect;
  final bool autofocus;

  const _TvNavigationRailItemWidget({
    required this.item,
    required this.isSelected,
    this.onSelect,
    this.autofocus = false,
  });

  @override
  State<_TvNavigationRailItemWidget> createState() =>
      _TvNavigationRailItemWidgetState();
}

class _TvNavigationRailItemWidgetState
    extends State<_TvNavigationRailItemWidget> {
  bool _isFocused = false;
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _handleKeyEvent(KeyEvent event) {
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.select ||
          event.logicalKey == LogicalKeyboardKey.enter ||
          event.logicalKey == LogicalKeyboardKey.gameButtonA) {
        widget.onSelect?.call();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isHighlighted = _isFocused || widget.isSelected;
    
    return KeyboardListener(
      focusNode: _focusNode,
      autofocus: widget.autofocus,
      onKeyEvent: _handleKeyEvent,
      child: Focus(
        onFocusChange: (hasFocus) {
          setState(() => _isFocused = hasFocus);
        },
        child: GestureDetector(
          onTap: widget.onSelect,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: isHighlighted
                  ? theme.colorScheme.primary.withOpacity(0.15)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _isFocused
                    ? theme.colorScheme.primary
                    : Colors.transparent,
                width: 2.0,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  widget.isSelected
                      ? widget.item.selectedIcon ?? widget.item.icon
                      : widget.item.icon,
                  color: isHighlighted
                      ? theme.colorScheme.primary
                      : theme.iconTheme.color,
                  size: 26,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    widget.item.label,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight:
                          isHighlighted ? FontWeight.bold : FontWeight.normal,
                      color: isHighlighted
                          ? theme.colorScheme.primary
                          : theme.textTheme.bodyLarge?.color,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
