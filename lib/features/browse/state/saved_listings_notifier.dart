import 'package:flutter/foundation.dart';

import '../data/browse_repository.dart';

/// In-memory state and ChangeNotifier for user's saved/bookmarked listings.
/// Synchronizes across Browse views and persists for signed-in users.
class SavedListingsNotifier extends ChangeNotifier {
  static final SavedListingsNotifier _instance =
      SavedListingsNotifier._internal();
  factory SavedListingsNotifier() => _instance;

  SavedListingsNotifier._internal() {
    _restore();
  }

  final BrowseRepository _repository = BrowseRepository();
  final Set<String> _savedIds = <String>{};
  int _revision = 0;
  String? _loadedAccountId;

  Set<String> get savedIds {
    _restore();
    return Set.unmodifiable(_savedIds);
  }

  bool get hasAccountSync => _repository.hasRealUser;

  bool isSaved(String id) {
    _restore();
    return _savedIds.contains(id);
  }

  Future<void> _restore() async {
    final accountId = _repository.currentAccountId;
    if (_loadedAccountId == accountId) return;
    _loadedAccountId = accountId;
    _revision++;
    final revision = _revision;
    if (accountId == null) {
      _savedIds.clear();
      notifyListeners();
      return;
    }
    try {
      final ids = await _repository.fetchSavedListingIds();
      if (revision != _revision) return;
      _savedIds
        ..clear()
        ..addAll(ids);
      notifyListeners();
    } catch (error) {
      debugPrint('Could not restore saved listings: $error');
    }
  }

  Future<bool> toggle(String id) async {
    final wasSaved = _savedIds.contains(id);
    if (_savedIds.contains(id)) {
      _savedIds.remove(id);
    } else {
      _savedIds.add(id);
    }
    _revision++;
    notifyListeners();
    return _persistOrRollback(id, wasSaved);
  }

  Future<bool> save(String id) async {
    if (_savedIds.add(id)) {
      _revision++;
      notifyListeners();
      return _persistOrRollback(id, false);
    }
    return true;
  }

  Future<bool> remove(String id) async {
    if (_savedIds.remove(id)) {
      _revision++;
      notifyListeners();
      return _persistOrRollback(id, true);
    }
    return true;
  }

  Future<void> clear() async {
    _savedIds.clear();
    _revision++;
    notifyListeners();
    try {
      await _repository.saveListingIds(_savedIds);
    } catch (error) {
      debugPrint('Could not clear saved listings: $error');
    }
  }

  Future<bool> _persistOrRollback(String id, bool wasSaved) async {
    try {
      await _repository.saveListingIds(_savedIds);
      return true;
    } catch (error) {
      debugPrint('Could not save listing state: $error');
      if (wasSaved) {
        _savedIds.add(id);
      } else {
        _savedIds.remove(id);
      }
      _revision++;
      notifyListeners();
      return false;
    }
  }
}
