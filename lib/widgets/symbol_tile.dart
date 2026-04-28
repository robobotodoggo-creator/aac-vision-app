import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/aac_symbol.dart';

class SymbolTile extends StatefulWidget {
  final AacSymbol symbol;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const SymbolTile({
    super.key,
    required this.symbol,
    required this.onTap,
    this.onLongPress,
  });

  @override
  State<SymbolTile> createState() => _SymbolTileState();
}

class _SymbolTileState extends State<SymbolTile>
    with SingleTickerProviderStateMixin {
  late final AnimationController _flashController;
  late final Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    _flashController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _colorAnimation = ColorTween(
      begin: Colors.grey[850],
      end: Colors.blue[400],
    ).animate(_flashController);
    _flashController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _flashController.reverse();
      }
    });
  }

  @override
  void dispose() {
    _flashController.dispose();
    super.dispose();
  }

  void _handleTap() {
    HapticFeedback.mediumImpact();
    _flashController.forward(from: 0);
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _colorAnimation,
      builder: (context, child) {
        return Material(
          color: _colorAnimation.value,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: _handleTap,
            onLongPress: widget.onLongPress != null
                ? () {
                    HapticFeedback.heavyImpact();
                    _flashController.forward(from: 0);
                    widget.onLongPress!();
                  }
                : null,
            child: child,
          ),
        );
      },
      child: Container(
        constraints: const BoxConstraints(minHeight: 60, minWidth: 60),
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              widget.symbol.emoji,
              style: const TextStyle(fontSize: 32),
            ),
            const SizedBox(height: 4),
            Text(
              widget.symbol.label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
