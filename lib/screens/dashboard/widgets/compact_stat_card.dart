import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

/// Enhanced compact stat card widget with gradient icon and glow effects
class CompactStatCard extends StatefulWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final bool isDark;
  final int animationIndex;

  const CompactStatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.isDark,
    this.animationIndex = 0,
  });

  @override
  State<CompactStatCard> createState() => _CompactStatCardState();
}

class _CompactStatCardState extends State<CompactStatCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  bool _hasAnimated = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 300 + (widget.animationIndex * 80)),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    
    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
    
    // Only animate once on first build
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
    // Generate gradient colors based on main color
    final gradientStart = widget.color;
    final gradientEnd = HSLColor.fromColor(widget.color)
        .withLightness((HSLColor.fromColor(widget.color).lightness + 0.15).clamp(0, 1))
        .toColor();

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _hasAnimated && !_controller.isAnimating ? 1.0 : _fadeAnimation.value,
          child: Transform.scale(
            scale: _hasAnimated && !_controller.isAnimating ? 1.0 : _scaleAnimation.value,
            child: child,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: widget.isDark ? AppTheme.darkCard : AppTheme.lightCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: widget.isDark
                ? widget.color.withValues(alpha: 0.1)
                : widget.color.withValues(alpha: 0.08),
            width: 1,
          ),
          boxShadow: [
            // Color-matched glow (subtle)
            BoxShadow(
              color: widget.color.withValues(alpha: widget.isDark ? 0.12 : 0.06),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
            // Base shadow
            BoxShadow(
              color: Colors.black.withValues(alpha: widget.isDark ? 0.15 : 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Gradient Icon Container with glow
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    gradientStart.withValues(alpha: 0.2),
                    gradientEnd.withValues(alpha: 0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: widget.color.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ShaderMask(
                shaderCallback: (bounds) => LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [gradientStart, gradientEnd],
                ).createShader(bounds),
                child: Icon(
                  widget.icon,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Value and Title
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  TweenAnimationBuilder<int>(
                    tween: IntTween(begin: 0, end: int.tryParse(widget.value) ?? 0),
                    duration: const Duration(milliseconds: 800),
                    curve: Curves.easeOutCubic,
                    builder: (context, animValue, child) {
                      return Text(
                        animValue.toString(),
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: widget.isDark
                              ? Colors.white
                              : const Color(0xFF1A1A2E),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 2),
                  Text(
                    widget.title,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: widget.isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
