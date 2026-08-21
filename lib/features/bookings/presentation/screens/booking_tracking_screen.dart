import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../shared/data/mock_data.dart';
import '../../domain/entities/booking_entity.dart';
import '../providers/bookings_provider.dart';

class BookingTrackingScreen extends ConsumerWidget {
  const BookingTrackingScreen({super.key, required this.bookingId});

  final String bookingId;

  static const _timeline = [
    BookingStatus.confirmed,
    BookingStatus.assigned,
    BookingStatus.onTheWay,
    BookingStatus.started,
    BookingStatus.completed,
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(bookingByIdProvider(bookingId));

    return Scaffold(
      appBar: AppBar(title: const Text('Track booking')),
      body: async.when(
        loading: () => const LoadingWidget(),
        error: (e, _) => ErrorView(message: '$e'),
        data: (booking) {
          if (booking == null) {
            return const ErrorView(message: 'Booking not found');
          }
          final current = booking.status.stepIndex;
          final provider = MockData.providers
              .where((p) => p.id == booking.providerId)
              .firstOrNull;

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                booking.serviceTitle,
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 4),
              Text('Booking ID · ${booking.id}'),
              const SizedBox(height: 20),
              ...List.generate(_timeline.length, (i) {
                final status = _timeline[i];
                final done = current >= i && current >= 0;
                final active = current == i;
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: done
                                ? AppColors.primary
                                : AppColors.primary.withValues(alpha: 0.15),
                          ),
                          child: Icon(
                            done ? Icons.check_rounded : Icons.circle,
                            size: done ? 16 : 8,
                            color: done ? Colors.white : AppColors.primary,
                          ),
                        ),
                        if (i != _timeline.length - 1)
                          Container(
                            width: 3,
                            height: 42,
                            color: done
                                ? AppColors.primary
                                : AppColors.primary.withValues(alpha: 0.15),
                          ),
                      ],
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 4, bottom: 24),
                        child: Text(
                          status.label,
                          style: TextStyle(
                            fontWeight:
                                active ? FontWeight.w800 : FontWeight.w500,
                            color: done
                                ? null
                                : Theme.of(context).disabledColor,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Provider: ${booking.providerName}'),
                      Text(
                        '${DateFormat.yMMMd().format(booking.date)} · ${booking.timeSlot}',
                      ),
                      Text(booking.address),
                      Text(
                        '\$${booking.price.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              if (provider != null)
                AppButton(
                  label: 'View provider',
                  variant: AppButtonVariant.secondary,
                  onPressed: () =>
                      context.push('/providers/${provider.id}'),
                ),
              const SizedBox(height: 10),
              AppButton(
                label: 'Open map',
                variant: AppButtonVariant.ghost,
                onPressed: () => context.push('/map'),
              ),
              if (booking.status != BookingStatus.completed &&
                  booking.status != BookingStatus.cancelled) ...[
                const SizedBox(height: 10),
                AppButton(
                  label: 'Cancel booking',
                  variant: AppButtonVariant.ghost,
                  onPressed: () async {
                    await ref
                        .read(bookingsListProvider.notifier)
                        .cancel(booking.id);
                    if (context.mounted) {
                      ref.invalidate(bookingByIdProvider(bookingId));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Booking cancelled')),
                      );
                    }
                  },
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}
