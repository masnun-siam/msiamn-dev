import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:portfolio/src/features/introduction/domain/contact.dart';
import 'package:portfolio/src/localization/generated/locale_keys.g.dart';

import 'package:url_launcher/url_launcher.dart';

class ContactBar extends ConsumerWidget {
  const ContactBar({super.key, required this.contacts});

  final List<Contact> contacts;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Wrap(
      children: contacts.map((contact) {
        final iconData = _getIconData(contact);
        final contactTooltip = contact.tooltip;
        final contactUrl = contact.url;
        if (contactTooltip == null || contactUrl == null) {
          return const SizedBox.shrink();
        }
        return _HoverableContactIcon(
          tooltip: contactTooltip,
          url: contactUrl,
          iconData: iconData,
          padding: iconData == null ? null : _fixGithubIconPadding(iconData),
        );
      }).toList(),
    );
  }

  IconData? _getIconData(Contact contact) {
    final contactIconCodePoint = contact.iconCodePoint;
    final contactIconFontFamily = contact.iconFontFamily;
    final contactIconFontPackage = contact.iconFontPackage;
    if (contactIconCodePoint != null &&
        contactIconFontFamily != null &&
        contactIconFontPackage != null) {
      final contactIconCodePointHexa = int.tryParse(contactIconCodePoint);
      if (contactIconCodePointHexa != null) {
        final iconData = IconData(
          contactIconCodePointHexa,
          fontFamily: contactIconFontFamily,
          fontPackage: contactIconFontPackage,
        );
        return iconData;
      }
    }
    return null;
  }

  EdgeInsetsGeometry? _fixGithubIconPadding(IconData iconData) {
    if (iconData != FontAwesomeIcons.discord) return null;
    return const EdgeInsets.only(right: 6);
  }
}

class _HoverableContactIcon extends StatefulWidget {
  const _HoverableContactIcon({
    required this.tooltip,
    required this.url,
    this.iconData,
    this.padding,
  });

  final String tooltip;
  final String url;
  final IconData? iconData;
  final EdgeInsetsGeometry? padding;

  @override
  State<_HoverableContactIcon> createState() => _HoverableContactIconState();
}

class _HoverableContactIconState extends State<_HoverableContactIcon> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedScale(
        scale: _isHovered ? 1.25 : 1.0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        child: Tooltip(
          message: widget.tooltip,
          child: IconButton(
            onPressed: () async {
              if (!await launchUrl(Uri.parse(widget.url))) {
                if (context.mounted) {
                  final snackBar = SnackBar(
                    content: Text(
                      "${tr(LocaleKeys.openUrlError)} ${widget.url}",
                    ),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                }
              }
            },
            icon: widget.iconData != null
                ? Icon(
                    widget.iconData,
                    color: _isHovered
                        ? Theme.of(context).colorScheme.inverseSurface
                        : null,
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.link,
                        color: _isHovered
                            ? Theme.of(context).colorScheme.inverseSurface
                            : null,
                      ),
                      const SizedBox(width: 4),
                      Text(widget.tooltip),
                    ],
                  ),
            padding: widget.padding,
          ),
        ),
      ),
    );
  }
}
