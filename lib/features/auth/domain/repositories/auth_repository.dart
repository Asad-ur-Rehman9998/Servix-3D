import '../../../auth/domain/entities/user_entity.dart';

abstract class AuthRepository {
  Future<AuthSession> login({required String email, required String password});
  Future<AuthSession> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  });
  Future<void> requestPasswordReset(String email);
  Future<bool> verifyOtp({required String email, required String otp});
  Future<void> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  });
  Future<AuthSession?> restoreSession();
  Future<void> logout();
  Future<UserEntity> updateProfile(UserEntity user);
}
