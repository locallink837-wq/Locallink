import 'package:flutter/material.dart';

import '../../../core/config/env.dart';
import '../../../core/widgets/ui_kit.dart';
import 'plan_loading_view.dart';

/// Screen 4.6: New to City Questionnaire Form.
/// Collects destination locality, household profile, and initial priorities to generate relocation plan.
class NewToCityFormView extends StatefulWidget {
  const NewToCityFormView({super.key});

  static const route = '/assistant/new-to-city-form';

  @override
  State<NewToCityFormView> createState() => _NewToCityFormViewState();
}

class _NewToCityFormViewState extends State<NewToCityFormView> {
  late final TextEditingController _areaController;
  String _selectedHousehold = 'Family with Kids';
  final Set<String> _selectedPriorities = {
    'Water Purifier (RO)',
    'Door Locks',
    'WiFi Broadband',
    'Deep Cleaning',
  };
  String? _errorMessage;

  final _householdTypes = [
    'Family with Kids',
    'Working Professional / Bachelor',
    'Couple',
    'Elderly Parents',
  ];

  final _priorityOptions = [
    'Water Purifier (RO)',
    'Door Locks',
    'WiFi Broadband',
    'Deep Cleaning',
    'LPG Gas Pipeline',
    'AC & Geyser Installation',
    'Daily Milk & Grocery',
    'Pest Control',
  ];

  @override
  void initState() {
    super.initState();
    _areaController = TextEditingController(text: Env.defaultAreaLabel);
  }

  @override
  void dispose() {
    _areaController.dispose();
    super.dispose();
  }

  void _onGenerate() {
    final area = _areaController.text.trim();
    if (area.isEmpty) {
      setState(() => _errorMessage = 'Please enter your destination locality or city');
      return;
    }

    setState(() => _errorMessage = null);

    Navigator.pushNamed(
      context,
      PlanLoadingView.route,
      arguments: {
        'destinationArea': area,
        'householdType': _selectedHousehold,
        'immediateNeeds': _selectedPriorities.toList(),
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: uiFeatureTheme(context, UiColors.indigo),
      child: UiScaffold(
        title: 'New to City Guide',
        bottomButton: UiMainButton(
          label: 'Generate Move-In Checklist',
          customAccent: UiColors.indigo,
          onPressed: _onGenerate,
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              uiText('Personalized Relocation Assistant', size: 18, weight: FontWeight.w800),
              const SizedBox(height: 6),
              uiText(
                'Tell us about your relocation and Gemini AI will curate day-1 tasks and vetted neighborhood trades.',
                size: 13.5,
                color: UiColors.muted,
                height: 1.4,
              ),
              const SizedBox(height: 20),

              if (_errorMessage != null) ...[
                UiWarningBanner(text: _errorMessage!),
                const SizedBox(height: 14),
              ],

              // Locality text input
              UiTextInput(
                label: 'Destination Locality & City',
                hintText: 'e.g. Kothrud, Pune or Indiranagar, Bengaluru',
                controller: _areaController,
              ),
              const SizedBox(height: 20),

              // Household Profile
              uiText('Household Profile', size: 13.5, weight: FontWeight.w700),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final type in _householdTypes)
                    UiChip(
                      label: type,
                      isSelected: _selectedHousehold == type,
                      customAccent: UiColors.indigo,
                      onTap: () => setState(() => _selectedHousehold = type),
                    ),
                ],
              ),
              const SizedBox(height: 22),

              // Immediate Priorities
              uiText('Immediate Priorities (Select all that apply)', size: 13.5, weight: FontWeight.w700),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final prio in _priorityOptions)
                    UiChip(
                      label: prio,
                      isSelected: _selectedPriorities.contains(prio),
                      customAccent: UiColors.indigo,
                      onTap: () {
                        setState(() {
                          if (_selectedPriorities.contains(prio)) {
                            _selectedPriorities.remove(prio);
                          } else {
                            _selectedPriorities.add(prio);
                          }
                        });
                      },
                    ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
