import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/async_value_x.dart';
import '../../data/repositories/mock_bookings_repository.dart';
import '../../domain/entities/booking_entity.dart';

final bookingsListProvider =
    AsyncNotifierProvider<BookingsListController, List<BookingEntity>>(
  BookingsListController.new,
);

class BookingsListController extends AsyncNotifier<List<BookingEntity>> {
  @override
  Future<List<BookingEntity>> build() {
    return ref.read(bookingsRepositoryProvider).getBookings();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(bookingsRepositoryProvider).getBookings(),
    );
  }

  Future<BookingEntity> create(BookingEntity booking) async {
    final created = await ref.read(bookingsRepositoryProvider).create(booking);
    final current = state.valueOrNull ?? [];
    state = AsyncData([created, ...current]);
    return created;
  }

  Future<void> cancel(String id) async {
    await ref.read(bookingsRepositoryProvider).cancel(id);
    await refresh();
  }

  Future<BookingEntity> advanceStatus(String id) async {
    final current = await ref.read(bookingsRepositoryProvider).getById(id);
    if (current == null) throw StateError('Booking not found');
    final next = current.status.next;
    if (next == null) return current;
    final updated =
        await ref.read(bookingsRepositoryProvider).updateStatus(id, next);
    await refresh();
    return updated;
  }

  Future<BookingEntity> reschedule({
    required String id,
    required DateTime date,
    required String timeSlot,
  }) async {
    final updated = await ref.read(bookingsRepositoryProvider).reschedule(
          id: id,
          date: date,
          timeSlot: timeSlot,
        );
    await refresh();
    return updated;
  }
}

final bookingByIdProvider =
    FutureProvider.family<BookingEntity?, String>((ref, id) {
  return ref.watch(bookingsRepositoryProvider).getById(id);
});

/// Mutable draft used across the multi-step booking flow.
class BookingDraft extends Equatable {
  const BookingDraft({
    this.serviceId,
    this.serviceTitle,
    this.providerId,
    this.providerName,
    this.date,
    this.timeSlot,
    this.address,
    this.price,
    this.paymentMethod = PaymentMethodType.card,
    this.notes,
    this.step = 0,
  });

  final String? serviceId;
  final String? serviceTitle;
  final String? providerId;
  final String? providerName;
  final DateTime? date;
  final String? timeSlot;
  final String? address;
  final double? price;
  final PaymentMethodType paymentMethod;
  final String? notes;
  final int step;

  static const int totalSteps = 5;

  bool get canContinue {
    switch (step) {
      case 0:
        return providerId != null && providerId!.isNotEmpty;
      case 1:
        return date != null;
      case 2:
        return timeSlot != null && timeSlot!.isNotEmpty;
      case 3:
        return address != null && address!.trim().isNotEmpty;
      case 4:
        return serviceId != null &&
            providerId != null &&
            date != null &&
            timeSlot != null &&
            address != null &&
            price != null;
      default:
        return false;
    }
  }

  BookingEntity toBooking() {
    return BookingEntity(
      id: 'draft',
      serviceId: serviceId!,
      serviceTitle: serviceTitle ?? 'Service',
      providerId: providerId!,
      providerName: providerName ?? 'Provider',
      date: date!,
      timeSlot: timeSlot!,
      address: address!,
      price: price ?? 0,
      status: BookingStatus.confirmed,
      paymentMethod: paymentMethod,
      notes: notes,
    );
  }

  BookingDraft copyWith({
    String? serviceId,
    String? serviceTitle,
    String? providerId,
    String? providerName,
    DateTime? date,
    String? timeSlot,
    String? address,
    double? price,
    PaymentMethodType? paymentMethod,
    String? notes,
    int? step,
    bool clearDate = false,
    bool clearTime = false,
  }) {
    return BookingDraft(
      serviceId: serviceId ?? this.serviceId,
      serviceTitle: serviceTitle ?? this.serviceTitle,
      providerId: providerId ?? this.providerId,
      providerName: providerName ?? this.providerName,
      date: clearDate ? null : (date ?? this.date),
      timeSlot: clearTime ? null : (timeSlot ?? this.timeSlot),
      address: address ?? this.address,
      price: price ?? this.price,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      notes: notes ?? this.notes,
      step: step ?? this.step,
    );
  }

  @override
  List<Object?> get props => [
        serviceId,
        serviceTitle,
        providerId,
        providerName,
        date,
        timeSlot,
        address,
        price,
        paymentMethod,
        notes,
        step,
      ];
}

final bookingDraftProvider =
    NotifierProvider<BookingDraftController, BookingDraft>(
  BookingDraftController.new,
);

class BookingDraftController extends Notifier<BookingDraft> {
  @override
  BookingDraft build() => const BookingDraft();

  void startForService({
    required String serviceId,
    required String serviceTitle,
    required String providerId,
    required String providerName,
    required double price,
    String? address,
  }) {
    state = BookingDraft(
      serviceId: serviceId,
      serviceTitle: serviceTitle,
      providerId: providerId,
      providerName: providerName,
      price: price,
      address: address,
      step: 0,
    );
  }

  void selectProvider({
    required String providerId,
    required String providerName,
  }) {
    state = state.copyWith(providerId: providerId, providerName: providerName);
  }

  void selectDate(DateTime date) {
    state = state.copyWith(date: date, clearTime: true);
  }

  void selectTimeSlot(String timeSlot) {
    state = state.copyWith(timeSlot: timeSlot);
  }

  void setAddress(String address) {
    state = state.copyWith(address: address);
  }

  void setNotes(String? notes) {
    state = state.copyWith(notes: notes);
  }

  void setPaymentMethod(PaymentMethodType method) {
    state = state.copyWith(paymentMethod: method);
  }

  void nextStep() {
    if (!state.canContinue) return;
    if (state.step < BookingDraft.totalSteps - 1) {
      state = state.copyWith(step: state.step + 1);
    }
  }

  void previousStep() {
    if (state.step > 0) {
      state = state.copyWith(step: state.step - 1);
    }
  }

  void goToStep(int step) {
    if (step >= 0 && step < BookingDraft.totalSteps) {
      state = state.copyWith(step: step);
    }
  }

  void reset() {
    state = const BookingDraft();
  }
}
