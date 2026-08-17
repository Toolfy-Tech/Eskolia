import 'package:flutter/material.dart';
import '../../data/osi_layers_data.dart';

class OsiLayerBadge extends StatelessWidget {
  const OsiLayerBadge({
    super.key,
    required this.layerNumber,
    this.showRole = false,
    this.compact = false,
  });

  final int layerNumber;
  final bool showRole;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final layer = OsiLayersData.getLayer(layerNumber);

    if (compact) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: layer.accentColor.withValues(alpha: 0.16),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: layer.accentColor.withValues(alpha: 0.45)),
        ),
        child: Text(
          'L$layerNumber • ${layer.name}',
          style: TextStyle(
            color: layer.accentColor,
            fontWeight: FontWeight.bold,
            fontSize: 11,
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: layer.accentColor.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: layer.accentColor.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: layer.accentColor,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              'L$layerNumber',
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w900,
                fontSize: 11,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            layer.name,
            style: TextStyle(
              color: layer.accentColor,
              fontWeight: FontWeight.bold,
              fontSize: 12.5,
            ),
          ),
          if (showRole) ...[
            const SizedBox(width: 6),
            Text(
              '(${layer.pdu})',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.6),
                fontSize: 11,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
