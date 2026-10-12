import 'package:flutter/material.dart';

class OpenNowBadge extends StatelessWidget {
  final bool open24x7;
  final bool openNow;
  const OpenNowBadge({super.key, this.open24x7 = false, this.openNow = false});

  @override
  Widget build(BuildContext context) {
    if (!open24x7 && !openNow) return const SizedBox.shrink();
    return Chip(label: Text(open24x7 ? '24x7' : 'Open now'));
  }
}
