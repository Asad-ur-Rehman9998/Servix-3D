import 'package:equatable/equatable.dart';

enum BookingStatus {
  confirmed,
  assigned,
  onTheWay,
  started,
  completed,
  cancelled,
}

extension BookingStatusX on BookingStatus {
  String get label {
    switch (this) {
      case BookingStatus.confirmed:
        return 'Booking Confirmed';
      case BookingStatus.assigned:
        return 'Professional Assigned';
      case BookingStatus.onTheWay:
        return 'On The Way';
      case BookingStatus.started:
        return 'Service Started';
      case BookingStatus.completed:
        return 'Completed';
      case BookingStatus.cancelled:
        return 'Cancelled';
    }
  }

  int get stepIndex {
    switch (this) {
      case BookingStatus.confirmed:
        return 0;
      case BookingStatus.assigned:
        return 1;
      case BookingStatus.onTheWay:
        return 2;
      case BookingStatus.started:
        return 3;
      case BookingStatus.completed:
        return 4;
      case BookingStatus.cancelled:
        return -1;
    }
  }
}

enum PaymentMethodType { card, cash, wallet }

class BookingEntity extends Equatable {
  const BookingEntity({
    required this.id,
    required this.serviceId,
    required this.serviceTitle,
    required this.providerId,
    required this.providerName,
    required this.date,
    required this.timeSlot,
    required this.address,
    required this.price,
    required this.status,
    required this.paymentMethod,
    this.notes,
  });

  final String id;
  final String serviceId;
  final String serviceTitle;
  final String providerId;
  final String providerName;
  final DateTime date;
  final String timeSlot;
  final String address;
  final double price;
  final BookingStatus status;
  final PaymentMethodType paymentMethod;
  final String? notes;

  BookingEntity copyWith({BookingStatus? status}) {
    return BookingEntity(
      id: id,
      serviceId: serviceId,
      serviceTitle: serviceTitle,
      providerId: providerId,
      providerName: providerName,
      date: date,
      timeSlot: timeSlot,
      address: address,
      price: price,
      status: status ?? this.status,
      paymentMethod: paymentMethod,
      notes: notes,
    );
  }

  @override
  List<Object?> get props => [
        id,
        serviceId,
        serviceTitle,
        providerId,
        providerName,
        date,
        timeSlot,
        address,
        price,
        status,
        paymentMethod,
        notes,
      ];
}
