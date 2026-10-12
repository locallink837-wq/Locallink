import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/models/listing.dart';
import '../../../core/models/service_request.dart';
import '../../../core/widgets/ui_kit.dart';
import '../data/requests_repository.dart';
import 'chat_view.dart';
import 'live_tracking_view.dart';

/// Screen 3.4: Request Accepted by Provider.
/// Displays accepted provider details, status stepper, direct phone calling, and chat.
class RequestAcceptedView extends StatefulWidget {
  const RequestAcceptedView({super.key});

  static const route = '/requests/request-accepted';

  @override
  State<RequestAcceptedView> createState() => _RequestAcceptedViewState();
}

class _RequestAcceptedViewState extends State<RequestAcceptedView> {
  final _repo = RequestsRepository();
  Listing? _providerListing;
  bool _isLoading = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_providerListing == null && _isLoading) {
      _loadProvider();
    }
  }

  Future<void> _loadProvider() async {
    final args = (ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?) ?? {};
    final req = args['request'] as ServiceRequest?;
    final providerId = req?.providerId ?? '';

    if (providerId.isNotEmpty) {
      final listing = await _repo.getProviderListing(providerId);
      if (!mounted) return;
      setState(() {
        _providerListing = listing;
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  void _callProvider(String phone) async {
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
    final req = args['request'] as ServiceRequest?;
    final requestId = (args['requestId'] ?? req?.id ?? '').toString();

    final providerName = _providerListing?.name ?? req?.providerName ?? 'Assigned Provider';
    final providerPhone = _providerListing?.phone ?? req?.customerPhone ?? '+91 98765 00000';

    return Theme(
      data: uiFeatureTheme(context, UiColors.teal),
      child: UiScaffold(
        title: 'Request accepted',
        bottomButton: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            UiMainButton(
              label: 'Track provider live',
              icon: Icons.navigation_rounded,
              customAccent: UiColors.teal,
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  LiveTrackingView.route,
                  arguments: {'requestId': requestId, 'providerName': providerName},
                );
              },
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: UiGhostButton(
                    label: 'Call',
                    icon: Icons.phone_rounded,
                    customAccent: UiColors.teal,
                    onPressed: () => _callProvider(providerPhone),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: UiGhostButton(
                    label: 'Chat',
                    icon: Icons.chat_bubble_outline_rounded,
                    customAccent: UiColors.teal,
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        ChatView.route,
                        arguments: {'requestId': requestId, 'recipientName': providerName},
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Status Stepper: Open > Accepted > On the way > Done
                    const UiStepper(
                      totalSteps: 4,
                      currentStep: 2,
                      customAccent: UiColors.teal,
                      stepLabels: ['Open', 'Accepted', 'On the way', 'Done'],
                    ),
                    const SizedBox(height: 20),

                    // Success banner
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle_rounded, color: Color(0xFF2E7D32), size: 22),
                          const SizedBox(width: 10),
                          Expanded(
                            child: uiText(
                              'A provider has accepted your request and unlocked your contact info.',
                              size: 12.5,
                              color: const Color(0xFF1B5E20),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Provider Card
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
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: UiColors.teal.withValues(alpha: 0.12),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.handyman_rounded, color: UiColors.teal, size: 26),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    uiText(providerName, size: 16, weight: FontWeight.w800),
                                    const SizedBox(height: 2),
                                    uiText(providerPhone, size: 13, color: UiColors.muted),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 24),
                          Row(
                            children: [
                              const Icon(Icons.star_rounded, color: UiColors.star, size: 20),
                              const SizedBox(width: 6),
                              uiText(
                                _providerListing != null
                                    ? '${_providerListing!.averageRating.toStringAsFixed(1)} rating (${_providerListing!.reviewCount} reviews)'
                                    : '4.8 rating (Verified provider)',
                                size: 12.5,
                                weight: FontWeight.w700,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Approximate map area
                    UiMapPlaceholder(
                      label: 'Provider moving towards your location',
                      height: 150,
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
      ),
    );
  }
}
