import 'package:flutter/material.dart';

const _toolDefs = [
  (name: 'Explain', icon: Icons.lightbulb_outline),
  (name: 'Quiz', icon: Icons.quiz_outlined),
  (name: 'Flashcards', icon: Icons.style_outlined),
  (name: 'Key ideas', icon: Icons.format_list_bulleted),
];

class ToolChipsRow extends StatelessWidget {
  final Function(String) onToolSelected;
  final String? activeTool;

  const ToolChipsRow({
    super.key,
    required this.onToolSelected,
    this.activeTool,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: _toolDefs.map((tool) {
          final isActive = activeTool == tool.name;
          return Padding(
            padding: const EdgeInsets.only(right: 10.0),
            child: FilterChip(
              avatar: Icon(
                tool.icon,
                size: 16,
                color: isActive ? cs.onSecondaryContainer : cs.primary,
              ),
              label: Text(tool.name),
              selected: isActive,
              onSelected: (_) => onToolSelected(tool.name),
              showCheckmark: false,
              backgroundColor: cs.surface,
              selectedColor: cs.secondaryContainer,
              labelStyle: TextStyle(
                color: isActive ? cs.onSecondaryContainer : cs.onSurface,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              ),
              side: BorderSide(
                color: isActive ? cs.secondary : cs.outlineVariant,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
