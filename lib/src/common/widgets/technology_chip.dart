import 'package:flutter/material.dart';

class TechnologyChip extends StatefulWidget {
  const TechnologyChip({super.key, required this.name});

  final String name;

  @override
  State<TechnologyChip> createState() => _TechnologyChipState();
}

class _TechnologyChipState extends State<TechnologyChip> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: _isHovered
              ? [
                  BoxShadow(
                    color: Theme.of(context)
                        .colorScheme
                        .tertiary
                        .withAlpha(50),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ]
              : [],
        ),
        child: IgnorePointer(
          child: Chip(
            label: Text(widget.name),
            backgroundColor: Theme.of(context).colorScheme.secondary,
            side: BorderSide(
              color: _isHovered
                  ? Theme.of(context).colorScheme.tertiary.withAlpha(120)
                  : Theme.of(context).colorScheme.tertiary.withAlpha(40),
              width: 1,
            ),
          ),
        ),
      ),
    );
  }
}
