import 'dart:math' as math;

import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/cell.dart';
import '../../../domain/entities/path_words_puzzle.dart';
import 'path_words_board_view.dart';

class PathWordsGame extends FlameGame with DragCallbacks {
  PathWordsGame({
    required this.view,
    required this.onPointerDown,
    required this.onPointerEnter,
    required this.onPointerUp,
  });

  PathWordsBoardView view;
  final void Function(Cell) onPointerDown;
  final void Function(Cell) onPointerEnter;
  final void Function() onPointerUp;

  late double _cellSize;
  late Offset _origin;
  late double _boardRadius;

  Vector2? _lastPointer;
  Cell? _lastEnteredCell;
  bool _drawing = false;

  DateTime? _hintFlashStartedAt;

  @override
  Color backgroundColor() => const Color(0x00000000);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _layout();
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    _layout();
  }

  void applyView(PathWordsBoardView view) {
    final oldHint = this.view.hintFlashCell;
    this.view = view;
    if (view.hintFlashCell != null && view.hintFlashCell != oldHint) {
      _hintFlashStartedAt = DateTime.now();
    }
    if (view.hintFlashCell == null) {
      _hintFlashStartedAt = null;
    }
    _layout();
  }

  void _layout() {
    final padding = 10.0;
    final usable = math.min(size.x, size.y);
    final boardSize = view.puzzle.size;
    _cellSize = (usable - padding * 2) / boardSize;
    final board = _cellSize * boardSize;
    _origin = Offset((size.x - board) / 2, (size.y - board) / 2);
    _boardRadius = math.min(22.0, _cellSize * 0.4);
  }

  Cell? _cellAt(Vector2 position) {
    final local = Offset(position.x - _origin.dx, position.y - _origin.dy);
    final pad = _cellSize * 0.05;
    if (local.dx < -pad || local.dy < -pad) return null;
    final board = _cellSize * view.puzzle.size;
    if (local.dx > board + pad || local.dy > board + pad) return null;

    final col = local.dx.clamp(0, board - 0.001) ~/ _cellSize;
    final row = local.dy.clamp(0, board - 0.001) ~/ _cellSize;
    final cell = Cell(row.toInt(), col.toInt());
    if (!_inBounds(cell)) return null;
    return cell;
  }

  bool _inBounds(Cell cell) {
    return cell.row >= 0 &&
        cell.row < view.puzzle.size &&
        cell.col >= 0 &&
        cell.col < view.puzzle.size;
  }

  Offset _centerOf(Cell cell) {
    return Offset(
      _origin.dx + (cell.col + 0.5) * _cellSize,
      _origin.dy + (cell.row + 0.5) * _cellSize,
    );
  }

  Rect _cellRect(Cell cell, {double inset = 0}) {
    return Rect.fromLTWH(
      _origin.dx + cell.col * _cellSize + inset,
      _origin.dy + cell.row * _cellSize + inset,
      _cellSize - inset * 2,
      _cellSize - inset * 2,
    );
  }

  void _tracePointer(Vector2 from, Vector2 to) {
    final delta = to - from;
    final distance = delta.length;
    final step = math.max(_cellSize * 0.2, 1.0);
    final samples = math.max(1, (distance / step).ceil());
    for (var i = 0; i <= samples; i++) {
      final t = samples == 0 ? 1.0 : i / samples;
      final point = from + delta * t;
      final cell = _cellAt(point);
      if (cell == null) continue;

      if (_lastEnteredCell == cell) continue;
      _lastEnteredCell = cell;
      if (!view.inputEnabled) continue;
      onPointerEnter(cell);
    }
  }

  @override
  void onDragStart(DragStartEvent event) {
    super.onDragStart(event);
    final pos = event.localPosition;
    _lastPointer = pos.clone();
    _lastEnteredCell = null;

    final cell = _cellAt(pos);
    if (cell == null || !view.inputEnabled) {
      _drawing = false;
      return;
    }

    _drawing = true;
    _lastEnteredCell = cell;
    onPointerDown(cell);
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    super.onDragUpdate(event);
    if (!_drawing) return;
    final to = event.localEndPosition;
    final from = _lastPointer ?? to;
    _tracePointer(from, to);
    _lastPointer = to.clone();
  }

  @override
  void onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);
    if (_drawing && view.inputEnabled) {
      onPointerUp();
    }
    _drawing = false;
    _lastPointer = null;
    _lastEnteredCell = null;
  }

  @override
  void onDragCancel(DragCancelEvent event) {
    super.onDragCancel(event);
    if (_drawing && view.inputEnabled) {
      onPointerUp();
    }
    _drawing = false;
    _lastPointer = null;
    _lastEnteredCell = null;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    _drawBoardShadow(canvas);
    _drawBoard(canvas);
    _drawCompletedPaths(canvas);
    _drawActivePath(canvas);
    _drawStartChecks(canvas);
    _drawHintFlash(canvas);
    _drawLetters(canvas);
  }

  void _drawBoardShadow(Canvas canvas) {
    final board = _cellSize * view.puzzle.size;
    final rect = Rect.fromLTWH(_origin.dx, _origin.dy, board, board);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        rect.translate(0, 6),
        Radius.circular(_boardRadius),
      ),
      Paint()..color = Colors.black.withValues(alpha: 0.35),
    );
  }

  void _drawBoard(Canvas canvas) {
    final board = _cellSize * view.puzzle.size;
    final rect = Rect.fromLTWH(_origin.dx, _origin.dy, board, board);
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(_boardRadius));

    canvas.drawRRect(rrect, Paint()..color = ZipColors.wall);
    canvas.drawRRect(
      rrect,
      Paint()
        ..color = ZipColors.outline
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    final grid = Paint()
      ..color = ZipColors.mistDeep
      ..strokeWidth = 1.2;
    for (var i = 1; i < view.puzzle.size; i++) {
      final x = _origin.dx + i * _cellSize;
      final y = _origin.dy + i * _cellSize;
      canvas.drawLine(
        Offset(x, _origin.dy),
        Offset(x, _origin.dy + board),
        grid,
      );
      canvas.drawLine(
        Offset(_origin.dx, y),
        Offset(_origin.dx + board, y),
        grid,
      );
    }
  }

  static const List<Color> pathColors = [
    Color(0xFFFB7185), // rose
    Color(0xFF38BDF8), // sky
    Color(0xFF34D399), // emerald
    Color(0xFFFBBF24), // amber
    Color(0xFFA78BFA), // violet
    Color(0xFF2DD4BF), // teal
    Color(0xFF60A5FA), // blue
    Color(0xFFF472B6), // pink
  ];

  Map<String, PathWordsTarget> _targetsById(PathWordsPuzzle puzzle) {
    return {for (final t in puzzle.targets) t.id: t};
  }

  void _drawCompletedPaths(Canvas canvas) {
    if (view.completedPathsByTargetId.isEmpty) return;

    final targets = _targetsById(view.puzzle);
    final orderedIds = view.puzzle.targets
        .map((t) => t.id)
        .where(view.completedPathsByTargetId.containsKey);

    for (final targetId in orderedIds) {
      final path = view.completedPathsByTargetId[targetId];
      if (path == null || path.isEmpty) continue;
      final target = targets[targetId];
      final colorIndex = target?.colorIndex ?? 0;
      final color = pathColors[colorIndex % pathColors.length];

      final fill = Paint()..color = color.withValues(alpha: 0.28);
      for (final cell in path) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            _cellRect(cell, inset: 2.5),
            Radius.circular(_cellSize * 0.18),
          ),
          fill,
        );
      }

      _drawArrows(canvas, path: path, color: color.withValues(alpha: 0.75));
    }
  }

  void _drawActivePath(Canvas canvas) {
    if (view.activePath.isEmpty) return;
    final fill = Paint()..color = ZipColors.emberSoft.withValues(alpha: 0.85);
    for (final cell in view.activePath) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          _cellRect(cell, inset: 3),
          Radius.circular(_cellSize * 0.18),
        ),
        fill,
      );
    }

    final strokeWidth = _cellSize * 0.14;
    final stroke = Paint()
      ..color = ZipColors.ember.withValues(alpha: 0.95)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    if (view.activePath.length == 1) {
      canvas.drawCircle(
        _centerOf(view.activePath.first),
        strokeWidth * 0.55,
        Paint()..color = ZipColors.ember,
      );
    } else {
      final p = Path();
      final first = _centerOf(view.activePath.first);
      p.moveTo(first.dx, first.dy);
      for (var i = 1; i < view.activePath.length; i++) {
        final c = _centerOf(view.activePath[i]);
        p.lineTo(c.dx, c.dy);
      }
      canvas.drawPath(p, stroke);
      canvas.drawPath(
        p,
        Paint()
          ..color = Colors.white.withValues(alpha: 0.25)
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth * 0.45
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round,
      );
    }

    _drawArrows(
      canvas,
      path: view.activePath,
      color: ZipColors.ember.withValues(alpha: 0.9),
    );
  }

  void _drawArrows(
    Canvas canvas, {
    required List<Cell> path,
    required Color color,
  }) {
    if (path.length < 2) return;

    final line = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(2.0, _cellSize * 0.07)
      ..strokeCap = StrokeCap.round;

    for (var i = 1; i < path.length; i++) {
      final a = _centerOf(path[i - 1]);
      final b = _centerOf(path[i]);
      canvas.drawLine(a, b, line);

      final dx = b.dx - a.dx;
      final dy = b.dy - a.dy;
      final len = math.sqrt(dx * dx + dy * dy);
      if (len < 0.001) continue;
      final ux = dx / len;
      final uy = dy / len;

      final arrowLength = _cellSize * 0.22;
      final arrowWidth = _cellSize * 0.14;
      final tip = b;
      final base = Offset(tip.dx - ux * arrowLength, tip.dy - uy * arrowLength);
      final perp = Offset(-uy, ux);
      final left = Offset(
        base.dx + perp.dx * (arrowWidth / 2),
        base.dy + perp.dy * (arrowWidth / 2),
      );
      final right = Offset(
        base.dx - perp.dx * (arrowWidth / 2),
        base.dy - perp.dy * (arrowWidth / 2),
      );

      final head = Path()
        ..moveTo(tip.dx, tip.dy)
        ..lineTo(left.dx, left.dy)
        ..lineTo(right.dx, right.dy)
        ..close();
      canvas.drawPath(head, Paint()..color = color.withValues(alpha: 0.95));
    }
  }

  void _drawStartChecks(Canvas canvas) {
    final completed = view.completedPathsByTargetId.keys.toSet();
    final paint = Paint()
      ..color = ZipColors.onInk.withValues(alpha: 0.42)
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(2.0, _cellSize * 0.06)
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    for (final target in view.puzzle.targets) {
      if (completed.contains(target.id)) continue;
      final center = _centerOf(target.start);
      final s = _cellSize * 0.18;
      final p = Path()
        ..moveTo(center.dx - s * 0.9, center.dy + s * 0.05)
        ..lineTo(center.dx - s * 0.25, center.dy + s * 0.7)
        ..lineTo(center.dx + s * 0.95, center.dy - s * 0.8);
      canvas.drawPath(p, paint);
    }
  }

  void _drawHintFlash(Canvas canvas) {
    final cell = view.hintFlashCell;
    if (cell == null) return;

    final startedAt = _hintFlashStartedAt ?? DateTime.now();
    final t = DateTime.now().difference(startedAt).inMilliseconds / 1000.0;
    final pulse = (math.sin(t * math.pi * 2) * 0.5 + 0.5);
    final alpha = (0.25 + pulse * 0.35).clamp(0.0, 1.0);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        _cellRect(cell, inset: 2),
        Radius.circular(_cellSize * 0.2),
      ),
      Paint()..color = ZipColors.success.withValues(alpha: alpha),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        _cellRect(cell, inset: 2),
        Radius.circular(_cellSize * 0.2),
      ),
      Paint()
        ..color = Colors.white.withValues(alpha: alpha * 0.9)
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(2.0, _cellSize * 0.06),
    );
  }

  void _drawLetters(Canvas canvas) {
    final completedCells = <Cell>{};
    for (final path in view.completedPathsByTargetId.values) {
      completedCells.addAll(path);
    }
    final activeCells = view.activePath.toSet();

    for (var row = 0; row < view.puzzle.size; row++) {
      for (var col = 0; col < view.puzzle.size; col++) {
        final cell = Cell(row, col);
        final center = _centerOf(cell);
        final isCompleted = completedCells.contains(cell);
        final isActive = activeCells.contains(cell);
        final isHint = view.hintFlashCell == cell;

        final color = isActive
            ? Colors.white
            : isHint
            ? Colors.white.withValues(alpha: 0.95)
            : isCompleted
            ? ZipColors.onInk.withValues(alpha: 0.92)
            : ZipColors.onInk;

        final tp = TextPainter(
          text: TextSpan(
            text: view.puzzle.letterAt(cell).toUpperCase(),
            style: TextStyle(
              color: color,
              fontSize: _cellSize * 0.38,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();

        tp.paint(
          canvas,
          Offset(center.dx - tp.width / 2, center.dy - tp.height / 2),
        );
      }
    }
  }
}
