import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:servix_3d/core/storage/local_storage_service.dart';
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

    test('confirm password mismatch', () {
      expect(AuthValidators.confirmPassword('a', 'b'), isNotNull);
      expect(AuthValidators.confirmPassword('same', 'same'), isNull);
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

    test('next status progression', () {
      expect(BookingStatus.confirmed.next, BookingStatus.assigned);
      expect(BookingStatus.started.next, BookingStatus.completed);
      expect(BookingStatus.completed.next, isNull);
    });
  });

  group('BookingEntity persistence', () {
    test('encode and decode roundtrip', () {
      final original = MockData.bookings.first;
      final encoded = BookingEntity.encodeList([original]);
      final decoded = BookingEntity.decodeList(encoded);
      expect(decoded, hasLength(1));
      expect(decoded.first.id, original.id);
      expect(decoded.first.status, original.status);
      expect(decoded.first.price, original.price);
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

  group('LocalStorageService', () {
    test('persists theme and notifications', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final storage = LocalStorageService(prefs);

      await storage.setThemeMode('dark');
      expect(storage.themeMode, 'dark');

      await storage.setNotificationsEnabled(false);
      expect(storage.notificationsEnabled, isFalse);

      await storage.setOnboardingDone(true);
      expect(storage.isOnboardingDone, isTrue);

      await storage.savePassword('user@test.com', 'secret123');
      expect(storage.getPassword('user@test.com'), 'secret123');
    });
  });
}
