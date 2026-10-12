import 'package:flutter/material.dart';

import '../../../core/models/service_request.dart';
import '../../../core/widgets/ui_kit.dart';
import '../data/requests_repository.dart';
import 'chat_view.dart';
import 'job_done_review_view.dart';

/// Screen 3.5: Customer Live Tracking.
/// Streams live provider GPS coordinates from requests/{id}/live/provider and transitions to review on job completion.
class LiveTrackingView extends StatefulWidget {
  const LiveTrackingView({super.key});

  static const route = '/requests/live-tracking';

  @override
  State<LiveTrackingView> createState() => _LiveTrackingViewState();
}

class _LiveTrackingViewState extends State<LiveTrackingView> {
  final _repo = RequestsRepository();

  @override
  Widget build(BuildContext context) {
    final args = (ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?) ?? {};
    final requestId = (args['requestId'] ?? '').toString();
    final providerName = (args['providerName'] ?? 'Provider').toString();

    return Theme(
      data: uiFeatureTheme(context, UiColors.teal),
      child: StreamBuilder<ServiceRequest?>(
        stream: _repo.streamRequest(requestId),
        builder: (context, reqSnap) {
          final req = reqSnap.data;
          // Auto-route to review when job completed
          if (req?.status == 'done') {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.pushReplacementNamed(
                context,
                JobDoneReviewView.route,
                arguments: {
                  'providerId': req?.providerId ?? '',
                  'providerName': providerName,
                },
              );
            });
          }

          return StreamBuilder<Map<String, dynamic>?>(
            stream: _repo.streamLiveProvider(requestId),
            builder: (context, liveSnap) {
              final liveData = liveSnap.data ?? {};
              final hasCoords = liveData.containsKey('lat') && liveData.containsKey('lng');

              return UiScaffold(
                title: 'On the way',
                bottomButton: Row(
                  children: [
                    Expanded(
                      child: UiMainButton(
                        label: 'Call',
                        icon: Icons.phone_rounded,
                        customAccent: UiColors.teal,
                        onPressed: () {},
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
                body: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Arrival estimation banner
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: UiColors.line),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: const BoxDecoration(
                              color: Color(0xFF2E7D32),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                uiText('Arriving in ~8 minutes', size: 14, weight: FontWeight.w800),
                                const SizedBox(height: 2),
                                uiText(
                                  hasCoords ? 'Provider GPS is actively moving' : 'Waiting for provider location ping...',
                                  size: 11.5,
                                  color: UiColors.muted,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Live moving map area
                    Expanded(
                      child: UiMapPlaceholder(
                        label: '$providerName on the way',
                        height: double.infinity,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
