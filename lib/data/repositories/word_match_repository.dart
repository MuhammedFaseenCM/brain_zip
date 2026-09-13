import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';

import '../../core/firebase/firebase_bootstrap.dart';
import '../../domain/entities/word_match_deck.dart';

class WordMatchRepository {
  WordMatchRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ??
            (FirebaseBootstrap.isReady ? FirebaseFirestore.instance : null);

  final FirebaseFirestore? _firestore;

  static const _assetFiles = [
    'assets/word_match/decks/opposites.json',
    'assets/word_match/decks/animals.json',
    'assets/word_match/decks/geography.json',
  ];

  Future<List<WordMatchDeck>> fetchDecks() async {
    if (_firestore != null) {
      try {
        final snap = await _firestore
            .collection('word_match_decks')
            .orderBy('order')
            .get(const GetOptions(source: Source.serverAndCache));
        if (snap.docs.isNotEmpty) {
          return snap.docs
              .map((d) => WordMatchDeck.fromJson(d.data(), id: d.id))
              .toList();
        }
      } catch (_) {}
    }
    return _loadAssets();
  }

  Future<List<WordMatchDeck>> _loadAssets() async {
    final decks = <WordMatchDeck>[];
    for (final path in _assetFiles) {
      final raw = await rootBundle.loadString(path);
      decks.add(
        WordMatchDeck.fromJson(jsonDecode(raw) as Map<String, dynamic>),
      );
    }
    decks.sort((a, b) => a.order.compareTo(b.order));
    return decks;
  }
}
