import 'package:flutter/material.dart';

/// Animated shimmer loading skeleton that replaces the content while courses load.
class ShimmerLoading extends StatefulWidget {
  final bool isGridView;
  const ShimmerLoading({super.key, this.isGridView = false});

  @override
  State<ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<ShimmerLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Widget _box({double? width, double height = 14, double radius = 8}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, child) => Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius),
          color: Color.lerp(
            isDark ? const Color(0xFF2A2A2A) : const Color(0xFFDDDDDD),
            isDark ? const Color(0xFF3C3C3C) : const Color(0xFFF5F5F5),
            _anim.value,
          ),
        ),
      ),
    );
  }

  Widget _listTileSkeleton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Theme.of(context)
              .colorScheme
              .surfaceContainerLow
              .withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: Theme.of(context)
                .colorScheme
                .outlineVariant
                .withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          children: [
            _box(width: 36, height: 36, radius: 10),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _box(height: 14),
                  const SizedBox(height: 8),
                  _box(width: 110, height: 10, radius: 5),
                ],
              ),
            ),
            const SizedBox(width: 12),
            _box(width: 18, height: 18, radius: 9),
          ],
        ),
      ),
    );
  }

  Widget _categoryHeaderSkeleton(double width) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Row(
        children: [
          AnimatedBuilder(
            animation: _anim,
            builder: (_, child) => Container(
              width: 4,
              height: 20,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
                color: Color.lerp(
                  Theme.of(context)
                      .colorScheme
                      .primary
                      .withValues(alpha: 0.2),
                  Theme.of(context)
                      .colorScheme
                      .primary
                      .withValues(alpha: 0.08),
                  _anim.value,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          _box(width: width, height: 11, radius: 5),
        ],
      ),
    );
  }

  Widget _gridCardSkeleton() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: Theme.of(context)
              .colorScheme
              .outlineVariant
              .withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _box(width: 46, height: 46, radius: 13),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _box(height: 14),
                    const SizedBox(height: 6),
                    _box(width: 72, height: 10, radius: 5),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(children: [
            Expanded(child: _box(height: 38, radius: 10)),
            const SizedBox(width: 8),
            Expanded(child: _box(height: 38, radius: 10)),
          ]),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(child: _box(height: 38, radius: 10)),
            const SizedBox(width: 8),
            Expanded(child: _box(height: 38, radius: 10)),
          ]),
          const SizedBox(height: 12),
          _box(height: 42, radius: 12),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isGridView) {
      final sw = MediaQuery.of(context).size.width;
      final cols = sw >= 1200 ? 4 : (sw >= 700 ? 3 : (sw >= 480 ? 2 : 1));
      final aspect = sw >= 1200 ? 1.2 : (sw >= 700 ? 1.0 : 0.72);
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: GridView.count(
          crossAxisCount: cols,
          mainAxisSpacing: 14,
          crossAxisSpacing: 14,
          childAspectRatio: aspect,
          children: List.generate(cols * 2, (_) => _gridCardSkeleton()),
        ),
      );
    }

    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        _categoryHeaderSkeleton(130),
        ...List.generate(4, (_) => _listTileSkeleton()),
        _categoryHeaderSkeleton(170),
        ...List.generate(3, (_) => _listTileSkeleton()),
      ],
    );
  }
}
