import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:portfolio/src/constants/sizes.dart';
import 'package:portfolio/src/features/introduction/domain/resume.dart';
import 'package:portfolio/src/features/introduction/presentation/widgets/resume_language_dialog.dart';
import 'package:portfolio/src/localization/generated/locale_keys.g.dart';

import 'package:url_launcher/url_launcher.dart';

class ResumeButton extends ConsumerStatefulWidget {
  const ResumeButton({super.key, required this.resumes});

  final List<Resume> resumes;

  @override
  ConsumerState<ResumeButton> createState() => _ResumeButtonState();
}

class _ResumeButtonState extends ConsumerState<ResumeButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final tertiary = Theme.of(context).colorScheme.tertiary;
    final inverseSurface = Theme.of(context).colorScheme.inverseSurface;
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(40),
          boxShadow: _isHovered
              ? [
                  BoxShadow(
                    color: tertiary.withAlpha(80),
                    blurRadius: 20,
                    spreadRadius: 2,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: OutlinedButton(
          style: OutlinedButton.styleFrom(
            side: BorderSide(
              width: 2,
              color: tertiary,
            ),
            backgroundColor:
                _isHovered ? tertiary.withAlpha(30) : Colors.transparent,
            elevation: 0,
            shape: const StadiumBorder(),
            padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 12),
          ),
          onPressed: () => _onPressed(context, ref),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            textBaseline: TextBaseline.alphabetic,
            children: [
              AnimatedRotation(
                turns: _isHovered ? 0.05 : 0,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
                child: Icon(
                  FontAwesomeIcons.filePdf,
                  color: inverseSurface,
                ),
              ),
              gapW12,
              Text(
                tr(LocaleKeys.resume),
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _onPressed(BuildContext context, WidgetRef ref) async {
    if (widget.resumes.length > 1) {
      showDialog(
        context: context,
        builder: (context) => ResumeLanguageDialog(resumes: widget.resumes),
      );
    } else if (widget.resumes.length == 1) {
      final resumeFirstUrl = widget.resumes.first.url;
      if (resumeFirstUrl == null) {
        _showSnackBarResumeError(context);
        return;
      }
      await launchUrl(Uri.parse(resumeFirstUrl));
      if (context.mounted) {
        Navigator.of(context).pop();
      }
    } else {
      _showSnackBarResumeError(context);
    }
  }

  void _showSnackBarResumeError(BuildContext context) {
    final snackBar = SnackBar(
      content: Text(tr(LocaleKeys.openResumeError)),
    );
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }
}
