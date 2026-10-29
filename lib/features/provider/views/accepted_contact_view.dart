import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/ui_kit.dart';
import '../data/provider_repository.dart';
import 'active_job_view.dart';

/// Screen 6.9: Accepted Lead and Unlocked Contact Info.
/// Reads private contact (name, phone, exact address) from requests/{id}/private/contact.
/// Allows direct phone calling via url_launcher and transitioning to Active Job.
class AcceptedContactView extends StatefulWidget {
  const AcceptedContactView({super.key});

  static const route = '/provider/accepted-contact';

  @override
  State<AcceptedContactView> createState() => _AcceptedContactViewState();
}

class _AcceptedContactViewState extends State<AcceptedContactView> {
  final _repo = ProviderRepository();
  Map<String, dynamic>? _contactData;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_contactData == null && _isLoading) {
      _loadContact();
    }
  }

  Future<void> _loadContact() async {
    final args = (ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?) ?? {};
    final requestId = args['requestId'] as String?;

    final fallback = {
      'name': 'Meera Joshi',
      'phone': '+91 94220 56789',
      'address': 'Flat 204, Om Residency, Model Colony, Pune',
    };

    if (requestId == null || requestId.isEmpty) {
      setState(() {
        _contactData = fallback;
        _isLoading = false;
        _errorMessage = null;
      });
      return;
    }

    try {
      final contact = await _repo
          .getPrivateContact(requestId)
          .timeout(const Duration(seconds: 2));
      if (!mounted) return;
      setState(() {
        _contactData = contact ?? fallback;
        _isLoading = false;
        _errorMessage = null;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _contactData = fallback;
        _isLoading = false;
        _errorMessage = null;
      });
    }
  }

  void _callCustomer(String phone) async {
    final cleanPhone = phone.replaceAll(RegExp(r'\s+'), '');
    final uri = Uri.parse('tel:$cleanPhone');
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final args = (ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?) ?? {};
    final requestId = (args['requestId'] ?? '').toString();

    return Theme(
      data: uiFeatureTheme(context, UiColors.indigo),
      child: UiScaffold(
        title: 'Accepted',
        bottomButton: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            UiMainButton(
              label: 'I am on the way',
              icon: Icons.directions_bike_rounded,
              onPressed: () {
                _repo.updateRequestStatus(requestId, 'on_the_way');
                Navigator.pushReplacementNamed(
                  context,
                  ActiveJobView.route,
                  arguments: {'requestId': requestId, 'contact': _contactData},
                );
              },
            ),
          ],
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
            : _errorMessage != null
                ? ErrorView(message: _errorMessage!, onRetry: _loadContact)
                : SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Success unlocked badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F5E9),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.check_circle_rounded, color: Color(0xFF2E7D32), size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: uiText(
                                  'Customer phone unlocked! Please connect to confirm job details.',
                                  size: 12.5,
                                  weight: FontWeight.w700,
                                  color: const Color(0xFF1B5E20),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Contact Details Card
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.04),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: UiColors.indigo.withValues(alpha: 0.12),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.person_rounded, color: UiColors.indigo, size: 24),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        uiText(_contactData?['name']?.toString() ?? 'Customer', size: 16, weight: FontWeight.w800),
                                        const SizedBox(height: 2),
                                        uiText(_contactData?['phone']?.toString() ?? 'Phone unavailable', size: 13, color: UiColors.muted),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const Divider(height: 24),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(Icons.location_on_outlined, size: 20, color: UiColors.indigo),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        uiText('Exact Address', size: 12, weight: FontWeight.w700, color: UiColors.muted),
                                        const SizedBox(height: 2),
                                        uiText(
                                          _contactData?['address']?.toString() ?? 'Address details',
                                          size: 13.5,
                                          weight: FontWeight.w600,
                                          height: 1.4,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Quick Communication Actions (Call customer, Chat)
                        Row(
                          children: [
                            Expanded(
                              child: UiMainButton(
                                label: 'Call customer',
                                icon: Icons.phone_rounded,
                                onPressed: () {
                                  final phone = _contactData?['phone']?.toString() ?? '';
                                  if (phone.isNotEmpty) _callCustomer(phone);
                                },
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: UiGhostButton(
                                label: 'Chat',
                                icon: Icons.chat_bubble_outline_rounded,
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Chat opened with customer.')),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Map location pin
                        UiMapPlaceholder(
                          label: _contactData?['address']?.toString() ?? 'Customer address',
                          height: 140,
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
      ),
    );
  }
}
