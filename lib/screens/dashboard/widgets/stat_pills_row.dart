import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

/// Data class for a single stat pill
class StatPillData {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const StatPillData({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });
}

/// Horizontal scrolling row of compact stat pills
class StatPillsRow extends StatelessWidget {
  final List<StatPillData> stats;
  final bool isDark;

  const StatPillsRow({super.key, required this.stats, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 64,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: stats.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, index) =>
            _StatPill(stat: stats[index], isDark: isDark, index: index),
      ),
    );
  }
}

class _StatPill extends StatefulWidget {
  final StatPillData stat;
  final bool isDark;
  final int index;

  const _StatPill({
    required this.stat,
    required this.isDark,
    required this.index,
  });

  @override
  State<_StatPill> createState() => _StatPillState();
}

class _StatPillState extends State<_StatPill>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  bool _hasAnimated = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 300 + (widget.index * 60)),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _scaleAnimation = Tween<double>(
      begin: 0.9,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_hasAnimated) {
        _controller.forward();
        _hasAnimated = true;
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stat = widget.stat;

    // Generate gradient colors
    final gradientEnd = HSLColor.fromColor(stat.color)
        .withLightness(
          (HSLColor.fromColor(stat.color).lightness + 0.15).clamp(0.0, 1.0),
        )
        .toColor();

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _hasAnimated && !_controller.isAnimating
              ? 1.0
              : _fadeAnimation.value,
          child: Transform.scale(
            scale: _hasAnimated && !_controller.isAnimating
                ? 1.0
                : _scaleAnimation.value,
            child: child,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: widget.isDark ? AppTheme.darkCard : AppTheme.lightCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: stat.color.withValues(alpha: 0.15),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: stat.color.withValues(alpha: widget.isDark ? 0.12 : 0.08),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
            BoxShadow(
              color: Colors.black.withValues(
                alpha: widget.isDark ? 0.12 : 0.04,
              ),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon with gradient background
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    stat.color.withValues(alpha: 0.2),
                    gradientEnd.withValues(alpha: 0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: stat.color.withValues(alpha: 0.25),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ShaderMask(
                shaderCallback: (bounds) => LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [stat.color, gradientEnd],
                ).createShader(bounds),
                child: Icon(stat.icon, color: Colors.white, size: 18),
              ),
            ),
            const SizedBox(width: 10),
            // Value and title
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TweenAnimationBuilder<int>(
                  tween: IntTween(begin: 0, end: int.tryParse(stat.value) ?? 0),
                  duration: const Duration(milliseconds: 700),
                  curve: Curves.easeOutCubic,
                  builder: (context, animValue, child) {
                    return Text(
                      animValue.toString(),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: widget.isDark
                            ? Colors.white
                            : const Color(0xFF1A1A2E),
                      ),
                    );
                  },
                ),
                Text(
                  stat.title,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: widget.isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
