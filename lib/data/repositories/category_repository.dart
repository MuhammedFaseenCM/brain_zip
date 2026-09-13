import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';

import '../../core/firebase/firebase_bootstrap.dart';
import '../../domain/entities/word_category.dart';

class CategoryRepository {
  CategoryRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ??
            (FirebaseBootstrap.isReady ? FirebaseFirestore.instance : null);

  final FirebaseFirestore? _firestore;

  static const _assetFiles = [
    'assets/words/categories/animals.json',
    'assets/words/categories/food.json',
    'assets/words/categories/sports.json',
  ];

  Future<List<WordCategory>> fetchCategories() async {
    if (_firestore != null) {
      try {
        final snap = await _firestore
            .collection('categories')
            .orderBy('order')
            .get(const GetOptions(source: Source.serverAndCache));
        if (snap.docs.isNotEmpty) {
          return snap.docs
              .map((d) => WordCategory.fromJson(d.data(), id: d.id))
              .toList();
        }
      } catch (_) {}
    }
    return _loadAssets();
  }

  Future<List<WordCategory>> _loadAssets() async {
    final categories = <WordCategory>[];
    for (final path in _assetFiles) {
      final raw = await rootBundle.loadString(path);
      categories.add(
        WordCategory.fromJson(jsonDecode(raw) as Map<String, dynamic>),
      );
    }
    categories.sort((a, b) => a.order.compareTo(b.order));
    return categories;
  }
}
