import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../bookings/domain/entities/booking_entity.dart';
import '../../../bookings/presentation/providers/bookings_provider.dart';
import '../../domain/payment_service.dart';

class PaymentScreen extends ConsumerStatefulWidget {
  const PaymentScreen({super.key});

  @override
  ConsumerState<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends ConsumerState<PaymentScreen> {
  PaymentMethodType _method = PaymentMethodType.card;
  final _cardCtrl = TextEditingController(text: '4242 4242 4242 4242');
  final _expiryCtrl = TextEditingController(text: '12/28');
  final _cvcCtrl = TextEditingController(text: '123');
  bool _loading = false;

  @override
  void dispose() {
    _cardCtrl.dispose();
    _expiryCtrl.dispose();
    _cvcCtrl.dispose();
    super.dispose();
  }

  Future<void> _pay() async {
    final draft = ref.read(bookingDraftProvider);
    if (!draft.canContinue && draft.step < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Complete booking details first')),
      );
      return;
    }
    setState(() => _loading = true);
    ref.read(bookingDraftProvider.notifier).setPaymentMethod(_method);

    final payment = await ref.read(paymentServiceProvider).processPayment(
          amount: draft.price ?? 0,
          method: _method,
          cardLast4: _cardCtrl.text.replaceAll(' ', '').length >= 4
              ? _cardCtrl.text.replaceAll(' ', '').substring(
                    _cardCtrl.text.replaceAll(' ', '').length - 4,
                  )
              : null,
        );

    if (!payment.success) {
      setState(() => _loading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(payment.message ?? 'Payment failed')),
      );
      return;
    }

    final booking = draft.copyWith(paymentMethod: _method).toBooking();
    final created =
        await ref.read(bookingsListProvider.notifier).create(booking);
    ref.read(bookingDraftProvider.notifier).reset();
    setState(() => _loading = false);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(payment.message ?? 'Payment successful')),
    );
    context.go('/bookings/${created.id}/track');
  }

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(bookingDraftProvider);
    final amount = draft.price ?? 0;

    return Scaffold(
      appBar: AppBar(title: const Text('Payment')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Total due',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          Text(
            '\$${amount.toStringAsFixed(0)}',
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Card data is never stored. Payments are mocked for portfolio demo.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 20),
          ...PaymentMethodType.values.map((m) {
            final label = switch (m) {
              PaymentMethodType.card => 'Credit / Debit Card',
              PaymentMethodType.cash => 'Cash on Service',
              PaymentMethodType.wallet => 'Digital Wallet',
            };
            final icon = switch (m) {
              PaymentMethodType.card => Icons.credit_card_rounded,
              PaymentMethodType.cash => Icons.payments_rounded,
              PaymentMethodType.wallet => Icons.account_balance_wallet_rounded,
            };
            return RadioListTile<PaymentMethodType>(
              value: m,
              groupValue: _method,
              onChanged: (v) => setState(() => _method = v!),
              title: Text(label),
              secondary: Icon(icon, color: AppColors.primary),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
            );
          }),
          if (_method == PaymentMethodType.card) ...[
            const SizedBox(height: 12),
            AppTextField(
              controller: _cardCtrl,
              label: 'Card number',
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: AppTextField(
                    controller: _expiryCtrl,
                    label: 'Expiry',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppTextField(
                    controller: _cvcCtrl,
                    label: 'CVC',
                    obscureText: true,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 28),
          AppButton(
            label: 'Confirm & pay',
            isLoading: _loading,
            onPressed: _pay,
          ),
        ],
      ),
    );
  }
}
