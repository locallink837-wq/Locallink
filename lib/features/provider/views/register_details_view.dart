import 'package:flutter/material.dart';

import '../../../core/widgets/ui_kit.dart';
import 'register_location_view.dart';

/// Screen 6.2: Provider Registration Step 2 - Experience, Radius, Languages & 24x7.
class RegisterDetailsView extends StatefulWidget {
  const RegisterDetailsView({super.key});

  static const route = '/provider/register-details';

  @override
  State<RegisterDetailsView> createState() => _RegisterDetailsViewState();
}

class _RegisterDetailsViewState extends State<RegisterDetailsView> {
  final _experienceController = TextEditingController(text: '3');
  double _radiusKm = 5.0;
  final Set<String> _selectedLanguages = {'English', 'Hindi'};
  bool _open24x7 = false;
  String? _errorMessage;

  final List<String> _allLanguages = ['Hindi', 'Marathi', 'English', 'Gujarati', 'Kannada'];

  @override
  void dispose() {
    _experienceController.dispose();
    super.dispose();
  }

  void _onNext() {
    final expText = _experienceController.text.trim();
    final exp = int.tryParse(expText);

    if (exp == null || exp < 0) {
      setState(() => _errorMessage = 'Please enter valid years of experience');
      return;
    }
    if (_selectedLanguages.isEmpty) {
      setState(() => _errorMessage = 'Please select at least one language you speak');
      return;
    }

    setState(() => _errorMessage = null);

    // Retrieve previous step arguments
    final prevArgs = (ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?) ?? {};
    final combinedData = Map<String, dynamic>.from(prevArgs)
      ..addAll({
        'experienceYears': exp,
        'radiusKm': _radiusKm,
        'languages': _selectedLanguages.toList(),
        'open24x7': _open24x7,
      });

    Navigator.pushNamed(context, RegisterLocationView.route, arguments: combinedData);
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: uiFeatureTheme(context, UiColors.indigo),
      child: UiScaffold(
        title: 'Register (2 of 4)',
        bottomButton: UiMainButton(
          label: 'Next',
          onPressed: _onNext,
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Stepper (2 of 4)
              const UiStepper(
                totalSteps: 4,
                currentStep: 2,
                stepLabels: ['Core', 'Details', 'Area', 'Docs'],
              ),
              const SizedBox(height: 20),

              if (_errorMessage != null) ...[
                UiWarningBanner(text: _errorMessage!),
                const SizedBox(height: 14),
              ],

              // Years of experience input
              UiTextInput(
                label: 'Years of experience',
                hintText: 'e.g. 5',
                controller: _experienceController,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 18),

              // Service radius slider / selection
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  uiText('Service radius', size: 13.5, weight: FontWeight.w600, color: UiColors.muted),
                  uiText('${_radiusKm.toStringAsFixed(0)} km', size: 14, weight: FontWeight.w800, color: UiColors.indigo),
                ],
              ),
              const SizedBox(height: 6),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: UiColors.indigo,
                  inactiveTrackColor: UiColors.line,
                  thumbColor: UiColors.indigo,
                ),
                child: Slider(
                  value: _radiusKm,
                  min: 1.0,
                  max: 25.0,
                  divisions: 24,
                  onChanged: (val) => setState(() => _radiusKm = val),
                ),
              ),
              const SizedBox(height: 14),

              // Languages spoken chips
              uiText('Languages spoken', size: 13.5, weight: FontWeight.w600, color: UiColors.muted),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final lang in _allLanguages)
                    UiChip(
                      label: lang,
                      isSelected: _selectedLanguages.contains(lang),
                      onTap: () {
                        setState(() {
                          if (_selectedLanguages.contains(lang)) {
                            _selectedLanguages.remove(lang);
                          } else {
                            _selectedLanguages.add(lang);
                          }
                        });
                      },
                    ),
                ],
              ),
              const SizedBox(height: 18),

              // 24x7 Availability toggle chip / card
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: UiColors.line),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          uiText('24x7 emergency service', size: 13.5, weight: FontWeight.w700),
                          const SizedBox(height: 2),
                          uiText('Available to take late-night emergency requests', size: 11.5, color: UiColors.muted),
                        ],
                      ),
                    ),
                    Switch(
                      value: _open24x7,
                      activeThumbColor: UiColors.indigo,
                      onChanged: (val) => setState(() => _open24x7 = val),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
