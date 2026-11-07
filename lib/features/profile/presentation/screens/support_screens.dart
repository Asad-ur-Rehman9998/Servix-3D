import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_button.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Help & Support')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'How can we help?',
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          const Text(
            'Browse FAQs or reach the Servix support team. Demo responses are mocked.',
          ),
          const SizedBox(height: 20),
          const _FaqTile(
            question: 'How do I book a service?',
            answer:
                'Open Explore or Home, pick a service, tap Book Now, choose provider/date/time, then confirm payment.',
          ),
          const _FaqTile(
            question: 'Can I reschedule?',
            answer:
                'Yes. Open Bookings → select a booking → Reschedule to pick a new date and time slot.',
          ),
          const _FaqTile(
            question: 'How do payments work?',
            answer:
                'Card, cash, and wallet options are available. In this portfolio build, charges are mocked securely.',
          ),
          const SizedBox(height: 16),
          Card(
            child: ListTile(
              leading:
                  const Icon(Icons.email_outlined, color: AppColors.primary),
              title: const Text('Email support'),
              subtitle: const Text('support@servix3d.com'),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Opening mail client is mocked in demo'),
                  ),
                );
              },
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.chat_bubble_outline,
                  color: AppColors.primary),
              title: const Text('Live chat'),
              subtitle: const Text('Average reply under 5 minutes'),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Chat widget coming soon')),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _FaqTile extends StatelessWidget {
  const _FaqTile({required this.question, required this.answer});
  final String question;
  final String answer;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ExpansionTile(
        title:
            Text(question, style: const TextStyle(fontWeight: FontWeight.w700)),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: [Text(answer)],
      ),
    );
  }
}

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Privacy')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Your data, your control',
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          const Text(
            'Servix 3D stores session tokens in secure storage and preferences locally on device. '
            'Demo mode does not send personal data to a live backend.\n\n'
            'When you connect a real API, use HTTPS, short-lived tokens, and never commit secrets to git.',
          ),
          const SizedBox(height: 16),
          const ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.lock_outline, color: AppColors.primary),
            title: Text('Secure token storage'),
            subtitle: Text('Flutter Secure Storage for access/refresh tokens'),
          ),
          const ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.delete_outline, color: AppColors.primary),
            title: Text('Delete account'),
            subtitle: Text('Contact support to request account deletion'),
          ),
        ],
      ),
    );
  }
}

class SecurityScreen extends StatelessWidget {
  const SecurityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Security')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          ListTile(
            leading:
                const Icon(Icons.password_rounded, color: AppColors.primary),
            title: const Text('Change password'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/forgot-password'),
          ),
          const ListTile(
            leading:
                Icon(Icons.phonelink_lock_rounded, color: AppColors.primary),
            title: Text('Two-factor authentication'),
            subtitle: Text('Coming soon'),
          ),
          const ListTile(
            leading: Icon(Icons.devices_rounded, color: AppColors.primary),
            title: Text('Active sessions'),
            subtitle: Text('This device · mock session'),
          ),
          const SizedBox(height: 12),
          Text(
            'Tips: use a unique password, enable device biometrics in production builds, '
            'and rotate API keys via .env — never hardcode secrets.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('About')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Center(
            child: Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              ),
              child: const Icon(Icons.view_in_ar_rounded,
                  color: Colors.white, size: 42),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            AppConstants.appName,
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(fontWeight: FontWeight.w800),
          ),
          Text(
            AppConstants.appTagline,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 8),
          const Text('Version 1.0.0', textAlign: TextAlign.center),
          const SizedBox(height: 24),
          const Text(
            'Servix 3D is a portfolio-grade Flutter marketplace demonstrating clean architecture, '
            'Riverpod, GoRouter, Dio-ready networking, secure storage, booking flows, and interactive 3D-style UI.',
          ),
          const SizedBox(height: 16),
          AppButton(
            label: 'GitHub: Asad-ur-Rehman9998/servix_3d',
            variant: AppButtonVariant.secondary,
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('https://github.com/Asad-ur-Rehman9998/servix_3d'),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class PaymentMethodsScreen extends StatefulWidget {
  const PaymentMethodsScreen({super.key});

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  String _selected = 'card';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Payment methods')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Saved methods are mocked locally. Card numbers are never stored.',
          ),
          const SizedBox(height: 12),
          ...[
            ('card', 'Visa ···· 4242', 'Expires 12/28', Icons.credit_card),
            (
              'wallet',
              'Servix Wallet',
              'Balance \$120.00',
              Icons.account_balance_wallet_outlined
            ),
            ('cash', 'Cash on service', null, Icons.payments_outlined),
          ].map((item) {
            final selected = _selected == item.$1;
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: Icon(item.$4, color: AppColors.primary),
                title: Text(item.$2),
                subtitle: item.$3 == null ? null : Text(item.$3!),
                trailing: Icon(
                  selected
                      ? Icons.radio_button_checked
                      : Icons.radio_button_off,
                  color: AppColors.primary,
                ),
                onTap: () => setState(() => _selected = item.$1),
              ),
            );
          }),
          const SizedBox(height: 16),
          AppButton(
            label: 'Add card',
            variant: AppButtonVariant.secondary,
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content:
                      Text('Stripe card form can be wired via PaymentService'),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class ContactProviderScreen extends StatefulWidget {
  const ContactProviderScreen({
    super.key,
    required this.providerName,
    this.providerId,
  });

  final String providerName;
  final String? providerId;

  @override
  State<ContactProviderScreen> createState() => _ContactProviderScreenState();
}

class _ContactProviderScreenState extends State<ContactProviderScreen> {
  final _controller = TextEditingController();
  final _messages = <String>[];

  @override
  void initState() {
    super.initState();
    _messages.add(
      'Hi! Thanks for booking with ${widget.providerName}. How can I help?',
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Message ${widget.providerName}')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: _messages.length,
                itemBuilder: (context, i) {
                  final mine = i.isOdd;
                  return Align(
                    alignment:
                        mine ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: mine
                            ? AppColors.primary
                            : AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        _messages[i],
                        style: TextStyle(
                          color: mine ? Colors.white : null,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Type a message…',
                    ),
                    onSubmitted: (_) => _send(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: _send,
                  icon: const Icon(Icons.send_rounded),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add(text);
      _messages.add('Thanks — I will get back to you shortly.');
      _controller.clear();
    });
  }
}
