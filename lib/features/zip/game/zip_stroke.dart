import 'package:flutter/material.dart';

abstract final class ZipStroke {
  static List<Offset> points({
    required List<Offset> cellCenters,
    Offset? liveTip,
  }) {
    if (cellCenters.isEmpty) return const [];
    if (liveTip == null) return List<Offset>.of(cellCenters);

    final last = cellCenters.last;
    final railed = rail(origin: last, finger: liveTip);
    if (cellCenters.length == 1) {
      if ((railed - last).distanceSquared < 1) return [last];
      return [last, railed];
    }

    final prev = cellCenters[cellCenters.length - 2];
    final incoming = last - prev;
    final outgoing = railed - last;
    final incomingHorizontal = incoming.dx.abs() >= incoming.dy.abs();
    final outgoingHorizontal = outgoing.dx.abs() >= outgoing.dy.abs();
    final continuingStraight =
        outgoing.distanceSquared < 1 ||
        incomingHorizontal == outgoingHorizontal;
    if (continuingStraight) {
      return [...cellCenters.sublist(0, cellCenters.length - 1), railed];
    }
    return [...cellCenters, railed];
  }

  static Offset rail({required Offset origin, required Offset finger}) {
    final dx = finger.dx - origin.dx;
    final dy = finger.dy - origin.dy;
    if (dx.abs() >= dy.abs()) return Offset(finger.dx, origin.dy);
    return Offset(origin.dx, finger.dy);
  }

  static Offset railWithin({
    required Offset origin,
    required Offset finger,
    required Rect bounds,
  }) {
    final railed = rail(origin: origin, finger: finger);
    return Offset(
      railed.dx.clamp(bounds.left, bounds.right),
      railed.dy.clamp(bounds.top, bounds.bottom),
    );
  }
}
