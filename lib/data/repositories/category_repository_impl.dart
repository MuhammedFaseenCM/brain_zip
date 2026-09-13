import 'dart:convert';

import 'package:brain_zip/core/firebase/firebase_bootstrap.dart';
import 'package:brain_zip/domain/entities/word_category.dart';
import 'package:brain_zip/domain/repositories/category_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  CategoryRepositoryImpl({
    FirebaseFirestore? firestore,
    AssetBundle? assetBundle,
  })  : _firestore = firestore ??
            (FirebaseBootstrap.isReady ? FirebaseFirestore.instance : null),
        _assetBundle = assetBundle ?? rootBundle;

  final FirebaseFirestore? _firestore;
  final AssetBundle _assetBundle;

  static const _assetFiles = [
    'assets/words/categories/animals.json',
    'assets/words/categories/food.json',
    'assets/words/categories/sports.json',
  ];

  @override
  Future<List<WordCategory>> fetchCategories() async {
    final firestore = _firestore;
    if (firestore != null) {
      try {
        final snap = await firestore
            .collection('categories')
            .orderBy('order')
            .get(const GetOptions(source: Source.serverAndCache));
        if (snap.docs.isNotEmpty) {
          return snap.docs
              .map((d) => WordCategory.fromJson(d.data(), id: d.id))
              .toList();
        }
      } catch (_) {
        // fall through to assets
      }
    }
    return _loadAssets();
  }

  Future<List<WordCategory>> _loadAssets() async {
    final categories = <WordCategory>[];
    for (final path in _assetFiles) {
      final raw = await _assetBundle.loadString(path);
      categories
          .add(WordCategory.fromJson(jsonDecode(raw) as Map<String, dynamic>));
    }
    categories.sort((a, b) => a.order.compareTo(b.order));
    return categories;
  }
}

