import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

enum ServiceCategoryType {
  cleaning,
  repair,
  carWash,
  plumbing,
  electrical,
  ac,
  painting,
  moving,
  beauty,
  maintenance,
}

extension ServiceCategoryTypeX on ServiceCategoryType {
  String get label {
    switch (this) {
      case ServiceCategoryType.cleaning:
        return 'Cleaning';
      case ServiceCategoryType.repair:
        return 'Repair';
      case ServiceCategoryType.carWash:
        return 'Car Wash';
      case ServiceCategoryType.plumbing:
        return 'Plumbing';
      case ServiceCategoryType.electrical:
        return 'Electrical';
      case ServiceCategoryType.ac:
        return 'AC Services';
      case ServiceCategoryType.painting:
        return 'Painting';
      case ServiceCategoryType.moving:
        return 'Moving';
      case ServiceCategoryType.beauty:
        return 'Beauty';
      case ServiceCategoryType.maintenance:
        return 'Maintenance';
    }
  }

  IconData get icon {
    switch (this) {
      case ServiceCategoryType.cleaning:
        return Icons.cleaning_services_rounded;
      case ServiceCategoryType.repair:
        return Icons.build_rounded;
      case ServiceCategoryType.carWash:
        return Icons.local_car_wash_rounded;
      case ServiceCategoryType.plumbing:
        return Icons.plumbing_rounded;
      case ServiceCategoryType.electrical:
        return Icons.electrical_services_rounded;
      case ServiceCategoryType.ac:
        return Icons.ac_unit_rounded;
      case ServiceCategoryType.painting:
        return Icons.format_paint_rounded;
      case ServiceCategoryType.moving:
        return Icons.local_shipping_rounded;
      case ServiceCategoryType.beauty:
        return Icons.spa_rounded;
      case ServiceCategoryType.maintenance:
        return Icons.handyman_rounded;
    }
  }
}

class ServiceCategory extends Equatable {
  const ServiceCategory({
    required this.id,
    required this.type,
    required this.description,
    required this.serviceCount,
    required this.accent,
  });

  final String id;
  final ServiceCategoryType type;
  final String description;
  final int serviceCount;
  final Color accent;

  String get name => type.label;
  IconData get icon => type.icon;

  @override
  List<Object?> get props => [id, type, description, serviceCount, accent];
}

class ServiceEntity extends Equatable {
  const ServiceEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.priceFrom,
    required this.durationMinutes,
    required this.rating,
    required this.reviewCount,
    required this.imageUrl,
    required this.included,
    required this.excluded,
    required this.providerId,
    this.isPopular = false,
    this.isRecommended = false,
  });

  final String id;
  final String title;
  final String description;
  final ServiceCategoryType category;
  final double priceFrom;
  final int durationMinutes;
  final double rating;
  final int reviewCount;
  final String imageUrl;
  final List<String> included;
  final List<String> excluded;
  final String providerId;
  final bool isPopular;
  final bool isRecommended;

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        category,
        priceFrom,
        durationMinutes,
        rating,
        reviewCount,
        imageUrl,
        included,
        excluded,
        providerId,
        isPopular,
        isRecommended,
      ];
}
