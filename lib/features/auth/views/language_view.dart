import 'package:flutter/material.dart';

import '../../../core/localization/app_language.dart';
import '../../../core/widgets/ui_kit.dart';
import '../state/auth_flow.dart';
import 'role_choice_view.dart';

/// Language
/// Module 1 - Auth and onboarding  |  Owner: A
/// The choice is kept in AuthFlow and saved to users/{uid}.language when the account is created.
class LanguageView extends StatefulWidget {
  const LanguageView({super.key});

  static const route = '/auth/language';

  @override
  State<LanguageView> createState() => _LanguageViewState();
}

class _LanguageViewState extends State<LanguageView> {
  static const _languages = <(String code, String name, String native)>[
    ('en', 'English', 'English'),
    ('hi', 'Hindi', 'हिन्दी'),
    ('mr', 'Marathi', 'मराठी'),
  ];

  String _selected = AuthFlow.language;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: uiFeatureTheme(context, UiColors.teal),
      child: UiScaffold(
        title: 'Choose language',
        body: ListView(
          children: [
            uiText(
              'You can change this later in Settings.',
              size: 12.5,
              weight: FontWeight.w500,
              color: UiColors.muted,
            ),
            const SizedBox(height: 14),
            for (final l in _languages)
              _LanguageTile(
                name: l.$2,
                native: l.$3,
                selected: _selected == l.$1,
                onTap: () => setState(() => _selected = l.$1),
              ),
          ],
        ),
        bottomButton: UiMainButton(
          label: 'Continue',
          onPressed: () {
            AuthFlow.language = _selected;
            AppLanguage.instance.setLanguage(_selected);
            Navigator.pushNamed(context, RoleChoiceView.route);
          },
        ),
      ),
    );
  }
}

class _LanguageTile extends StatelessWidget {
  final String name;
  final String native;
  final bool selected;
  final VoidCallback onTap;

  const _LanguageTile({
    required this.name,
    required this.native,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: selected ? accent : UiColors.line,
          width: selected ? 1.6 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      uiText(native, size: 16, weight: FontWeight.w800),
                      const SizedBox(height: 2),
                      uiText(name, size: 12, weight: FontWeight.w500, color: UiColors.muted),
                    ],
                  ),
                ),
                Icon(
                  selected ? Icons.check_circle_rounded : Icons.circle_outlined,
                  color: selected ? accent : UiColors.line,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}