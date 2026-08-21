import 'package:flutter_test/flutter_test.dart';

import 'package:servix_3d/features/auth/domain/validators/auth_validators.dart';
import 'package:servix_3d/features/bookings/domain/entities/booking_entity.dart';
import 'package:servix_3d/features/services/domain/entities/service_entity.dart';
import 'package:servix_3d/shared/data/mock_data.dart';

void main() {
  group('AuthValidators', () {
    test('validates email', () {
      expect(AuthValidators.email(null), isNotNull);
      expect(AuthValidators.email('bad'), isNotNull);
      expect(AuthValidators.email('asad@servix3d.com'), isNull);
    });

    test('validates password', () {
      expect(AuthValidators.password('123'), isNotNull);
      expect(AuthValidators.password('Servix@123'), isNull);
    });
  });

  group('MockData', () {
    test('has services and categories', () {
      expect(MockData.services, isNotEmpty);
      expect(MockData.categories.length, 10);
      expect(MockData.providers, isNotEmpty);
    });

    test('can filter popular services', () {
      final popular = MockData.services.where((s) => s.isPopular).toList();
      expect(popular, isNotEmpty);
    });
  });

  group('BookingStatus', () {
    test('step indexes are ordered', () {
      expect(BookingStatus.confirmed.stepIndex, 0);
      expect(BookingStatus.completed.stepIndex, 4);
      expect(BookingStatus.cancelled.stepIndex, -1);
    });
  });

  group('Service search', () {
    test('matches category labels', () {
      final results = MockData.services
          .where((s) =>
              s.title.toLowerCase().contains('clean') ||
              s.category == ServiceCategoryType.cleaning)
          .toList();
      expect(results, isNotEmpty);
    });
  });
}
