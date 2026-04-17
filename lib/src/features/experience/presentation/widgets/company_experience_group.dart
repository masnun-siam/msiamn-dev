import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portfolio/src/common/widgets/responsive.dart';
import 'package:portfolio/src/common/widgets/technology_chip.dart';
import 'package:portfolio/src/constants/sizes.dart';
import 'package:portfolio/src/features/experience/domain/experience.dart';
import 'package:portfolio/src/localization/generated/locale_keys.g.dart';
import 'package:portfolio/src/localization/localized_date_extension.dart';
import 'package:portfolio/src/utils/string_extension.dart';
import 'package:url_launcher/url_launcher.dart';

class CompanyExperienceGroup extends ConsumerStatefulWidget {
  const CompanyExperienceGroup({super.key, required this.experiences});

  final List<Experience> experiences;

  @override
  ConsumerState<CompanyExperienceGroup> createState() =>
      _CompanyExperienceGroupState();
}

class _CompanyExperienceGroupState
    extends ConsumerState<CompanyExperienceGroup> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final company = widget.experiences.first.company ?? '';
    final companyUrl = widget.experiences.first.url;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: (_isHovered && companyUrl != null)
              ? [
                  BoxShadow(
                    color: Theme.of(context)
                        .colorScheme
                        .tertiary
                        .withAlpha(60),
                    blurRadius: 24,
                    spreadRadius: 2,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withAlpha(20),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Material(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(20),
          child: InkWell(
            onTap:
                companyUrl != null ? () => _onTapCompany(context, companyUrl) : null,
            borderRadius: BorderRadius.circular(20),
            hoverColor: Theme.of(context).colorScheme.tertiary.withAlpha(40),
            splashColor: Theme.of(context).colorScheme.tertiary.withAlpha(30),
            highlightColor: Theme.of(context).colorScheme.tertiary.withAlpha(20),
            child: MouseRegion(
              cursor: companyUrl != null
                  ? SystemMouseCursors.click
                  : SystemMouseCursors.basic,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      company,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    gapH12,
                    ...widget.experiences.asMap().entries.map((entry) {
                      final index = entry.key;
                      final experience = entry.value;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (index > 0) ...[
                            Divider(
                              color: Theme.of(context)
                                  .colorScheme
                                  .outline
                                  .withAlpha(60),
                            ),
                            gapH4,
                          ],
                          _RoleEntry(experience: experience),
                        ],
                      );
                    }),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _onTapCompany(BuildContext context, String url) async {
    if (!await launchUrl(Uri.parse(url))) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("${tr(LocaleKeys.openUrlError)} $url")),
        );
      }
    }
  }
}

class _RoleEntry extends ConsumerWidget {
  const _RoleEntry({required this.experience});

  final Experience experience;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                experience.job ?? '',
                style: Theme.of(context)
                    .textTheme
                    .titleSmall
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            gapW24,
            if (!Responsive.isMobile(context)) _buildDateText(context),
          ],
        ),
        if (Responsive.isMobile(context)) ...[
          gapH4,
          _buildDateText(context),
        ],
        gapH8,
        Text(
          experience.description ?? '',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        if (experience.technologies?.isNotEmpty == true) ...[
          gapH12,
          _buildChips(context),
        ],
        gapH4,
      ],
    );
  }

  Widget _buildDateText(BuildContext context) {
    final locale = context.locale;
    final startMonth = experience.startMonth?.localizedMonth(locale) ?? '';
    final startYear = experience.startYear?.localizedYear(locale);
    final startDate =
        startMonth.isEmpty ? startYear : '$startMonth $startYear';
    final endMonth = experience.endMonth?.localizedMonth(locale) ?? '';
    final endYear = experience.endYear?.localizedYear(locale);
    final String? endDate;
    if (experience.isPresent == true) {
      endDate = tr(LocaleKeys.present);
    } else {
      endDate = endMonth.isEmpty ? endYear : '$endMonth $endYear';
    }
    if (startDate == null || endDate == null) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondary.withAlpha(80),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).colorScheme.tertiary.withAlpha(60),
          width: 1,
        ),
      ),
      child: Text(
        '${startDate.capitalize()} — ${endDate.capitalize()}',
        style: Theme.of(context).textTheme.bodySmall,
      ),
    );
  }

  Widget _buildChips(BuildContext context) {
    final technologies = experience.technologies;
    if (technologies == null) return const SizedBox.shrink();
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: technologies.map((technology) {
        return IgnorePointer(child: TechnologyChip(name: technology));
      }).toList(),
    );
  }
}
