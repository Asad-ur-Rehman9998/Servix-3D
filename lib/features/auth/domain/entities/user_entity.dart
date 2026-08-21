import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  const UserEntity({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.avatarUrl,
    this.address,
  });

  final String id;
  final String name;
  final String email;
  final String phone;
  final String? avatarUrl;
  final String? address;

  UserEntity copyWith({
    String? name,
    String? email,
    String? phone,
    String? avatarUrl,
    String? address,
  }) {
    return UserEntity(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      address: address ?? this.address,
    );
  }

  @override
  List<Object?> get props => [id, name, email, phone, avatarUrl, address];
}

class AuthSession extends Equatable {
  const AuthSession({
    required this.user,
    required this.accessToken,
    required this.refreshToken,
  });

  final UserEntity user;
  final String accessToken;
  final String refreshToken;

  @override
  List<Object?> get props => [user, accessToken, refreshToken];
}
