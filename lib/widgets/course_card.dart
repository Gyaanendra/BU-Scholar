import 'package:flutter/material.dart';
import '../models/course.dart';
import '../services/pyq_data_service.dart';
import '../utils/string_extensions.dart';
import 'paper_button.dart';

class CourseCard extends StatelessWidget {
  static const int _visibleCap = 4;
  static const double _paperSpacing = 8.0;

  final Course course;
  final bool isExpanded;
  final VoidCallback onToggleExpand;

  const CourseCard({
    super.key,
    required this.course,
    required this.isExpanded,
    required this.onToggleExpand,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final courseName = course.name
        .replaceAll('_', ' ')
        .split(' ')
        .map((word) => word.capitalize())
        .join(' ');
    final courseCode = course.joinedCourseIds.toUpperCase();

    final papers = course.papers;
    final hasMore = papers.length > _visibleCap;
    final visiblePapers = (isExpanded || !hasMore)
        ? papers
        : papers.take(_visibleCap).toList();
    final hiddenCount = papers.length - _visibleCap;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.zero,
      child: AnimatedSize(
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOut,
        alignment: Alignment.topCenter,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                courseName,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  height: 1.25,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                courseCode,
                style: TextStyle(
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                  color: theme.colorScheme.primary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              if (papers.isEmpty)
                Text(
                  'No papers available',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                )
              else
                Wrap(
                  spacing: _paperSpacing,
                  runSpacing: _paperSpacing,
                  alignment: WrapAlignment.center,
                  children: [
                    for (final paper in visiblePapers)
                      PaperButton(
                        label: paper.label,
                        url: PyqDataService.paperUrl(paper),
                      ),
                    if (hasMore)
                      _ToggleButton(
                        label: isExpanded
                            ? 'Show less'
                            : '+$hiddenCount more',
                        expanded: isExpanded,
                        onTap: onToggleExpand,
                      ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ToggleButton extends StatelessWidget {
  final String label;
  final bool expanded;
  final VoidCallback onTap;

  const _ToggleButton({
    required this.label,
    required this.expanded,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return TextButton.icon(
      onPressed: onTap,
      icon: Icon(
        expanded ? Icons.expand_less : Icons.expand_more,
        size: 16,
      ),
      label: Text(
        label,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      ),
      style: TextButton.styleFrom(
        foregroundColor: theme.colorScheme.primary,
        backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.08),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        minimumSize: const Size(0, 32),
      ),
    );
  }
}
