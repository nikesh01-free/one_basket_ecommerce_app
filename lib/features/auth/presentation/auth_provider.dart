import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/models.dart';
import '../../../core/network/mock_repositories.dart';

final authRepositoryProvider = Provider<MockAuthRepository>((ref) {
  return MockAuthRepository();
});

class AuthNotifier extends StateNotifier<UserProfile?> {
  final MockAuthRepository _repository;

  AuthNotifier(this._repository) : super(null) {
    _checkInitialSession();
  }

  Future<void> _checkInitialSession() async {
    final user = await _repository.getCurrentUser();
    state = user;
  }

  Future<UserProfile?> login(String email, String password) async {
    try {
      final user = await _repository.login(email, password);
      state = user;
      return user;
    } catch (e) {
      state = null;
      rethrow;
    }
  }

  Future<UserProfile?> register(String fullName, String email, String password) async {
    try {
      final user = await _repository.register(fullName, email, password);
      state = user;
      return user;
    } catch (e) {
      state = null;
      rethrow;
    }
  }

  Future<void> changePassword(String newPassword) async {
    await _repository.changePassword(newPassword);
  }

  Future<void> logout() async {
    await _repository.logout();
    state = null;
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, UserProfile?>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return AuthNotifier(repository);
});
