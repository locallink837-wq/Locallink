import 'package:flutter/material.dart';

import '../../../core/constants/enums.dart';
import '../../../core/widgets/ui_kit.dart';
import '../data/auth_repository.dart';
import '../state/auth_flow.dart';
import 'sign_in_view.dart';

/// Role choice
/// Module 1 - Auth and onboarding  |  Owner: A
/// Role comes BEFORE login. The role is saved to users/{uid}.role after sign-in (it never changes later).
class RoleChoiceView extends StatefulWidget {
  const RoleChoiceView({super.key});

  static const route = '/auth/role-choice';

  @override
  State<RoleChoiceView> createState() => _RoleChoiceViewState();
}

class _RoleChoiceViewState extends State<RoleChoiceView> {
  static const _repo = AuthRepository();

  UserRole? _selected;
  bool _busy = false;

  static const _info = <UserRole, (IconData icon, String hint, Color color)>{
    UserRole.customer: (Icons.person_rounded, 'Find services, places and shops', UiColors.teal),
    UserRole.provider: (Icons.handyman_rounded, 'Get job requests near you', UiColors.indigo),
    UserRole.shopOwner: (Icons.storefront_rounded, 'List your shop', UiColors.amber),
    UserRole.placeOwner: (Icons.apartment_rounded, 'List your place', UiColors.amber),
  };

  Future<void> _continue({required bool login}) async {
    final role = _selected ?? (login ? UserRole.customer : null);
    if (role == null || _busy) return;
    AuthFlow.chooseRole(role, login: login);

    // Already logged in but the account was never finished: skip sign-in.
    if (_repo.isRealUser) {
      setState(() => _busy = true);
      try {
        await AuthFlow.afterSignIn(context, _repo);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AuthRepository.friendlyError(e))),
          );
        }
      } finally {
        if (mounted) setState(() => _busy = false);
      }
      return;
    }
    Navigator.pushNamed(context, SignInView.route);
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: uiFeatureTheme(context, UiColors.teal),
      child: UiScaffold(
        title: 'I am a',
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              uiText(
                'Pick what describes you best. You can use only one role per account.',
                size: 12.5,
                weight: FontWeight.w500,
                color: UiColors.muted,
              ),
              const SizedBox(height: 14),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.95,
                children: [
                  for (final role in UserRole.values)
                    _RoleTile(
                      label: role.displayName,
                      hint: _info[role]!.$2,
                      icon: _info[role]!.$1,
                      color: _info[role]!.$3,
                      selected: _selected == role,
                      onTap: () => setState(() => _selected = role),
                    ),
                ],
              ),
            ],
          ),
        ),
        bottomButton: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            UiMainButton(
              label: 'Continue',
              isLoading: _busy,
              onPressed: _selected == null ? null : () => _continue(login: false),
            ),
            const SizedBox(height: 10),
            UiGhostButton(
              label: 'I already have an account',
              onPressed: _busy ? null : () => _continue(login: true),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoleTile extends StatelessWidget {
  final String label;
  final String hint;
  final IconData icon;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  const _RoleTile({
    required this.label,
    required this.hint,
    required this.icon,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: selected ? color.withValues(alpha: 0.08) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: selected ? color : UiColors.line,
          width: selected ? 1.8 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.14),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 26),
                ),
                const SizedBox(height: 10),
                uiText(label, size: 14, weight: FontWeight.w800, align: TextAlign.center),
                const SizedBox(height: 4),
                uiText(
                  hint,
                  size: 11,
                  weight: FontWeight.w500,
                  color: UiColors.muted,
                  align: TextAlign.center,
                  height: 1.3,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}