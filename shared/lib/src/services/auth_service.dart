import 'package:shared/src/models/user.dart';

abstract interface class AuthService {
  User? get currentUser;

  Stream<User?> watchCurrentUser();

  Future<void> signInAsUser(String userId);

  Future<void> signOut();
}

