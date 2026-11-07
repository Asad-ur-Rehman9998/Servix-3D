import 'dart:convert';

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

  BookingStatus? get next {
    switch (this) {
      case BookingStatus.confirmed:
        return BookingStatus.assigned;
      case BookingStatus.assigned:
        return BookingStatus.onTheWay;
      case BookingStatus.onTheWay:
        return BookingStatus.started;
      case BookingStatus.started:
        return BookingStatus.completed;
      case BookingStatus.completed:
      case BookingStatus.cancelled:
        return null;
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

  BookingEntity copyWith({
    BookingStatus? status,
    DateTime? date,
    String? timeSlot,
    String? address,
    String? notes,
    PaymentMethodType? paymentMethod,
  }) {
    return BookingEntity(
      id: id,
      serviceId: serviceId,
      serviceTitle: serviceTitle,
      providerId: providerId,
      providerName: providerName,
      date: date ?? this.date,
      timeSlot: timeSlot ?? this.timeSlot,
      address: address ?? this.address,
      price: price,
      status: status ?? this.status,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'serviceId': serviceId,
        'serviceTitle': serviceTitle,
        'providerId': providerId,
        'providerName': providerName,
        'date': date.toIso8601String(),
        'timeSlot': timeSlot,
        'address': address,
        'price': price,
        'status': status.name,
        'paymentMethod': paymentMethod.name,
        'notes': notes,
      };

  factory BookingEntity.fromJson(Map<String, dynamic> json) {
    return BookingEntity(
      id: json['id'] as String,
      serviceId: json['serviceId'] as String,
      serviceTitle: json['serviceTitle'] as String,
      providerId: json['providerId'] as String,
      providerName: json['providerName'] as String,
      date: DateTime.parse(json['date'] as String),
      timeSlot: json['timeSlot'] as String,
      address: json['address'] as String,
      price: (json['price'] as num).toDouble(),
      status: BookingStatus.values.byName(json['status'] as String),
      paymentMethod:
          PaymentMethodType.values.byName(json['paymentMethod'] as String),
      notes: json['notes'] as String?,
    );
  }

  static String encodeList(List<BookingEntity> items) =>
      jsonEncode(items.map((e) => e.toJson()).toList());

  static List<BookingEntity> decodeList(String raw) {
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => BookingEntity.fromJson(e as Map<String, dynamic>))
        .toList();
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
