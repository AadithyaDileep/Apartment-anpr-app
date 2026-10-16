import 'package:flutter/material.dart';

import '../data.dart';
import '../theme.dart';
import '../widgets.dart';

class DetectionHistoryScreen extends StatelessWidget {
  const DetectionHistoryScreen({super.key});

  @override
  Widget build(BuildContext c) => SubPage('Detection history', [
        if (detections.isEmpty) const Empty('No detections yet'),
        for (final d in detections)
          Tile(
            Icons.crop_free,
            d[0],
            '${d[1]} · ${d[2]}',
            color: d[3] == 'Allowed' ? cGold : cRed,
            trailing: Pill(d[3], d[3] == 'Allowed' ? cSage : cRed),
          ),
      ]);
}