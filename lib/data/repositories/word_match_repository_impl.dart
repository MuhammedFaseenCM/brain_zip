import 'dart:convert';

import 'package:winklo/core/firebase/firebase_bootstrap.dart';
import 'package:winklo/domain/entities/word_match_deck.dart';
import 'package:winklo/domain/repositories/word_match_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';

class WordMatchRepositoryImpl implements WordMatchRepository {
  WordMatchRepositoryImpl({
    FirebaseFirestore? firestore,
    AssetBundle? assetBundle,
  }) : _firestore =
           firestore ??
           (FirebaseBootstrap.isReady ? FirebaseFirestore.instance : null),
       _assetBundle = assetBundle ?? rootBundle;

  final FirebaseFirestore? _firestore;
  final AssetBundle _assetBundle;

  static const _assetFiles = [
    'assets/word_match/decks/opposites.json',
    'assets/word_match/decks/animals.json',
    'assets/word_match/decks/geography.json',
  ];

  @override
  Future<List<WordMatchDeck>> fetchDecks() async {
    final firestore = _firestore;
    if (firestore != null) {
      try {
        final snap = await firestore
            .collection('word_match_decks')
            .orderBy('order')
            .get(const GetOptions(source: Source.serverAndCache));
        if (snap.docs.isNotEmpty) {
          return snap.docs
              .map((d) => WordMatchDeck.fromJson(d.data(), id: d.id))
              .toList();
        }
      } catch (_) {
        // fall through to assets
      }
    }
    return _loadAssets();
  }

  @override
  Future<WordMatchDeck?> fetchDeckById(String id) async {
    final firestore = _firestore;
    if (firestore != null) {
      try {
        final doc = await firestore
            .collection('word_match_decks')
            .doc(id)
            .get();
        final data = doc.data();
        if (doc.exists && data != null) {
          return WordMatchDeck.fromJson(data, id: doc.id);
        }
      } catch (_) {
        // fall through to assets
      }
    }

    for (final path in _assetFiles) {
      final raw = await _assetBundle.loadString(path);
      final json = jsonDecode(raw) as Map<String, dynamic>;
      final deck = WordMatchDeck.fromJson(json);
      if (deck.id == id) return deck;
    }
    return null;
  }

  Future<List<WordMatchDeck>> _loadAssets() async {
    final decks = <WordMatchDeck>[];
    for (final path in _assetFiles) {
      final raw = await _assetBundle.loadString(path);
      decks.add(
        WordMatchDeck.fromJson(jsonDecode(raw) as Map<String, dynamic>),
      );
    }
    decks.sort((a, b) => a.order.compareTo(b.order));
    return decks;
  }
}
