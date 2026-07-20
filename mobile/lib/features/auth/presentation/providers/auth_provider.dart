import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jattau/features/auth/data/auth_repository.dart';

final authStateProvider = StateNotifierProvider<AuthNotifier, AsyncValue<bool>>((ref) {
  return AuthNotifier(ref.watch(authRepositoryProvider));
});

class AuthNotifier extends StateNotifier<AsyncValue<bool>> {
  final AuthRepository _repo;
  AuthNotifier(this._repo) : super(const AsyncValue.loading()) {
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    state = AsyncValue.data(await _repo.isLoggedIn());
  }

  Future<void> login(String email, String password, String pin) async {
    state = const AsyncValue.loading();
    try {
      await _repo.login(email, password, pin);
      state = const AsyncValue.data(true);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> register(String email, String password, String name, String pin) async {
    state = const AsyncValue.loading();
    try {
      await _repo.register(email: email, password: password, fullName: name, pin: pin);
      state = const AsyncValue.data(true);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> logout() async {
    await _repo.logout();
    state = const AsyncValue.data(false);
  }
}
