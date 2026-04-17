import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portfolio/src/constants/sizes.dart';
import 'package:portfolio/src/features/experience/domain/experience.dart';
import 'package:portfolio/src/common/widgets/link.dart';
import 'package:portfolio/src/common/widgets/responsive.dart';
import 'package:portfolio/src/common/widgets/technology_chip.dart';
import 'package:portfolio/src/localization/generated/locale_keys.g.dart';
import 'package:portfolio/src/localization/localized_date_extension.dart';
import 'package:portfolio/src/utils/string_extension.dart';
import 'package:url_launcher/url_launcher.dart';

class ExperienceCard extends ConsumerStatefulWidget {
  const ExperienceCard({super.key, required this.experience});

  final Experience experience;

  @override
  ConsumerState<ExperienceCard> createState() => _ExperienceCardState();
}

class _ExperienceCardState extends ConsumerState<ExperienceCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: _isHovered
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
            onTap: () => _onTap(context),
            borderRadius: BorderRadius.circular(20),
            hoverColor: Theme.of(context).colorScheme.tertiary.withAlpha(40),
            splashColor: Theme.of(context).colorScheme.tertiary.withAlpha(30),
            highlightColor: Theme.of(context).colorScheme.tertiary.withAlpha(20),
            child: MouseRegion(
              cursor: SystemMouseCursors.basic,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            widget.experience.job ?? "",
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                        gapW24,
                        if (!Responsive.isMobile(context))
                          _buildExperienceDateText(context),
                      ],
                    ),
                    if (Responsive.isMobile(context))
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.experience.company ?? "",
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          gapH4,
                          _buildExperienceDateText(context),
                        ],
                      )
                    else
                      Text(
                        widget.experience.company ?? "",
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    gapH8,
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            widget.experience.description ?? "",
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                    gapH12,
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLinks(),
                        if (widget.experience.links?.isNotEmpty == true) gapH12 else gapH4,
                        _buildChips(context),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _onTap(BuildContext context) async {
    final url = widget.experience.url;
    if (url == null) return;
    if (!await launchUrl(Uri.parse(url))) {
      if (context.mounted) {
        final snackBar = SnackBar(
          content: Text(
            "${tr(LocaleKeys.openUrlError)} ${widget.experience.url}",
          ),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    }
  }

  Widget _buildExperienceDateText(BuildContext context) {
    final locale = context.locale;
    final startMonth = widget.experience.startMonth?.localizedMonth(locale) ?? "";
    final startYear = widget.experience.startYear?.localizedYear(locale);
    final startDate = startMonth.isEmpty ? startYear : "$startMonth $startYear";
    final endMonth = widget.experience.endMonth?.localizedMonth(locale) ?? "";
    final endYear = widget.experience.endYear?.localizedYear(locale);
    String? endDate;
    if (widget.experience.isPresent == true) {
      endDate = tr(LocaleKeys.present);
    } else {
      endDate = endMonth.isEmpty ? endYear : "$endMonth $endYear";
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
        "${startDate.capitalize()} — ${endDate.capitalize()}",
        style: Theme.of(context).textTheme.bodySmall,
      ),
    );
  }

  Widget _buildChips(BuildContext context) {
    final experienceTechnologies = widget.experience.technologies;
    if (experienceTechnologies == null) return const SizedBox.shrink();
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: experienceTechnologies.map((technology) {
        return IgnorePointer(
          child: TechnologyChip(name: technology),
        );
      }).toList(),
    );
  }

  Widget _buildLinks() {
    final experienceLinks = widget.experience.links;
    if (experienceLinks == null) return const SizedBox.shrink();
    return Wrap(
      spacing: 16,
      runSpacing: 4,
      children: experienceLinks.map((link) {
        final experienceLinkUrl = link.url;
        final experienceLinkDisplay = link.display;
        if (experienceLinkUrl == null) return const SizedBox.shrink();
        return Link(
          url: experienceLinkUrl,
          displayLink: experienceLinkDisplay ?? experienceLinkUrl,
          displayLeadingIcon: true,
        );
      }).toList(),
    );
  }
}
