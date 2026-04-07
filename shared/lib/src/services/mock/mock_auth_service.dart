import 'dart:async';

import 'package:hive/hive.dart';
import 'package:shared/src/models/user.dart';
import 'package:shared/src/repositories/user_repo.dart';
import 'package:shared/src/seed/seed_data.dart';
import 'package:shared/src/services/auth_service.dart';

class MockAuthService implements AuthService {
  MockAuthService({
    required Box<String> appStateBox,
    required UserRepo userRepo,
  })  : _appStateBox = appStateBox,
        _userRepo = userRepo;

  static const String _kCurrentUserIdKey = 'currentUserId';

  final Box<String> _appStateBox;
  final UserRepo _userRepo;

  final StreamController<User?> _controller = StreamController<User?>.broadcast();

  User? _current;

  Future<void> ensureSeeded() async {
    // Seed users if missing.
    if (_userRepo.getAll().isEmpty) {
      for (final u in SeedData.initialUsers) {
        await _userRepo.upsert(u);
      }
    }

    final id = _appStateBox.get(_kCurrentUserIdKey);
    if (id != null) {
      _current = _userRepo.getAll().where((u) => u.id == id).firstOrNull;
    }
    _controller.add(_current);
  }

  @override
  User? get currentUser => _current;

  @override
  Stream<User?> watchCurrentUser() {
    return Stream.multi((multi) {
      multi.add(_current);
      final sub = _controller.stream.listen(multi.add);
      multi.onCancel = sub.cancel;
    });
  }

  @override
  Future<void> signInAsUser(String userId) async {
    final user = _userRepo.getAll().where((u) => u.id == userId).firstOrNull;
    if (user == null) {
      throw StateError('Unknown userId: $userId');
    }
    _current = user;
    await _appStateBox.put(_kCurrentUserIdKey, userId);
    _controller.add(_current);
  }

  @override
  Future<void> signOut() async {
    _current = null;
    await _appStateBox.delete(_kCurrentUserIdKey);
    _controller.add(null);
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}

