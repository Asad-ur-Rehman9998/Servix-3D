import 'package:uuid/uuid.dart';

import '../../../../shared/data/mock_data.dart';
import '../../domain/entities/booking_entity.dart';
import '../../domain/repositories/bookings_repository.dart';

class MockBookingsRepository implements BookingsRepository {
  MockBookingsRepository() : _items = List.of(MockData.bookings);

  final List<BookingEntity> _items;
  final _uuid = const Uuid();

  @override
  Future<List<BookingEntity>> getBookings() async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return List.unmodifiable(_items);
  }

  @override
  Future<BookingEntity?> getById(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    try {
      return _items.firstWhere((b) => b.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<BookingEntity> create(BookingEntity booking) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
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
    return created;
  }

  @override
  Future<BookingEntity> updateStatus(String id, BookingStatus status) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    final index = _items.indexWhere((b) => b.id == id);
    if (index < 0) throw StateError('Booking not found');
    final updated = _items[index].copyWith(status: status);
    _items[index] = updated;
    return updated;
  }

  @override
  Future<void> cancel(String id) async {
    await updateStatus(id, BookingStatus.cancelled);
  }
}
