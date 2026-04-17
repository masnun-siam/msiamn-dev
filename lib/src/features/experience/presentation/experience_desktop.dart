import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portfolio/src/common/widgets/section_header.dart';
import 'package:portfolio/src/constants/sizes.dart';
import 'package:portfolio/src/features/experience/domain/experience.dart';
import 'package:portfolio/src/features/experience/presentation/widgets/company_experience_group.dart';
import 'package:portfolio/src/features/experience/presentation/widgets/experience_card.dart';
import 'package:portfolio/src/localization/generated/locale_keys.g.dart';
import 'package:portfolio/src/localization/json_list_translation.dart';

class ExperienceDesktop extends ConsumerStatefulWidget {
  const ExperienceDesktop({super.key});

  @override
  ConsumerState<ExperienceDesktop> createState() => _ExperienceDesktopState();
}

class _ExperienceDesktopState extends ConsumerState<ExperienceDesktop> {
  @override
  Widget build(BuildContext context) {
    final experiences = trList(context.locale, LocaleKeys.experiences)
        .map(Experience.fromJson)
        .toList();

    // Group consecutive experiences by company (preserving order)
    final groups = <List<Experience>>[];
    for (final exp in experiences) {
      if (groups.isNotEmpty && groups.last.first.company == exp.company) {
        groups.last.add(exp);
      } else {
        groups.add([exp]);
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 12, bottom: 20),
          child: SectionHeader(title: tr(LocaleKeys.experienceSectionTitle)),
        ),
        for (int i = 0; i < groups.length; i++) ...[
          if (groups[i].length == 1)
            ExperienceCard(experience: groups[i].first)
          else
            CompanyExperienceGroup(experiences: groups[i]),
          if (i != groups.length - 1) gapH24,
        ],
      ],
    );
  }
}
