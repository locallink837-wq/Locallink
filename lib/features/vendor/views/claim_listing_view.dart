import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/models/listing.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/ui_kit.dart';
import '../data/vendor_repository.dart';

/// Screen 7.7: Claim Existing Listing.
/// Searches active unclaimed listings, uploads ownership proof to provider-docs bucket, and creates claim in claims/{id}.
class ClaimListingView extends StatefulWidget {
  const ClaimListingView({super.key});

  static const route = '/vendor/claim-listing';

  @override
  State<ClaimListingView> createState() => _ClaimListingViewState();
}

class _ClaimListingViewState extends State<ClaimListingView> {
  final _searchController = TextEditingController();
  final _noteController = TextEditingController();
  final _repo = VendorRepository();
  final _picker = ImagePicker();

  List<Listing> _unclaimedListings = [];
  Listing? _selectedListing;
  File? _proofPhoto;
  bool _isLoading = false;
  bool _isSubmitting = false;
  String? _statusMessage;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _searchListings('');
  }

  @override
  void dispose() {
    _searchController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _searchListings(String query) async {
    setState(() => _isLoading = true);
    try {
      final results = await _repo.searchUnclaimedListings(query);
      if (!mounted) return;
      setState(() {
        _unclaimedListings = results;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pickProofPhoto() async {
    try {
      final picked = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1280,
        imageQuality: 70,
      );

      if (picked != null) {
        setState(() {
          _proofPhoto = File(picked.path);
          _errorMessage = null;
        });
      }
    } catch (e) {
      setState(() => _errorMessage = 'Failed to select image: $e');
    }
  }

  Future<void> _sendClaim() async {
    if (_selectedListing == null) {
      setState(() => _errorMessage = 'Please select a listing from the search results to claim.');
      return;
    }
    if (_proofPhoto == null) {
      setState(() => _errorMessage = 'Please upload a photo proof (business card, bill, or signboard).');
      return;
    }

    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    if (uid.isEmpty) {
      setState(() => _errorMessage = 'Please sign in to file an ownership claim.');
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      final claimId = DateTime.now().millisecondsSinceEpoch.toString();
      final bytes = await _proofPhoto!.readAsBytes();

      // Upload to private provider-docs bucket
      final evidencePath = await _repo.uploadClaimProof(
        uid: uid,
        claimId: claimId,
        bytes: bytes,
      );

      if (evidencePath == null) {
        throw Exception('Failed to upload proof photo.');
      }

      await _repo.submitClaim(
        listingId: _selectedListing!.id,
        claimantId: uid,
        note: _noteController.text.trim(),
        evidencePath: evidencePath,
      );

      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _statusMessage = 'Claim submitted! Our support team will verify your ownership within 24 hours.';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _errorMessage = 'Claim submission error: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: uiFeatureTheme(context, UiColors.amber),
      child: UiScaffold(
        title: 'Is this your place?',
        bottomButton: UiMainButton(
          label: 'Send claim',
          customAccent: UiColors.amber,
          isLoading: _isSubmitting,
          onPressed: _sendClaim,
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_statusMessage != null) ...[
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle_rounded, color: Color(0xFF2E7D32)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: uiText(_statusMessage!, size: 12.5, color: const Color(0xFF1B5E20)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              if (_errorMessage != null) ...[
                UiWarningBanner(text: _errorMessage!),
                const SizedBox(height: 14),
              ],

              // Search Box
              UiTextInput(
                label: 'Search listing name',
                hintText: 'e.g. Sharma Hardware',
                controller: _searchController,
                prefixIcon: const Icon(Icons.search_rounded, color: UiColors.muted),
                onChanged: _searchListings,
              ),
              const SizedBox(height: 14),

              uiText('Unclaimed listings nearby', size: 13.5, weight: FontWeight.w700),
              const SizedBox(height: 8),

              if (_isLoading)
                const Center(child: CircularProgressIndicator(strokeWidth: 2))
              else if (_unclaimedListings.isEmpty)
                const EmptyState(
                  title: 'No unclaimed listings found',
                  message: 'If your business is not listed yet, register a new listing.',
                  icon: Icons.store_outlined,
                )
              else
                Column(
                  children: [
                    for (final item in _unclaimedListings)
                      Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: _selectedListing?.id == item.id
                              ? UiColors.amber.withValues(alpha: 0.12)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: _selectedListing?.id == item.id ? UiColors.amber : UiColors.line,
                            width: _selectedListing?.id == item.id ? 1.6 : 1.0,
                          ),
                        ),
                        child: ListTile(
                          title: uiText(item.name, size: 14, weight: FontWeight.w700),
                          subtitle: uiText('${item.category} • ${item.address}', size: 11.5, color: UiColors.muted),
                          trailing: _selectedListing?.id == item.id
                              ? const Icon(Icons.check_circle_rounded, color: UiColors.amber)
                              : const Icon(Icons.radio_button_unchecked_rounded, color: UiColors.muted),
                          onTap: () => setState(() => _selectedListing = item),
                        ),
                      ),
                  ],
                ),
              const SizedBox(height: 16),

              uiText('Ownership proof document', size: 13.5, weight: FontWeight.w700),
              const SizedBox(height: 4),
              uiText('Upload a utility bill, business registration, or photo outside shop', size: 11.5, color: UiColors.muted),
              const SizedBox(height: 8),

              UiUploadCard(
                label: _proofPhoto != null ? 'Proof photo selected' : 'Upload proof photo',
                pickedFile: _proofPhoto,
                icon: Icons.verified_user_outlined,
                onTap: _pickProofPhoto,
              ),
              const SizedBox(height: 16),

              UiTextInput(
                label: 'Additional note (optional)',
                hintText: 'Any information to help identify your ownership',
                controller: _noteController,
                maxLines: 2,
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
