import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../core/widgets/ui_kit.dart';
import '../data/provider_repository.dart';

/// Screen: Edit Services (Tagged NEW in UI/UX E_F).
/// Allows provider to update offered services, experience years, and 24x7 toggle.
class EditServicesView extends StatefulWidget {
  const EditServicesView({super.key});

  static const route = '/provider/edit-services';

  @override
  State<EditServicesView> createState() => _EditServicesViewState();
}

class _EditServicesViewState extends State<EditServicesView> {
  final _repo = ProviderRepository();
  final _experienceController = TextEditingController();

  List<String> _availableCategories = [];
  final Set<String> _selectedServices = {};
  bool _open24x7 = false;
  bool _isLoading = true;
  bool _isSaving = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadCurrentServices();
  }

  @override
  void dispose() {
    _experienceController.dispose();
    super.dispose();
  }

  Future<void> _loadCurrentServices() async {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    try {
      try {
        final categories = await _repo.fetchServiceCategories();
        _availableCategories = categories.isNotEmpty
            ? categories
            : ['Plumber', 'Electrician', 'Carpenter', 'Locksmith', 'Cleaning', 'Appliance Repair'];
      } catch (_) {
        _availableCategories = ['Plumber', 'Electrician', 'Carpenter', 'Locksmith', 'Cleaning', 'Appliance Repair'];
      }

      if (uid.isNotEmpty) {
        try {
          final provData = await _repo.streamProvider(uid).first.timeout(const Duration(seconds: 2));
          if (provData != null) {
            final sList = (provData['services'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [];
            _selectedServices.addAll(sList);
            _experienceController.text = (provData['experienceYears'] ?? 3).toString();
          }
        } catch (_) {
          if (_selectedServices.isEmpty) {
            _selectedServices.addAll(['Plumber', 'Electrician']);
            _experienceController.text = '3';
          }
        }

        try {
          final listing = await _repo.streamListing(uid).first.timeout(const Duration(seconds: 2));
          if (listing != null) {
            _open24x7 = listing.open24x7;
          }
        } catch (_) {}
      } else {
        _selectedServices.addAll(['Plumber', 'Electrician']);
        _experienceController.text = '3';
      }

      if (!mounted) return;
      setState(() => _isLoading = false);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _availableCategories = ['Plumber', 'Electrician', 'Carpenter', 'Locksmith', 'Cleaning', 'Appliance Repair'];
        if (_selectedServices.isEmpty) {
          _selectedServices.addAll(['Plumber', 'Electrician']);
          _experienceController.text = '3';
        }
      });
    }
  }

  Future<void> _saveChanges() async {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    if (uid.isEmpty) return;

    if (_selectedServices.isEmpty) {
      setState(() => _errorMessage = 'Please select at least one service offered');
      return;
    }

    final exp = int.tryParse(_experienceController.text.trim()) ?? 1;

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      await _repo.updateServices(
        uid: uid,
        services: _selectedServices.toList(),
        experienceYears: exp,
        open24x7: _open24x7,
      );

      if (!mounted) return;
      setState(() => _isSaving = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Services updated successfully!'),
          backgroundColor: Color(0xFF2E7D32),
        ),
      );
      Navigator.of(context).maybePop();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSaving = false;
        _errorMessage = 'Failed to update services: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: uiFeatureTheme(context, UiColors.indigo),
      child: UiScaffold(
        title: 'Edit services',
        bottomButton: UiMainButton(
          label: 'Save',
          isLoading: _isSaving,
          onPressed: _saveChanges,
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_errorMessage != null) ...[
                      UiWarningBanner(text: _errorMessage!),
                      const SizedBox(height: 14),
                    ],

                    uiText('Select services you provide', size: 13.5, weight: FontWeight.w700),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final s in _availableCategories)
                          UiChip(
                            label: s,
                            isSelected: _selectedServices.contains(s),
                            onTap: () {
                              setState(() {
                                if (_selectedServices.contains(s)) {
                                  _selectedServices.remove(s);
                                } else {
                                  _selectedServices.add(s);
                                }
                              });
                            },
                          ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Years of Experience
                    UiTextInput(
                      label: 'Years of experience',
                      hintText: 'e.g. 5',
                      controller: _experienceController,
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 18),

                    // 24x7 Availability toggle
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
                                uiText('Receive urgent nighttime customer requests', size: 11.5, color: UiColors.muted),
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
