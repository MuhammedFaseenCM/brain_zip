import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../domain/entities/cell.dart';
import '../../domain/entities/wall.dart';
import '../theme/app_theme.dart';

/// Shared mini grid used by canned game tutorials (not the live puzzle).
class TutorialMiniBoard extends StatelessWidget {
  const TutorialMiniBoard({
    super.key,
    required this.size,
    required this.labels,
    required this.path,
    required this.pathProgress,
    this.walls = const [],
    this.highlightCells = const {},
    this.highlightPulse = 1,
    this.drawnFill = false,
    this.pathColor = ZipColors.ember,
    this.showFinger = true,
    this.fingerLifted = false,
    this.boardColor = ZipColors.paper,
  });

  final int size;
  final Map<Cell, String> labels;
  final List<Cell> path;
  final double pathProgress;
  final List<Wall> walls;
  final Set<Cell> highlightCells;
  final double highlightPulse;
  final bool drawnFill;
  final Color pathColor;
  final bool showFinger;
  final bool fingerLifted;
  final Color boardColor;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: boardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: ZipColors.outlineQuiet),
        ),
        child: CustomPaint(
          painter: _TutorialMiniBoardPainter(
            size: size,
            labels: labels,
            path: path,
            pathProgress: pathProgress.clamp(0.0, 1.0),
            walls: walls,
            highlightCells: highlightCells,
            highlightPulse: highlightPulse.clamp(0.0, 1.0),
            drawnFill: drawnFill,
            pathColor: pathColor,
            showFinger: showFinger,
            fingerLifted: fingerLifted,
          ),
        ),
      ),
    );
  }
}

class _TutorialMiniBoardPainter extends CustomPainter {
  _TutorialMiniBoardPainter({
    required this.size,
    required this.labels,
    required this.path,
    required this.pathProgress,
    required this.walls,
    required this.highlightCells,
    required this.highlightPulse,
    required this.drawnFill,
    required this.pathColor,
    required this.showFinger,
    required this.fingerLifted,
  });

  final int size;
  final Map<Cell, String> labels;
  final List<Cell> path;
  final double pathProgress;
  final List<Wall> walls;
  final Set<Cell> highlightCells;
  final double highlightPulse;
  final bool drawnFill;
  final Color pathColor;
  final bool showFinger;
  final bool fingerLifted;

  @override
  void paint(Canvas canvas, Size boardSize) {
    final cellW = boardSize.width / size;
    final cellH = boardSize.height / size;
    final inset = math.min(cellW, cellH) * 0.08;

    Offset centerOf(Cell cell) =>
        Offset((cell.col + 0.5) * cellW, (cell.row + 0.5) * cellH);

    final visibleCount = path.isEmpty
        ? 0
        : math.max(1, (pathProgress * path.length).ceil());
    final visiblePath = path.isEmpty
        ? const <Cell>[]
        : path.take(visibleCount.clamp(0, path.length)).toList();
    final filled = drawnFill ? visiblePath.toSet() : const <Cell>{};

    final gridPaint = Paint()
      ..color = ZipColors.outlineQuiet
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (var r = 0; r < size; r++) {
      for (var c = 0; c < size; c++) {
        final cell = Cell(r, c);
        final rect = Rect.fromLTWH(
          c * cellW + inset,
          r * cellH + inset,
          cellW - inset * 2,
          cellH - inset * 2,
        );
        final fill = Paint()
          ..color = filled.contains(cell)
              ? pathColor.withValues(alpha: 0.28)
              : ZipColors.wall;
        canvas.drawRRect(
          RRect.fromRectAndRadius(rect, const Radius.circular(8)),
          fill,
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(rect, const Radius.circular(8)),
          gridPaint,
        );

        if (highlightCells.contains(cell) && highlightPulse > 0) {
          canvas.drawRRect(
            RRect.fromRectAndRadius(rect, const Radius.circular(8)),
            Paint()
              ..color = pathColor.withValues(alpha: 0.35 * highlightPulse)
              ..style = PaintingStyle.stroke
              ..strokeWidth = 3,
          );
        }

        final label = labels[cell];
        if (label != null && label.isNotEmpty) {
          final tp = TextPainter(
            text: TextSpan(
              text: label,
              style: TextStyle(
                color: ZipColors.onInk,
                fontWeight: FontWeight.w800,
                fontSize: math.min(cellW, cellH) * 0.38,
              ),
            ),
            textDirection: TextDirection.ltr,
          )..layout();
          tp.paint(
            canvas,
            centerOf(cell) - Offset(tp.width / 2, tp.height / 2),
          );
        }
      }
    }

    final wallPaint = Paint()
      ..color = ZipColors.onInk
      ..strokeWidth = math.min(cellW, cellH) * 0.12
      ..strokeCap = StrokeCap.round;
    for (final wall in walls) {
      final a = centerOf(wall.a);
      final b = centerOf(wall.b);
      final mid = Offset((a.dx + b.dx) / 2, (a.dy + b.dy) / 2);
      final dir = b - a;
      final len = dir.distance;
      if (len == 0) continue;
      final normal = Offset(-dir.dy / len, dir.dx / len);
      final half = math.min(cellW, cellH) * 0.28;
      canvas.drawLine(mid - normal * half, mid + normal * half, wallPaint);
    }

    if (visiblePath.length >= 2) {
      final pathPaint = Paint()
        ..color = pathColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.min(cellW, cellH) * 0.18
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;
      final uiPath = ui.Path()
        ..moveTo(
          centerOf(visiblePath.first).dx,
          centerOf(visiblePath.first).dy,
        );
      for (var i = 1; i < visiblePath.length; i++) {
        final p = centerOf(visiblePath[i]);
        uiPath.lineTo(p.dx, p.dy);
      }
      // Partial segment into next cell.
      if (visibleCount < path.length && visiblePath.isNotEmpty) {
        final from = centerOf(visiblePath.last);
        final to = centerOf(path[visibleCount]);
        final frac = (pathProgress * path.length) - (visibleCount - 1);
        final t = frac.clamp(0.0, 1.0);
        uiPath.lineTo(
          ui.lerpDouble(from.dx, to.dx, t)!,
          ui.lerpDouble(from.dy, to.dy, t)!,
        );
      }
      canvas.drawPath(uiPath, pathPaint);
    }

    if (showFinger && path.isNotEmpty && pathProgress > 0) {
      final fingerPos = _fingerPosition(centerOf);
      _drawFinger(canvas, fingerPos, math.min(cellW, cellH));
    }
  }

  Offset _fingerPosition(Offset Function(Cell) centerOf) {
    if (path.length == 1) return centerOf(path.first);
    final exact = pathProgress * (path.length - 1);
    final i = exact.floor().clamp(0, path.length - 2);
    final t = exact - i;
    final a = centerOf(path[i]);
    final b = centerOf(path[i + 1]);
    final base = Offset(
      ui.lerpDouble(a.dx, b.dx, t)!,
      ui.lerpDouble(a.dy, b.dy, t)!,
    );
    if (!fingerLifted) return base;
    return base.translate(0, -math.min(24.0, (a - b).distance * 0.4));
  }

  void _drawFinger(Canvas canvas, Offset pos, double cellMin) {
    final r = cellMin * 0.22;
    canvas.drawCircle(
      pos,
      r,
      Paint()..color = Colors.white.withValues(alpha: 0.92),
    );
    canvas.drawCircle(
      pos,
      r,
      Paint()
        ..color = ZipColors.ink.withValues(alpha: 0.35)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    canvas.drawCircle(
      pos.translate(r * 0.55, r * 1.1),
      r * 0.55,
      Paint()..color = Colors.white.withValues(alpha: 0.85),
    );
  }

  @override
  bool shouldRepaint(covariant _TutorialMiniBoardPainter oldDelegate) {
    return oldDelegate.pathProgress != pathProgress ||
        oldDelegate.highlightPulse != highlightPulse ||
        oldDelegate.fingerLifted != fingerLifted ||
        oldDelegate.showFinger != showFinger ||
        oldDelegate.drawnFill != drawnFill ||
        oldDelegate.pathColor != pathColor ||
        oldDelegate.size != size ||
        oldDelegate.path != path ||
        oldDelegate.labels != labels ||
        oldDelegate.walls != walls ||
        oldDelegate.highlightCells != highlightCells;
  }
}
