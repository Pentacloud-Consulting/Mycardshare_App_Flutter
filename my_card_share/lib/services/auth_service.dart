import '../models/user_model.dart';

class AuthService {
  Future<UserModel?> login(String email, String password) async {
    // Placeholder login API call
    return UserModel(
      id: '1',
      name: 'User',
      email: email,
      role: 'individual',
    );
  }

  Future<void> logout() async {
    // Placeholder logout
  }
}
