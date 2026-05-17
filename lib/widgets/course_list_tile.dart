import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/course.dart';
import '../utils/string_extensions.dart';

class CourseListTile extends StatelessWidget {
  final Course course;
  final bool isExpanded;
  final VoidCallback onTap;

  const CourseListTile({
    super.key,
    required this.course,
    this.isExpanded = false,
    required this.onTap,
  });

  IconData _getCategoryIcon(String courseId) {
    final id = courseId.toUpperCase();
    if (id.startsWith('CSET')) return Icons.computer;
    if (id.startsWith('EMAT')) return Icons.calculate;
    if (id.startsWith('EPHY')) return Icons.science;
    if (id.startsWith('UVAC')) return Icons.eco;
    return Icons.menu_book;
  }

  Color _getCategoryColor(String courseId) {
    final id = courseId.toUpperCase();
    if (id.startsWith('CSET')) return Colors.blue;
    if (id.startsWith('EMAT')) return Colors.orange;
    if (id.startsWith('EPHY')) return Colors.teal;
    if (id.startsWith('UVAC')) return Colors.green;
    return Colors.indigo;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    final courseName = course.name
        .replaceAll('_', ' ')
        .split(' ')
        .map((word) => word.capitalize())
        .join(' ');

    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _getCategoryColor(course.primaryCourseId).withValues(alpha: isDark ? 0.2 : 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                _getCategoryIcon(course.primaryCourseId),
                size: 18,
                color: _getCategoryColor(course.primaryCourseId),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    courseName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    course.joinedCourseIds.toUpperCase(),
                    style: TextStyle(
                      fontSize: 12,
                      fontFamily: 'monospace',
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            AnimatedRotation(
              turns: isExpanded ? 0.25 : 0,
              duration: const Duration(milliseconds: 200),
              child: Icon(
                Icons.chevron_right,
                size: 20,
                color: theme.colorScheme.outline.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
