import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PaperButton extends StatefulWidget {
  final String label;
  final String url;
  final double? fontSize;

  const PaperButton({
    super.key,
    required this.label,
    required this.url,
    this.fontSize,
  });

  @override
  State<PaperButton> createState() => _PaperButtonState();
}

class _PaperButtonState extends State<PaperButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _getCompactLabel(String fullLabel, bool isSmall) {
    if (!isSmall) return fullLabel;
    String text = fullLabel;
    text = text.replaceAll('Supplementary Examination', 'Supp');
    text = text.replaceAll('Supplementary', 'Supp');
    text = text.replaceAll('Makeup Examination', 'Makeup');
    text = text.replaceAll('End Semester', 'End');
    text = text.replaceAll('Mid Semester', 'Mid');
    text = text.replaceAll('NPTEL Assignment', 'NPTEL');
    text = text.replaceAll('Assignment', 'Asgn');
    return text;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmall = screenWidth < 450;
    
    final displayLabel = _getCompactLabel(widget.label, isSmall);
    final effectiveFontSize = widget.fontSize ?? (isSmall ? 11.5 : 13.0);

    final lowerLabel = widget.label.toLowerCase();
    
    final isDark = theme.brightness == Brightness.dark;
    
    Color bgColor = theme.colorScheme.primaryContainer;
    Color fgColor = theme.colorScheme.onPrimaryContainer;

    if (lowerLabel.contains('end semester')) {
      bgColor = Colors.green.withValues(alpha: isDark ? 0.25 : 0.15);
      fgColor = isDark ? Colors.green.shade300 : Colors.green.shade800;
    } else if (lowerLabel.contains('mid semester')) {
      bgColor = Colors.purple.withValues(alpha: isDark ? 0.25 : 0.15);
      fgColor = isDark ? Colors.purple.shade300 : Colors.purple.shade800;
    } else if (lowerLabel.contains('assignment') || lowerLabel.contains('nptel')) {
      bgColor = Colors.indigo.withValues(alpha: isDark ? 0.25 : 0.15);
      fgColor = isDark ? Colors.indigo.shade300 : Colors.indigo.shade800;
    } else if (lowerLabel.contains('lab')) {
      bgColor = Colors.teal.withValues(alpha: isDark ? 0.25 : 0.15);
      fgColor = isDark ? Colors.teal.shade300 : Colors.teal.shade800;
    } else if (lowerLabel.contains('quiz')) {
      bgColor = Colors.orange.withValues(alpha: isDark ? 0.25 : 0.15);
      fgColor = isDark ? Colors.orange.shade300 : Colors.orange.shade800;
    } else if (lowerLabel.contains('supplementary') || lowerLabel.contains('makeup')) {
      bgColor = Colors.deepPurple.withValues(alpha: isDark ? 0.25 : 0.15);
      fgColor = isDark ? Colors.deepPurple.shade300 : Colors.deepPurple.shade800;
    } else if (lowerLabel.contains('notes')) {
      bgColor = Colors.blueGrey.withValues(alpha: isDark ? 0.25 : 0.15);
      fgColor = isDark ? Colors.blueGrey.shade300 : Colors.blueGrey.shade800;
    }

    return GestureDetector(
      onTapDown: (_) {
        HapticFeedback.lightImpact();
        _controller.forward();
      },
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: ElevatedButton.icon(
          onPressed: () {
            Navigator.pushNamed(context, '/pdf_viewer', arguments: widget.url);
          },
          icon: Icon(Icons.picture_as_pdf_outlined, size: effectiveFontSize * 1.3),
          label: Text(
            displayLabel,
            style: TextStyle(
              fontSize: effectiveFontSize,
              fontWeight: FontWeight.w500,
              height: 1.2,
            ),
            softWrap: true,
            textAlign: TextAlign.center,
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: bgColor,
            foregroundColor: fgColor,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(22),
            ),
            padding: EdgeInsets.symmetric(
              horizontal: isSmall ? 10 : 14,
              vertical: isSmall ? 8 : 10,
            ),
            minimumSize: Size(0, isSmall ? 38 : 44),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
      ),
    );
  }
}
