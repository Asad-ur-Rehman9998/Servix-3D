import 'dart:convert';

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
    final normalized = email.trim().toLowerCase();
    final stored = _localStorage.getPassword(normalized);

    final isDemo = normalized == AppConstants.demoUserEmail.toLowerCase() &&
        password == AppConstants.demoPassword;
    final isStoredMatch = stored != null && stored == password;
    final isFirstTimeValid = stored == null &&
        password.length >= 6 &&
        RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(normalized);

    if (!isDemo && !isStoredMatch && !isFirstTimeValid) {
      throw UnauthorizedException('Invalid email or password');
    }

    if (stored == null) {
      await _localStorage.savePassword(normalized, password);
    }

    final cached = _readCachedUser();
    if (cached != null && cached.email.toLowerCase() == normalized) {
      _currentUser = cached;
    } else if (isDemo) {
      _currentUser = MockData.demoUser;
    } else {
      _currentUser = UserEntity(
        id: _uuid.v4(),
        name: normalized.split('@').first,
        email: email.trim(),
        phone: '+1 000 000 0000',
        avatarUrl: 'assets/images/avatars/user.jpg',
        address: 'Add your address in profile',
      );
    }
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
    final normalized = email.trim().toLowerCase();
    await _localStorage.savePassword(normalized, password);
    _currentUser = UserEntity(
      id: _uuid.v4(),
      name: name.trim(),
      email: email.trim(),
      phone: phone.trim(),
      avatarUrl: 'assets/images/avatars/user.jpg',
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
    await _localStorage.savePassword(email, newPassword);
    await Future<void>.delayed(const Duration(milliseconds: 400));
  }

  @override
  Future<AuthSession?> restoreSession() async {
    final token = await _secureStorage.readAccessToken();
    if (token == null || token.isEmpty) return null;
    _currentUser = _readCachedUser() ?? MockData.demoUser;
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
    await _localStorage.saveUserJson(_encodeUser(user));
    return user;
  }

  Future<AuthSession> _persistSession(UserEntity user) async {
    final access = 'mock_access_${_uuid.v4()}';
    final refresh = 'mock_refresh_${_uuid.v4()}';
    await _secureStorage.saveTokens(
      accessToken: access,
      refreshToken: refresh,
    );
    await _localStorage.saveUserJson(_encodeUser(user));
    return AuthSession(user: user, accessToken: access, refreshToken: refresh);
  }

  UserEntity? _readCachedUser() {
    final raw = _localStorage.userJson;
    if (raw == null || raw.isEmpty) return null;
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return UserEntity(
        id: map['id'] as String,
        name: map['name'] as String,
        email: map['email'] as String,
        phone: map['phone'] as String,
        avatarUrl: map['avatarUrl'] as String?,
        address: map['address'] as String?,
      );
    } catch (_) {
      return null;
    }
  }

  String _encodeUser(UserEntity user) => jsonEncode({
        'id': user.id,
        'name': user.name,
        'email': user.email,
        'phone': user.phone,
        'avatarUrl': user.avatarUrl,
        'address': user.address,
      });
}
