import 'package:uuid/uuid.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/storage/local_storage_service.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../../../shared/data/mock_data.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';

class MockAuthRepository implements AuthRepository {
  MockAuthRepository({
    required SecureStorageService secureStorage,
    required LocalStorageService localStorage,
  })  : _secureStorage = secureStorage,
        _localStorage = localStorage;

  final SecureStorageService _secureStorage;
  final LocalStorageService _localStorage;
  UserEntity? _currentUser;
  final _otpStore = <String, String>{};
  final _uuid = const Uuid();

  @override
  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 700));
    if (email.trim().toLowerCase() != AppConstants.demoUserEmail &&
        password != AppConstants.demoPassword &&
        password.length < 6) {
      throw UnauthorizedException('Invalid email or password');
    }
    // Accept demo credentials OR any valid-looking email with password length >= 6
    if (password.length < 6) {
      throw UnauthorizedException('Invalid email or password');
    }
    _currentUser = MockData.demoUser.copyWith(email: email.trim());
    return _persistSession(_currentUser!);
  }

  @override
  Future<AuthSession> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 800));
    if (password.length < 6) {
      throw AppException('Password must be at least 6 characters');
    }
    _currentUser = UserEntity(
      id: _uuid.v4(),
      name: name.trim(),
      email: email.trim(),
      phone: phone.trim(),
      avatarUrl: 'https://i.pravatar.cc/200?u=$email',
      address: 'Add your address in profile',
    );
    return _persistSession(_currentUser!);
  }

  @override
  Future<void> requestPasswordReset(String email) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    _otpStore[email.trim().toLowerCase()] = '123456';
  }

  @override
  Future<bool> verifyOtp({required String email, required String otp}) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    final expected = _otpStore[email.trim().toLowerCase()] ?? '123456';
    return otp.trim() == expected;
  }

  @override
  Future<void> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    final ok = await verifyOtp(email: email, otp: otp);
    if (!ok) throw AppException('Invalid OTP');
    if (newPassword.length < 6) {
      throw AppException('Password must be at least 6 characters');
    }
    await Future<void>.delayed(const Duration(milliseconds: 400));
  }

  @override
  Future<AuthSession?> restoreSession() async {
    final token = await _secureStorage.readAccessToken();
    if (token == null || token.isEmpty) return null;
    _currentUser ??= MockData.demoUser;
    final refresh = await _secureStorage.readRefreshToken() ?? '';
    return AuthSession(
      user: _currentUser!,
      accessToken: token,
      refreshToken: refresh,
    );
  }

  @override
  Future<void> logout() async {
    _currentUser = null;
    await _secureStorage.clearTokens();
  }

  @override
  Future<UserEntity> updateProfile(UserEntity user) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    _currentUser = user;
    return user;
  }

  Future<AuthSession> _persistSession(UserEntity user) async {
    final access = 'mock_access_${_uuid.v4()}';
    final refresh = 'mock_refresh_${_uuid.v4()}';
    await _secureStorage.saveTokens(
      accessToken: access,
      refreshToken: refresh,
    );
    // touch local storage to keep dependency used
    await _localStorage.setOnboardingDone(_localStorage.isOnboardingDone);
    return AuthSession(user: user, accessToken: access, refreshToken: refresh);
  }
}
