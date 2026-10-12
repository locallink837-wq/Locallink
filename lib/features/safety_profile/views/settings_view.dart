import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../core/widgets/ui_kit.dart';
import '../data/safety_profile_repository.dart';

/// Screen 5.5: App Settings.
/// Manages language, notifications, dark mode preference, and sign-out.
class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  static const route = '/safety-profile/settings';

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  final _repo = SafetyProfileRepository();
  bool _notificationsEnabled = true;
  bool _darkMode = false;
  String _selectedLanguage = 'English';

  void _saveSettings() {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    if (uid.isNotEmpty) {
      _repo.updateSettings(
        uid: uid,
        settings: {
          'notifications': _notificationsEnabled,
          'darkMode': _darkMode,
        },
        language: _selectedLanguage == 'Hindi' ? 'hi' : (_selectedLanguage == 'Marathi' ? 'mr' : 'en'),
      );
    }
  }

  Future<void> _handleSignOut() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: uiText('Log out', size: 18, weight: FontWeight.w800),
        content: uiText('Are you sure you want to log out of LocaLink?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: uiText('Cancel', color: UiColors.muted),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: UiColors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Log out', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await FirebaseAuth.instance.signOut();
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, '/auth/splash', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: uiFeatureTheme(context, UiColors.teal),
      child: UiScaffold(
        title: 'Settings',
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              uiText('Preferences', size: 14, weight: FontWeight.w800),
              const SizedBox(height: 10),

              // Language selector tile
              Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: UiColors.teal.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(11),
                          ),
                          child: const Icon(Icons.language_rounded, size: 18, color: UiColors.teal),
                        ),
                        const SizedBox(width: 10),
                        uiText('Language', size: 13.5, weight: FontWeight.w700),
                      ],
                    ),
                    DropdownButton<String>(
                      value: _selectedLanguage,
                      underline: const SizedBox(),
                      items: const [
                        DropdownMenuItem(value: 'English', child: Text('English')),
                        DropdownMenuItem(value: 'Hindi', child: Text('हिंदी (Hindi)')),
                        DropdownMenuItem(value: 'Marathi', child: Text('मराठी (Marathi)')),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          setState(() => _selectedLanguage = val);
                          _saveSettings();
                        }
                      },
                    ),
                  ],
                ),
              ),

              // Notifications Switch Tile
              Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: UiColors.teal.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(11),
                          ),
                          child: const Icon(Icons.notifications_outlined, size: 18, color: UiColors.teal),
                        ),
                        const SizedBox(width: 10),
                        uiText('Notifications', size: 13.5, weight: FontWeight.w700),
                      ],
                    ),
                    Switch(
                      value: _notificationsEnabled,
                      activeThumbColor: UiColors.teal,
                      onChanged: (val) {
                        setState(() => _notificationsEnabled = val);
                        _saveSettings();
                      },
                    ),
                  ],
                ),
              ),

              // Dark mode Switch Tile
              Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: UiColors.teal.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(11),
                          ),
                          child: const Icon(Icons.dark_mode_outlined, size: 18, color: UiColors.teal),
                        ),
                        const SizedBox(width: 10),
                        uiText('Dark mode', size: 13.5, weight: FontWeight.w700),
                      ],
                    ),
                    Switch(
                      value: _darkMode,
                      activeThumbColor: UiColors.teal,
                      onChanged: (val) {
                        setState(() => _darkMode = val);
                        _saveSettings();
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              uiText('Account & Privacy', size: 14, weight: FontWeight.w800),
              const SizedBox(height: 10),

              UiListTile(
                title: 'Privacy Policy',
                subtitle: 'Data usage and security standards',
                icon: Icons.privacy_tip_outlined,
                customAccent: UiColors.teal,
                onTap: () {},
              ),

              UiListTile(
                title: 'Log out',
                subtitle: 'Sign out of current account',
                icon: Icons.logout_rounded,
                customAccent: UiColors.red,
                onTap: _handleSignOut,
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
