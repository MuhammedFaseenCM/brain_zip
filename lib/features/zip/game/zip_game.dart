import 'dart:math' as math;

import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/models/zip_level.dart';
import '../logic/path_validator.dart';

typedef ZipWinCallback = void Function(int points, int elapsedSeconds);

class ZipGame extends FlameGame with DragCallbacks {
  ZipGame({
    required this.level,
    required this.onWin,
    required this.onStatsChanged,
  });

  final ZipLevel level;
  final ZipWinCallback onWin;
  final void Function(int pathLength, int nextNumber) onStatsChanged;

  late final PathValidator _validator;
  late double _cellSize;
  late Offset _origin;
  late double _boardRadius;
  final List<Cell> path = [];
  bool _won = false;
  bool _drawing = false;
  DateTime? startedAt;

  @override
  Color backgroundColor() => const Color(0x00000000);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _validator = PathValidator(level);
    startedAt = DateTime.now();
    _layout();
    onStatsChanged(0, 1);
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    _layout();
  }

  void _layout() {
    final padding = 10.0;
    final usable = math.min(size.x, size.y);
    _cellSize = (usable - padding * 2) / level.size;
    final board = _cellSize * level.size;
    _origin = Offset((size.x - board) / 2, (size.y - board) / 2);
    _boardRadius = math.min(22.0, _cellSize * 0.4);
  }

  Cell? _cellAt(Vector2 position) {
    final local = Offset(position.x - _origin.dx, position.y - _origin.dy);
    // Small edge tolerance so fast swipes near borders still register.
    final pad = _cellSize * 0.05;
    if (local.dx < -pad || local.dy < -pad) return null;
    final board = _cellSize * level.size;
    if (local.dx > board + pad || local.dy > board + pad) return null;
    final col = local.dx.clamp(0, board - 0.001) ~/ _cellSize;
    final row = local.dy.clamp(0, board - 0.001) ~/ _cellSize;
    final cell = Cell(row.toInt(), col.toInt());
    if (!_validator.inBounds(cell)) return null;
    return cell;
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

  void undo() {
    if (_won || path.isEmpty) return;
    path.removeLast();
    _notifyStats();
  }

  void clearPath() {
    if (_won) return;
    path.clear();
    _notifyStats();
  }

  void _notifyStats() {
    onStatsChanged(path.length, _validator.nextRequiredAfter(path));
  }

  Vector2? _lastPointer;

  void _applyCell(Cell cell) {
    if (_won) return;

    final backtracked = _validator.tryBacktrack(path: path, candidate: cell);
    if (backtracked != null) {
      path
        ..clear()
        ..addAll(backtracked);
      _notifyStats();
      return;
    }

    final next = _validator.nextRequiredAfter(path);
    final extended = _validator.tryExtend(
      path: path,
      candidate: cell,
      nextRequiredNumber: next,
    );
    if (extended == null) return;

    path
      ..clear()
      ..addAll(extended);
    _notifyStats();

    if (_validator.isWon(path)) {
      _won = true;
      final elapsed = DateTime.now().difference(startedAt!).inSeconds;
      final points = (1000 - elapsed * 5).clamp(50, 1000);
      onWin(points, elapsed);
    }
  }

  /// Sample along the finger path so fast swipes still fill every cell.
  void _tracePointer(Vector2 from, Vector2 to) {
    final delta = to - from;
    final distance = delta.length;
    final step = math.max(_cellSize * 0.2, 1.0);
    final samples = math.max(1, (distance / step).ceil());
    for (var i = 0; i <= samples; i++) {
      final t = samples == 0 ? 1.0 : i / samples;
      final point = from + delta * t;
      final cell = _cellAt(point);
      if (cell != null) _applyCell(cell);
      if (_won) return;
    }
  }

  bool _canStartDrawing(Cell cell) {
    if (path.isEmpty) {
      return level.numbers[cell] == 1;
    }
    if (cell == path.last) return true;
    if (path.length >= 2 && cell == path[path.length - 2]) return true;
    // Allow grabbing from an orthogonal neighbor of the tip.
    return _validator.isOrthogonalNeighbor(path.last, cell);
  }

  @override
  void onDragStart(DragStartEvent event) {
    super.onDragStart(event);
    final pos = event.localPosition;
    final cell = _cellAt(pos);
    _lastPointer = pos.clone();
    if (cell == null) {
      _drawing = false;
      return;
    }

    if (path.isEmpty) {
      if (level.numbers[cell] == 1) {
        _drawing = true;
        _applyCell(cell);
      } else {
        _drawing = false;
      }
      return;
    }

    if (_canStartDrawing(cell)) {
      _drawing = true;
      _applyCell(cell);
      return;
    }
    _drawing = false;
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    super.onDragUpdate(event);
    if (!_drawing || _won) return;
    final to = event.localEndPosition;
    final from = _lastPointer ?? to;
    _tracePointer(from, to);
    _lastPointer = to.clone();
  }

  @override
  void onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);
    _drawing = false;
    _lastPointer = null;
  }

  @override
  void onDragCancel(DragCancelEvent event) {
    super.onDragCancel(event);
    _drawing = false;
    _lastPointer = null;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    _drawBoardShadow(canvas);
    _drawBoard(canvas);
    _drawStartEndHints(canvas);
    _drawPathFill(canvas);
    _drawPathStroke(canvas);
    _drawWalls(canvas);
    _drawNumbers(canvas);
  }

  void _drawBoardShadow(Canvas canvas) {
    final board = _cellSize * level.size;
    final rect = Rect.fromLTWH(_origin.dx, _origin.dy, board, board);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        rect.translate(0, 6),
        Radius.circular(_boardRadius),
      ),
      Paint()..color = ZipColors.ink.withValues(alpha: 0.08),
    );
  }

  void _drawBoard(Canvas canvas) {
    final board = _cellSize * level.size;
    final rect = Rect.fromLTWH(_origin.dx, _origin.dy, board, board);
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(_boardRadius));

    canvas.drawRRect(rrect, Paint()..color = Colors.white);
    canvas.drawRRect(
      rrect,
      Paint()
        ..color = const Color(0xFFD5DEEA)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  void _drawStartEndHints(Canvas canvas) {
    Cell? start;
    Cell? end;
    for (final e in level.numbers.entries) {
      if (e.value == 1) start = e.key;
      if (e.value == level.maxNumber) end = e.key;
    }

    if (start != null && !path.contains(start)) {
      canvas.drawCircle(
        _centerOf(start),
        _cellSize * 0.32,
        Paint()
          ..color = ZipColors.ember.withValues(alpha: 0.12)
          ..style = PaintingStyle.fill,
      );
      canvas.drawCircle(
        _centerOf(start),
        _cellSize * 0.32,
        Paint()
          ..color = ZipColors.ember.withValues(alpha: 0.45)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }

    if (end != null) {
      final visited = path.contains(end);
      canvas.drawCircle(
        _centerOf(end),
        _cellSize * 0.34,
        Paint()
          ..color = (visited ? ZipColors.success : ZipColors.ink)
              .withValues(alpha: visited ? 0.18 : 0.08)
          ..style = PaintingStyle.fill,
      );
      canvas.drawCircle(
        _centerOf(end),
        _cellSize * 0.34,
        Paint()
          ..color = visited ? ZipColors.success : ZipColors.inkSoft
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5,
      );
      // Inner finish ring
      canvas.drawCircle(
        _centerOf(end),
        _cellSize * 0.26,
        Paint()
          ..color = visited
              ? ZipColors.success.withValues(alpha: 0.5)
              : ZipColors.ink.withValues(alpha: 0.2)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );
    }
  }

  void _drawPathFill(Canvas canvas) {
    if (path.isEmpty) return;
    final fill = Paint()..color = ZipColors.emberSoft.withValues(alpha: 0.55);
    for (final cell in path) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          _cellRect(cell, inset: 3),
          const Radius.circular(8),
        ),
        fill,
      );
    }
  }

  void _drawPathStroke(Canvas canvas) {
    if (path.isEmpty) return;

    final width = _cellSize * 0.46;
    final stroke = Paint()
      ..color = ZipColors.ember
      ..style = PaintingStyle.stroke
      ..strokeWidth = width
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    if (path.length == 1) {
      canvas.drawCircle(
        _centerOf(path.first),
        width * 0.42,
        Paint()..color = ZipColors.ember,
      );
      return;
    }

    final p = Path()
      ..moveTo(_centerOf(path.first).dx, _centerOf(path.first).dy);
    for (var i = 1; i < path.length; i++) {
      final c = _centerOf(path[i]);
      p.lineTo(c.dx, c.dy);
    }
    canvas.drawPath(p, stroke);

    // Lighter inner highlight for tube feel.
    canvas.drawPath(
      p,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.28)
        ..style = PaintingStyle.stroke
        ..strokeWidth = width * 0.35
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    final tip = _centerOf(path.last);
    final onFinish = level.numbers[path.last] == level.maxNumber;
    canvas.drawCircle(
      tip,
      width * 0.42,
      Paint()..color = onFinish ? ZipColors.success : ZipColors.ember,
    );
    canvas.drawCircle(
      tip,
      width * 0.42,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );
  }

  void _drawWalls(Canvas canvas) {
    final paint = Paint()
      ..color = ZipColors.wall
      ..strokeWidth = math.max(5.0, _cellSize * 0.12)
      ..strokeCap = StrokeCap.round;

    for (final wall in level.walls) {
      final a = wall.a;
      final b = wall.b;
      late Offset p1;
      late Offset p2;
      final inset = _cellSize * 0.16;
      if (a.row == b.row) {
        final row = a.row;
        final col = math.max(a.col, b.col);
        final x = _origin.dx + col * _cellSize;
        p1 = Offset(x, _origin.dy + row * _cellSize + inset);
        p2 = Offset(x, _origin.dy + (row + 1) * _cellSize - inset);
      } else {
        final col = a.col;
        final row = math.max(a.row, b.row);
        final y = _origin.dy + row * _cellSize;
        p1 = Offset(_origin.dx + col * _cellSize + inset, y);
        p2 = Offset(_origin.dx + (col + 1) * _cellSize - inset, y);
      }
      canvas.drawLine(p1, p2, paint);
    }
  }

  void _drawNumbers(Canvas canvas) {
    final next = _validator.nextRequiredAfter(path);
    for (final entry in level.numbers.entries) {
      final n = entry.value;
      final center = _centerOf(entry.key);
      final isNext = n == next;
      final visited = path.contains(entry.key);
      final isEnd = n == level.maxNumber;

      if (isNext && !visited) {
        canvas.drawCircle(
          center,
          _cellSize * 0.3,
          Paint()..color = ZipColors.emberSoft,
        );
      }

      final tp = TextPainter(
        text: TextSpan(
          text: '$n',
          style: TextStyle(
            color: visited
                ? (isEnd ? ZipColors.success : ZipColors.number)
                    .withValues(alpha: 0.55)
                : isEnd
                    ? ZipColors.ink
                    : ZipColors.number,
            fontSize: _cellSize * (isEnd ? 0.4 : 0.36),
            fontWeight: FontWeight.w800,
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
