import 'package:equatable/equatable.dart';

class ProviderEntity extends Equatable {
  const ProviderEntity({
    required this.id,
    required this.name,
    required this.title,
    required this.rating,
    required this.jobsCompleted,
    required this.experienceYears,
    required this.skills,
    required this.bio,
    required this.avatarUrl,
    required this.location,
    required this.hourlyRate,
    required this.available,
    this.distanceKm = 2.5,
  });

  final String id;
  final String name;
  final String title;
  final double rating;
  final int jobsCompleted;
  final int experienceYears;
  final List<String> skills;
  final String bio;
  final String avatarUrl;
  final String location;
  final double hourlyRate;
  final bool available;
  final double distanceKm;

  @override
  List<Object?> get props => [
        id,
        name,
        title,
        rating,
        jobsCompleted,
        experienceYears,
        skills,
        bio,
        avatarUrl,
        location,
        hourlyRate,
        available,
        distanceKm,
      ];
}

class ReviewEntity extends Equatable {
  const ReviewEntity({
    required this.id,
    required this.authorName,
    required this.rating,
    required this.comment,
    required this.createdAt,
    this.avatarUrl,
    this.photos = const [],
  });

  final String id;
  final String authorName;
  final double rating;
  final String comment;
  final DateTime createdAt;
  final String? avatarUrl;
  final List<String> photos;

  @override
  List<Object?> get props =>
      [id, authorName, rating, comment, createdAt, avatarUrl, photos];
}
