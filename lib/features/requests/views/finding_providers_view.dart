import 'package:flutter/material.dart';

import '../../../core/models/service_request.dart';
import '../../../core/widgets/ui_kit.dart';
import '../data/requests_repository.dart';
import 'cancel_sheet_view.dart';
import 'no_provider_found_view.dart';
import 'request_accepted_view.dart';

/// Screen 3.3: Finding Providers Cover Screen.
/// Streams requests/{id} and auto-transitions when accepted or when no provider found.
class FindingProvidersView extends StatefulWidget {
  const FindingProvidersView({super.key});

  static const route = '/requests/finding-providers';

  @override
  State<FindingProvidersView> createState() => _FindingProvidersViewState();
}

class _FindingProvidersViewState extends State<FindingProvidersView> {
  final _repo = RequestsRepository();

  @override
  Widget build(BuildContext context) {
    final args = (ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?) ?? {};
    final requestId = (args['requestId'] ?? '').toString();

    if (requestId.isEmpty) {
      return const Scaffold(
        body: Center(child: Text('Request not specified')),
      );
    }

    return Theme(
      data: uiFeatureTheme(context, UiColors.teal),
      child: StreamBuilder<ServiceRequest?>(
        stream: _repo.streamRequest(requestId),
        builder: (context, snapshot) {
          final req = snapshot.data;
          final status = req?.status.toLowerCase();

          // Auto-transitions on status change
          if (status == 'accepted' || status == 'on_the_way' || status == 'in_progress') {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.pushReplacementNamed(
                context,
                RequestAcceptedView.route,
                arguments: {'request': req, 'requestId': requestId},
              );
            });
          } else if (status == 'no_provider') {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.pushReplacementNamed(
                context,
                NoProviderFoundView.route,
                arguments: {'requestId': requestId},
              );
            });
          }

          return UiCoverScreen(
            customAccent: UiColors.teal,
            icon: Icons.radar_rounded,
            title: 'Searching nearby providers',
            subtitle:
                'We have alerted verified providers within 5 km of your location. You will receive an instant notification once accepted.',
            secondaryButtonText: 'Cancel request',
            onSecondaryPressed: () {
              Navigator.pushNamed(
                context,
                CancelSheetView.route,
                arguments: {'requestId': requestId},
              );
            },
          );
        },
      ),
    );
  }
}
