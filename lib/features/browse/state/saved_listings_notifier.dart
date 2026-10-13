import 'package:flutter/foundation.dart';

/// In-memory state and ChangeNotifier for user's saved/bookmarked listings.
/// Synchronizes across all Browse views and can persist to Firestore.
class SavedListingsNotifier extends ChangeNotifier {
  static final SavedListingsNotifier _instance = SavedListingsNotifier._internal();
  factory SavedListingsNotifier() => _instance;

  SavedListingsNotifier._internal() {
    // Seed default saved places for instant interactive demo
    _savedIds.addAll(['serv-1', 'place-1', 'shop-1']);
  }

  final Set<String> _savedIds = <String>{};

  Set<String> get savedIds => Set.unmodifiable(_savedIds);

  bool isSaved(String id) => _savedIds.contains(id);

  void toggle(String id) {
    if (_savedIds.contains(id)) {
      _savedIds.remove(id);
    } else {
      _savedIds.add(id);
    }
    notifyListeners();
  }

  void save(String id) {
    if (_savedIds.add(id)) {
      notifyListeners();
    }
  }

  void remove(String id) {
    if (_savedIds.remove(id)) {
      notifyListeners();
    }
  }

  void clear() {
    _savedIds.clear();
    notifyListeners();
  }
}
