import '../entities/booking_entity.dart';

abstract class BookingsRepository {
  Future<List<BookingEntity>> getBookings();
  Future<BookingEntity?> getById(String id);
  Future<BookingEntity> create(BookingEntity booking);
  Future<BookingEntity> updateStatus(String id, BookingStatus status);
  Future<BookingEntity> reschedule({
    required String id,
    required DateTime date,
    required String timeSlot,
  });
  Future<void> cancel(String id);
}
