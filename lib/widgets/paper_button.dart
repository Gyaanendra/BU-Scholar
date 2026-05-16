import 'package:flutter/material.dart';

class PaperButton extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveFontSize = fontSize ?? 12.5;

    return ElevatedButton.icon(
      onPressed: () {
        Navigator.pushNamed(context, '/pdf_viewer', arguments: url);
      },
      icon: Icon(Icons.picture_as_pdf_outlined, size: effectiveFontSize * 1.2),
      label: Text(
        label,
        style: TextStyle(
          fontSize: effectiveFontSize,
          fontWeight: FontWeight.w500,
          height: 1.2,
        ),
        softWrap: true,
        textAlign: TextAlign.center,
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: theme.colorScheme.primaryContainer,
        foregroundColor: theme.colorScheme.onPrimaryContainer,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        minimumSize: const Size(0, 32),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }
}
