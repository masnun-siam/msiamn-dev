import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portfolio/src/constants/sizes.dart';
import 'package:portfolio/src/features/introduction/domain/resume.dart';
import 'package:portfolio/src/features/introduction/presentation/widgets/contact_bar.dart';
import 'package:portfolio/src/features/introduction/presentation/widgets/magic_icon.dart';
import 'package:portfolio/src/features/introduction/presentation/widgets/resume_button.dart';
import 'package:portfolio/src/features/introduction/domain/contact.dart';
import 'package:portfolio/src/localization/generated/locale_keys.g.dart';
import 'package:portfolio/src/localization/json_list_translation.dart';

class IntroductionMobile extends ConsumerStatefulWidget {
  const IntroductionMobile({super.key});

  @override
  ConsumerState<IntroductionMobile> createState() => _IntroductionMobileState();
}

class _IntroductionMobileState extends ConsumerState<IntroductionMobile>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final jsonResumes = trList(context.locale, LocaleKeys.resumes);
    final resumes = jsonResumes.map((jsonResume) {
      return Resume.fromJson(jsonResume);
    });
    final jsonContacts = trList(context.locale, LocaleKeys.contacts);
    final contacts = jsonContacts.map((jsonContact) {
      return Contact.fromJson(jsonContact);
    });
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              tr(LocaleKeys.name),
              style: Theme.of(context).textTheme.displayMedium,
            ),
            gapH4,
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "${tr(LocaleKeys.description)} ",
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontSize: 20),
                ),
                const MagicIcon(),
              ],
            ),
            _buildResumeButton(ref, resumes: resumes.toList()),
            gapH8,
            ContactBar(contacts: contacts.toList()),
          ],
        ),
      ),
    );
  }

  Widget _buildResumeButton(WidgetRef ref, {required List<Resume> resumes}) {
    if (resumes.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 28),
      child: ResumeButton(resumes: resumes),
    );
  }
}
