import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../shared/data/mock_data.dart';
import '../../domain/entities/booking_entity.dart';
import '../providers/bookings_provider.dart';

class BookingsScreen extends ConsumerWidget {
  const BookingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(bookingsListProvider);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My Bookings'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Upcoming'),
              Tab(text: 'Past'),
            ],
          ),
        ),
        body: async.when(
          loading: () => const LoadingWidget(),
          error: (e, _) => ErrorView(
            message: '$e',
            onRetry: () =>
                ref.read(bookingsListProvider.notifier).refresh(),
          ),
          data: (bookings) {
            final upcoming = bookings
                .where((b) =>
                    b.status != BookingStatus.completed &&
                    b.status != BookingStatus.cancelled)
                .toList();
            final past = bookings
                .where((b) =>
                    b.status == BookingStatus.completed ||
                    b.status == BookingStatus.cancelled)
                .toList();
            return TabBarView(
              children: [
                _BookingList(items: upcoming),
                _BookingList(items: past),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _BookingList extends StatelessWidget {
  const _BookingList({required this.items});
  final List<BookingEntity> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const EmptyStateWidget(
        icon: Icons.calendar_today_outlined,
        title: 'No bookings here',
        subtitle: 'Book a service from Explore to get started.',
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, i) {
        final b = items[i];
        return Material(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          child: InkWell(
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            onTap: () => context.push('/bookings/${b.id}/track'),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                border: Border.all(
                  color: Theme.of(context).dividerColor,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          b.serviceTitle,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          b.status.label,
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text('${b.providerName} · ${b.timeSlot}'),
                  Text(DateFormat.yMMMd().format(b.date)),
                  const SizedBox(height: 4),
                  Text(
                    '\$${b.price.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class BookingFlowScreen extends ConsumerStatefulWidget {
  const BookingFlowScreen({super.key});

  @override
  ConsumerState<BookingFlowScreen> createState() => _BookingFlowScreenState();
}

class _BookingFlowScreenState extends ConsumerState<BookingFlowScreen> {
  late final TextEditingController _addressCtrl;
  late final TextEditingController _notesCtrl;

  @override
  void initState() {
    super.initState();
    final draft = ref.read(bookingDraftProvider);
    _addressCtrl = TextEditingController(text: draft.address ?? '');
    _notesCtrl = TextEditingController(text: draft.notes ?? '');
  }

  @override
  void dispose() {
    _addressCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      firstDate: now,
      lastDate: now.add(const Duration(days: 60)),
      initialDate: ref.read(bookingDraftProvider).date ?? now.add(const Duration(days: 1)),
    );
    if (picked != null) {
      ref.read(bookingDraftProvider.notifier).selectDate(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(bookingDraftProvider);
    final notifier = ref.read(bookingDraftProvider.notifier);
    final steps = ['Provider', 'Date', 'Time', 'Address', 'Review'];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Book service'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () {
            if (draft.step > 0) {
              notifier.previousStep();
            } else {
              context.pop();
            }
          },
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  draft.serviceTitle ?? 'Service',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 12),
                Row(
                  children: List.generate(steps.length, (i) {
                    final active = i <= draft.step;
                    return Expanded(
                      child: Container(
                        margin: EdgeInsets.only(right: i == steps.length - 1 ? 0 : 6),
                        height: 6,
                        decoration: BoxDecoration(
                          color: active
                              ? AppColors.primary
                              : AppColors.primary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 8),
                Text(
                  'Step ${draft.step + 1} of ${steps.length}: ${steps[draft.step]}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          Expanded(child: _buildStep(draft, notifier)),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
              child: AppButton(
                label: draft.step == steps.length - 1
                    ? 'Continue to payment'
                    : 'Continue',
                onPressed: !draft.canContinue
                    ? null
                    : () {
                        if (draft.step == steps.length - 1) {
                          context.push('/payment');
                        } else {
                          if (draft.step == 3) {
                            notifier.setAddress(_addressCtrl.text.trim());
                            notifier.setNotes(_notesCtrl.text.trim());
                          }
                          notifier.nextStep();
                        }
                      },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep(BookingDraft draft, BookingDraftController notifier) {
    switch (draft.step) {
      case 0:
        return ListView.separated(
          padding: const EdgeInsets.all(20),
          itemCount: MockData.providers.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, i) {
            final p = MockData.providers[i];
            final selected = draft.providerId == p.id;
            return ListTile(
              selected: selected,
              selectedTileColor: AppColors.primary.withValues(alpha: 0.08),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                side: BorderSide(
                  color: selected ? AppColors.primary : Theme.of(context).dividerColor,
                ),
              ),
              leading: CircleAvatar(
                backgroundImage: p.avatarUrl.startsWith('assets/')
                    ? AssetImage(p.avatarUrl) as ImageProvider
                    : NetworkImage(p.avatarUrl),
              ),
              title: Text(p.name),
              subtitle: Text('${p.title} · ${p.rating}★ · ${p.distanceKm} km'),
              trailing: selected
                  ? const Icon(Icons.check_circle, color: AppColors.primary)
                  : null,
              onTap: () => notifier.selectProvider(
                providerId: p.id,
                providerName: p.name,
              ),
            );
          },
        );
      case 1:
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  draft.date == null
                      ? 'Select a date'
                      : DateFormat.yMMMMEEEEd().format(draft.date!),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 20),
                AppButton(
                  label: 'Pick date',
                  expand: false,
                  onPressed: _pickDate,
                ),
              ],
            ),
          ),
        );
      case 2:
        return GridView.builder(
          padding: const EdgeInsets.all(20),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 2.2,
          ),
          itemCount: MockData.timeSlots.length,
          itemBuilder: (context, i) {
            final slot = MockData.timeSlots[i];
            final selected = draft.timeSlot == slot;
            return ChoiceChip(
              label: Text(slot),
              selected: selected,
              onSelected: (_) => notifier.selectTimeSlot(slot),
            );
          },
        );
      case 3:
        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            TextField(
              controller: _addressCtrl,
              onChanged: notifier.setAddress,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Service address',
                hintText: 'Street, city, zip',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _notesCtrl,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Notes (optional)',
                hintText: 'Gate code, pets, access info…',
              ),
            ),
          ],
        );
      default:
        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _ReviewRow('Service', draft.serviceTitle ?? '-'),
            _ReviewRow('Provider', draft.providerName ?? '-'),
            _ReviewRow(
              'Date',
              draft.date == null
                  ? '-'
                  : DateFormat.yMMMd().format(draft.date!),
            ),
            _ReviewRow('Time', draft.timeSlot ?? '-'),
            _ReviewRow('Address', draft.address ?? '-'),
            _ReviewRow(
              'Price',
              '\$${(draft.price ?? 0).toStringAsFixed(0)}',
            ),
          ],
        );
    }
  }
}

class _ReviewRow extends StatelessWidget {
  const _ReviewRow(this.label, this.value);
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
