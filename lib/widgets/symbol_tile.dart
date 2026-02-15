import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/aac_symbol.dart';

class SymbolTile extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Material(
      color: Colors.grey[850],
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          HapticFeedback.mediumImpact();
          onTap();
        },
        onLongPress: onLongPress != null
            ? () {
                HapticFeedback.heavyImpact();
                onLongPress!();
              }
            : null,
        child: Container(
          constraints: const BoxConstraints(minHeight: 60, minWidth: 60),
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                symbol.emoji,
                style: const TextStyle(fontSize: 32),
              ),
              const SizedBox(height: 4),
              Text(
                symbol.label,
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
      ),
    );
  }
}
