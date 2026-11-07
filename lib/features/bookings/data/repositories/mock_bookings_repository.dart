import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/storage/local_storage_service.dart';
import '../../../../shared/data/mock_data.dart';
import '../../domain/entities/booking_entity.dart';
import '../../domain/repositories/bookings_repository.dart';

class MockBookingsRepository implements BookingsRepository {
  MockBookingsRepository(this._localStorage) {
    _load();
  }

  final LocalStorageService _localStorage;
  late List<BookingEntity> _items;
  final _uuid = const Uuid();

  void _load() {
    final raw = _localStorage.bookingsJson;
    if (raw != null && raw.isNotEmpty) {
      try {
        _items = BookingEntity.decodeList(raw);
        return;
      } catch (_) {
        // fall through to seed data
      }
    }
    _items = List.of(MockData.bookings);
    _persist();
  }

  Future<void> _persist() async {
    await _localStorage.saveBookingsJson(BookingEntity.encodeList(_items));
  }

  @override
  Future<List<BookingEntity>> getBookings() async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    return List.unmodifiable(_items);
  }

  @override
  Future<BookingEntity?> getById(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    try {
      return _items.firstWhere((b) => b.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<BookingEntity> create(BookingEntity booking) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    final created = BookingEntity(
      id: 'b_${_uuid.v4().substring(0, 8)}',
      serviceId: booking.serviceId,
      serviceTitle: booking.serviceTitle,
      providerId: booking.providerId,
      providerName: booking.providerName,
      date: booking.date,
      timeSlot: booking.timeSlot,
      address: booking.address,
      price: booking.price,
      status: BookingStatus.confirmed,
      paymentMethod: booking.paymentMethod,
      notes: booking.notes,
    );
    _items.insert(0, created);
    await _persist();
    return created;
  }

  @override
  Future<BookingEntity> updateStatus(String id, BookingStatus status) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    final index = _items.indexWhere((b) => b.id == id);
    if (index < 0) throw StateError('Booking not found');
    final updated = _items[index].copyWith(status: status);
    _items[index] = updated;
    await _persist();
    return updated;
  }

  @override
  Future<BookingEntity> reschedule({
    required String id,
    required DateTime date,
    required String timeSlot,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    final index = _items.indexWhere((b) => b.id == id);
    if (index < 0) throw StateError('Booking not found');
    final updated = _items[index].copyWith(
      date: date,
      timeSlot: timeSlot,
      status: BookingStatus.confirmed,
    );
    _items[index] = updated;
    await _persist();
    return updated;
  }

  @override
  Future<void> cancel(String id) async {
    await updateStatus(id, BookingStatus.cancelled);
  }
}

final bookingsRepositoryProvider = Provider<BookingsRepository>((ref) {
  return MockBookingsRepository(ref.watch(localStorageProvider));
});
