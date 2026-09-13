import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Soft mist gradient + faint diagonal path motif behind Zip screens.
class ZipAtmosphere extends StatelessWidget {
  const ZipAtmosphere({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFEEF3F9),
                ZipColors.mist,
                Color(0xFFE4EAF3),
              ],
            ),
          ),
        ),
        const Positioned.fill(
          child: CustomPaint(painter: _PathMotifPainter()),
        ),
        child,
      ],
    );
  }
}

class _PathMotifPainter extends CustomPainter {
  const _PathMotifPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = ZipColors.ember.withValues(alpha: 0.06)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 18
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path()
      ..moveTo(size.width * 0.75, -20)
      ..lineTo(size.width * 0.75, size.height * 0.22)
      ..lineTo(size.width * 0.35, size.height * 0.22)
      ..lineTo(size.width * 0.35, size.height * 0.48)
      ..lineTo(size.width * 1.05, size.height * 0.48);

    canvas.drawPath(path, paint);

    final paint2 = Paint()
      ..color = ZipColors.ink.withValues(alpha: 0.03)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round;

    final path2 = Path()
      ..moveTo(-30, size.height * 0.72)
      ..lineTo(size.width * 0.45, size.height * 0.72)
      ..lineTo(size.width * 0.45, size.height * 1.1);

    canvas.drawPath(path2, paint2);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Single brand mark used in UI — same asset as launcher / splash.
class ZipMark extends StatelessWidget {
  const ZipMark({super.key, this.size = 56});

  final double size;

  static const assetPath = 'assets/branding/app_icon.png';

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(size * 0.22),
      child: Image.asset(
        assetPath,
        width: size,
        height: size,
        fit: BoxFit.cover,
        filterQuality: FilterQuality.high,
        gaplessPlayback: true,
      ),
    );
  }
}

class ZipPrimaryButton extends StatelessWidget {
  const ZipPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: onPressed,
        child: icon == null
            ? Text(label)
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 20),
                  const SizedBox(width: 8),
                  Text(label),
                ],
              ),
      ),
    );
  }
}

class ZipHudPill extends StatelessWidget {
  const ZipHudPill({
    super.key,
    required this.icon,
    required this.label,
    this.emphasize = false,
  });

  final IconData icon;
  final String label;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: emphasize ? ZipColors.emberSoft : ZipColors.paper,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: emphasize
              ? ZipColors.ember.withValues(alpha: 0.35)
              : const Color(0xFFD8E0EB),
        ),
        boxShadow: [
          BoxShadow(
            color: ZipColors.ink.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: emphasize ? ZipColors.emberDeep : ZipColors.inkSoft,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: emphasize ? ZipColors.emberDeep : ZipColors.ink,
                ),
          ),
        ],
      ),
    );
  }
}

class PulseDot extends StatefulWidget {
  const PulseDot({super.key, this.color = ZipColors.ember});

  final Color color;

  @override
  State<PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<PulseDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) {
        final t = Curves.easeInOut.transform(_c.value);
        return Container(
          width: 8 + t * 2,
          height: 8 + t * 2,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.color.withValues(alpha: 0.55 + t * 0.45),
          ),
        );
      },
    );
  }
}
