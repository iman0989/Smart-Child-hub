import 'package:flutter/foundation.dart';

import '../core/network/api_exception.dart';
import '../core/repositories/child_repository.dart';
import '../models/child_model.dart';

/// Child profiles + coin balances, backed by the REST API.
class ChildProvider extends ChangeNotifier {
  ChildProvider({ChildRepository? repository}) : _repository = repository ?? ChildRepository();

  final ChildRepository _repository;
  final List<ChildModel> _children = [];

  String? _selectedChildId;
  bool _isLoading = false;
  bool _hasLoaded = false;
  String? _error;

  bool get isLoading => _isLoading;
  bool get hasLoaded => _hasLoaded;
  String? get error => _error;

  List<ChildModel> get children => List.unmodifiable(_children);
  String? get selectedChildId => _selectedChildId;

  /// The child the parent explicitly picked (or the signed-in child).
  /// Null until [selectChild] is called — there is deliberately no "first child"
  /// fallback, so the child zone can never silently pick a profile.
  ChildModel? get selectedChild {
    for (final ChildModel child in _children) {
      if (child.id == _selectedChildId) return child;
    }
    return null;
  }

  bool get hasSelection => selectedChild != null;

  /// Parent-zone convenience: focuses the first child so the dashboard has
  /// someone to show. This is only ever called from the parent zone — the
  /// child zone requires [selectChild] to be called from the picker.
  void ensureSelection() {
    if (hasSelection || _children.isEmpty) return;
    _selectedChildId = _children.first.id;
    notifyListeners();
  }

  ChildModel? childById(String id) {
    for (final ChildModel child in _children) {
      if (child.id == id) return child;
    }
    return null;
  }

  /// Drops the current selection while keeping the loaded children, e.g. when
  /// leaving the child zone.
  void clearSelection() {
    if (_selectedChildId == null) return;
    _selectedChildId = null;
    notifyListeners();
  }

  /// Clears all cached children + selection. Used when switching accounts so
  /// the next account never sees the previous family's data.
  void reset() {
    _children.clear();
    _selectedChildId = null;
    _hasLoaded = false;
    _error = null;
    notifyListeners();
  }

  /// Fetches the children list from the server (keeps the current selection).
  Future<void> load() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final List<ChildModel> fetched = await _repository.children();
      _children
        ..clear()
        ..addAll(fetched);
      if (_selectedChildId != null && !_children.any((c) => c.id == _selectedChildId)) {
        _selectedChildId = null;
      }
      _hasLoaded = true;
    } on ApiException catch (e) {
      _error = e.userMessage;
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> refresh() => load();

  void selectChild(String id) {
    if (_selectedChildId == id) return;
    _selectedChildId = id;
    notifyListeners();
  }

  /// Adds a child profile returned by the child login without hitting the
  /// parent-only children endpoint, so the child zone always has its identity.
  void seedChild(ChildModel child) {
    _replace(child);
    if (_selectedChildId == null || _selectedChildId == child.id) {
      _selectedChildId = child.id;
    }
    _hasLoaded = true;
    notifyListeners();
  }

  /// Builds the `securityQuestions` payload for create/update.
  ///
  /// Questions with a blank answer keep the value already stored on the server,
  /// so a parent can leave a configured question untouched while editing a
  /// profile.
  static List<Map<String, String>> _securityQuestionPayload(ChildModel child) {
    return child.securityQuestionKeys
        .map(
          (String key) => <String, String>{
            'questionKey': key,
            'answer': (child.securityQuestionAnswers[key] ?? '').trim(),
          },
        )
        .toList(growable: false);
  }

  /// Creates the child on the server, then adds it locally and selects it.
  Future<ChildModel?> addChild(ChildModel child) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final ChildModel created = await _repository.create({
        'name': child.name,
        'age': child.age,
        'grade': child.grade,
        'aboutChild': child.aboutChild,
        'avatarKey': child.avatarKey,
        'pin': child.pin,
        'securityQuestions': _securityQuestionPayload(child),
      });
      _children.add(created);
      _isLoading = false;
      notifyListeners();
      return created;
    } on ApiException catch (e) {
      _error = e.userMessage;
      _isLoading = false;
      notifyListeners();
      return null;
    } catch (e) {
      _error = 'Something went wrong. Please try again.';
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  Future<bool> updateChild(ChildModel child) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      // `photoUrl` is deliberately not part of this payload: the server only
      // accepts a photo through the upload/remove endpoints, and echoing the
      // current value back would let a stale value overwrite a newer upload.
      final Map<String, dynamic> payload = {
        'name': child.name,
        'age': child.age,
        'grade': child.grade,
        'aboutChild': child.aboutChild,
        'avatarKey': child.avatarKey,
        'coins': child.coins,
        'streakDays': child.streakDays,
        'securityQuestions': _securityQuestionPayload(child),
      };
      // Only send the PIN when the parent set a new one for this edit;
      // leaving it blank keeps the existing PIN on the server.
      if (child.pin.isNotEmpty) {
        payload['pin'] = child.pin;
      }
      final ChildModel updated = await _repository.update(child.id, payload);
      _replace(updated);
      _isLoading = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.userMessage;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Something went wrong. Please try again.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteChild(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _repository.delete(id);
      _children.removeWhere((c) => c.id == id);
      if (_selectedChildId == id) {
        _selectedChildId = null;
      }
      _isLoading = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.userMessage;
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Uploads a profile photo for a child and replaces the local copy.
  Future<ChildModel?> uploadPhoto({
    required String childId,
    required Uint8List bytes,
    required String filename,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final ChildModel updated = await _repository.uploadPhoto(
        childId: childId,
        bytes: bytes,
        filename: filename,
      );
      _replace(updated);
      _isLoading = false;
      notifyListeners();
      return updated;
    } on ApiException catch (e) {
      _error = e.userMessage;
      _isLoading = false;
      notifyListeners();
      return null;
    } catch (e) {
      _error = 'Something went wrong. Please try again.';
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  /// Clears a child's profile photo and falls the avatar back to its monogram.
  Future<ChildModel?> removePhoto(String childId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final ChildModel updated = await _repository.removePhoto(childId);
      _replace(updated);
      _isLoading = false;
      notifyListeners();
      return updated;
    } on ApiException catch (e) {
      _error = e.userMessage;
      _isLoading = false;
      notifyListeners();
      return null;
    } catch (e) {
      _error = 'Something went wrong. Please try again.';
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  /// Applies a coin delta to a child locally and syncs it to the server.
  Future<void> adjustCoins(String childId, int delta) async {
    final int index = _children.indexWhere((c) => c.id == childId);
    if (index == -1) return;
    final ChildModel current = _children[index];
    final int next = (current.coins + delta).clamp(0, 99999);
    _children[index] = current.copyWith(coins: next);
    notifyListeners();
    try {
      await _repository.update(childId, {'coins': next});
    } on ApiException catch (e) {
      _error = e.userMessage;
      notifyListeners();
    }
  }

  Future<void> addCoinsToSelected(int delta) async {
    final String? id = _selectedChildId;
    if (id == null) return;
    await adjustCoins(id, delta);
  }

  /// Applies a coin delta locally without a network call. The server already
  /// awards the coins when a task is completed, so child mode only needs the
  /// display to stay in sync.
  void bumpCoinsLocal(String childId, int delta) {
    final int index = _children.indexWhere((c) => c.id == childId);
    if (index == -1) return;
    final ChildModel current = _children[index];
    final int next = (current.coins + delta).clamp(0, 99999);
    _children[index] = current.copyWith(coins: next);
    notifyListeners();
  }

  void _replace(ChildModel child) {
    final int index = _children.indexWhere((c) => c.id == child.id);
    if (index == -1) {
      _children.add(child);
    } else {
      _children[index] = child;
    }
  }

  Future<bool> changePin({
    required String childId,
    required String currentPin,
    required String newPin,
    required String newPinConfirmation,
  }) async {
    _error = null;
    notifyListeners();
    try {
      final ChildModel updated = await _repository.changePin(
        childId: childId,
        currentPin: currentPin,
        newPin: newPin,
        newPinConfirmation: newPinConfirmation,
      );
      _replace(updated);
      _isLoading = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.userMessage;
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
