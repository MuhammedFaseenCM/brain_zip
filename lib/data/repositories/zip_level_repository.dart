import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';

import '../../core/firebase/firebase_bootstrap.dart';
import '../../domain/entities/zip_level.dart';

class ZipLevelRepository {
  ZipLevelRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ??
            (FirebaseBootstrap.isReady ? FirebaseFirestore.instance : null);

  final FirebaseFirestore? _firestore;

  static const _assetFiles = [
    'assets/zip/levels/level_01.json',
    'assets/zip/levels/level_02.json',
    'assets/zip/levels/level_03.json',
  ];

  Future<List<ZipLevel>> fetchLevels() async {
    if (_firestore != null) {
      try {
        final snap = await _firestore
            .collection('zip_levels')
            .orderBy('order')
            .get(const GetOptions(source: Source.serverAndCache));
        if (snap.docs.isNotEmpty) {
          return snap.docs
              .map((d) => ZipLevel.fromJson(d.data(), id: d.id))
              .toList();
        }
      } catch (_) {
        // fall through to assets
      }
    }
    return _loadAssets();
  }

  Future<List<ZipLevel>> _loadAssets() async {
    final levels = <ZipLevel>[];
    for (final path in _assetFiles) {
      final raw = await rootBundle.loadString(path);
      levels.add(ZipLevel.fromJson(jsonDecode(raw) as Map<String, dynamic>));
    }
    levels.sort((a, b) => a.order.compareTo(b.order));
    return levels;
  }
}
