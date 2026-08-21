import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../bookings/domain/entities/booking_entity.dart';

/// Contract for charging a booking. Swap [MockPaymentService] for a real
/// gateway (Stripe, etc.) without changing the payment UI.
abstract class PaymentService {
  Future<PaymentResult> processPayment({
    required double amount,
    required PaymentMethodType method,
    String? cardLast4,
  });
}

class PaymentResult {
  const PaymentResult({
    required this.success,
    required this.transactionId,
    this.message,
  });

  final bool success;
  final String transactionId;
  final String? message;
}

class MockPaymentService implements PaymentService {
  @override
  Future<PaymentResult> processPayment({
    required double amount,
    required PaymentMethodType method,
    String? cardLast4,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 900));

    if (amount <= 0) {
      return const PaymentResult(
        success: false,
        transactionId: '',
        message: 'Invalid amount',
      );
    }

    final suffix = DateTime.now().millisecondsSinceEpoch.toString().substring(7);
    return PaymentResult(
      success: true,
      transactionId: 'txn_$suffix',
      message: switch (method) {
        PaymentMethodType.card =>
          'Card ending ${cardLast4 ?? '4242'} charged successfully',
        PaymentMethodType.cash => 'Pay cash to the professional on arrival',
        PaymentMethodType.wallet => 'Wallet balance deducted',
      },
    );
  }
}

final paymentServiceProvider = Provider<PaymentService>((ref) {
  return MockPaymentService();
});
