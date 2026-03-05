import 'package:flutter/material.dart';

import '../tokens.dart';

class RTabs extends StatelessWidget {
  const RTabs({
    super.key,
    required this.tabs,
    required this.active,
    required this.onChanged,
  });

  final List<String> tabs;
  final String active;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: tabs
            .map(
              (tab) => Padding(
                padding: const EdgeInsets.only(right: RTokens.spacingX2),
                child: ChoiceChip(
                  label: Text(tab),
                  selected: active == tab,
                  onSelected: (_) => onChanged(tab),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}
