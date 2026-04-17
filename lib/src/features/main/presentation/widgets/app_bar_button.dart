import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppBarButton extends ConsumerStatefulWidget {
  const AppBarButton({super.key, this.onPressed, required this.title});

  final VoidCallback? onPressed;
  final String title;

  @override
  ConsumerState<AppBarButton> createState() => _AppBarButtonState();
}

class _AppBarButtonState extends ConsumerState<AppBarButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isEnabled = widget.onPressed != null;

    return Semantics(
      button: true,
      enabled: isEnabled,
      label: widget.title,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: widget.onPressed,
          onHover: (isHovered) =>
              setState(() => _isHovered = isEnabled && isHovered),
          mouseCursor:
              isEnabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
          borderRadius: BorderRadius.circular(4),
          hoverColor: Theme.of(context).colorScheme.primary.withAlpha(60),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: SizedBox(
              height: 56,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    widget.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: _isHovered
                              ? Theme.of(context).colorScheme.inverseSurface
                              : null,
                        ),
                  ),
                  const SizedBox(height: 4),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOut,
                    height: 2,
                    width: _isHovered ? 24 : 0,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.inverseSurface,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
