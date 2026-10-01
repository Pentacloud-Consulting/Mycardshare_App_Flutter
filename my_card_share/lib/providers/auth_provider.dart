import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../backend/app view/app_view_auth_gate.dart';

class AuthState {
  final bool isLoggedIn;
  final String role; // individual, enterprise, employee, master-admin
  final UserModel? user;

  const AuthState({
    this.isLoggedIn = false,
    this.role = 'individual',
    this.user,
  });

  AuthState copyWith({
    bool? isLoggedIn,
    String? role,
    UserModel? user,
  }) {
    return AuthState(
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      role: role ?? this.role,
      user: user ?? this.user,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService authService;

  AuthNotifier(this.authService) : super(const AuthState()) {
    _initSession();
    _listenToAuthChanges();
  }

  Future<void> _initSession() async {
    final userModel = await AppViewAuthGate.instance.restoreSessionOnAppLaunch();
    if (userModel != null) {
      state = AuthState(
        isLoggedIn: true,
        role: userModel.role,
        user: userModel,
      );
    }
  }

  void _listenToAuthChanges() {
    AppViewAuthGate.instance.authStateChanges.listen((firebaseUser) {
      if (firebaseUser != null) {
        if (!state.isLoggedIn || state.user?.id != firebaseUser.uid) {
          AppViewAuthGate.instance.restoreSessionOnAppLaunch().then((userModel) {
            if (userModel != null) {
              state = AuthState(
                isLoggedIn: true,
                role: userModel.role,
                user: userModel,
              );
            }
          });
        }
      } else {
        if (state.isLoggedIn) {
          state = const AuthState(isLoggedIn: false);
        }
      }
    });
  }

  void login(UserModel user) {
    state = AuthState(
      isLoggedIn: true,
      role: user.role,
      user: user,
    );
    if (AppViewAuthGate.instance.currentUser != null) {
      AppViewAuthGate.instance.onUserAuthenticated(
        AppViewAuthGate.instance.currentUser!,
        role: user.role,
      );
    }
  }

  void logout() {
    AppViewAuthGate.instance.signOut();
    authService.logout();
    state = const AuthState();
  }

  void setRole(String role) {
    state = state.copyWith(role: role);
  }
}

final authServiceProvider = Provider<AuthService>((ref) => AuthService());

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authService = ref.watch(authServiceProvider);
  return AuthNotifier(authService);
});

final currentUserProvider = StateProvider<UserModel?>((ref) => null);
