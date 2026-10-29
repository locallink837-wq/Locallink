import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/widgets/ui_kit.dart';
import '../data/provider_repository.dart';

/// Screen: Documents Status (Tagged NEW in UI/UX E_F).
/// Displays verification status of uploaded documents and allows re-uploading new proofs to provider-docs bucket.
class DocumentsStatusView extends StatefulWidget {
  const DocumentsStatusView({super.key});

  static const route = '/provider/documents-status';

  @override
  State<DocumentsStatusView> createState() => _DocumentsStatusViewState();
}

class _DocumentsStatusViewState extends State<DocumentsStatusView> {
  final _repo = ProviderRepository();
  final _picker = ImagePicker();
  bool _isUploading = false;
  String? _statusMessage;

  Future<void> _uploadNewDocument() async {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    if (uid.isEmpty) return;

    try {
      final picked = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1280,
        imageQuality: 70,
      );

      if (picked != null) {
        setState(() {
          _isUploading = true;
          _statusMessage = null;
        });

        final bytes = await picked.readAsBytes();
        final path = await _repo.uploadDocument(
          uid: uid,
          bytes: bytes,
          docType: 'additional-proof',
        );

        if (!mounted) return;
        setState(() {
          _isUploading = false;
          _statusMessage = path != null
              ? 'New document uploaded successfully for review!'
              : 'Failed to upload document. Please retry.';
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isUploading = false;
        _statusMessage = 'Upload error: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';

    return Theme(
      data: uiFeatureTheme(context, UiColors.indigo),
      child: UiScaffold(
        title: 'Documents',
        bottomButton: UiGhostButton(
          label: 'Upload new document',
          icon: Icons.upload_file_rounded,
          onPressed: _isUploading ? null : _uploadNewDocument,
        ),
        body: uid.isEmpty
            ? const Center(child: Text('Please log in'))
            : StreamBuilder<Map<String, dynamic>?>(
                stream: _repo.streamProvider(uid),
                builder: (context, snapshot) {
                  final provData = snapshot.data ?? {};
                  final vStatus = provData['verificationStatus']?.toString().toUpperCase() ?? 'PENDING';

                  return SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_isUploading) ...[
                          const LinearProgressIndicator(),
                          const SizedBox(height: 14),
                        ],

                        if (_statusMessage != null) ...[
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8F5E9),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: uiText(_statusMessage!, size: 12.5, color: const Color(0xFF2E7D32)),
                          ),
                          const SizedBox(height: 14),
                        ],

                        // Document Items List Tiles
                        UiListTile(
                          title: 'Government ID Proof',
                          subtitle: 'Aadhaar / Voter ID',
                          icon: Icons.badge_outlined,
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8F5E9),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'Approved',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF2E7D32),
                              ),
                            ),
                          ),
                        ),
                        UiListTile(
                          title: 'Verification Selfie',
                          subtitle: 'Live facial capture',
                          icon: Icons.face_rounded,
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8F5E9),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'Approved',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF2E7D32),
                              ),
                            ),
                          ),
                        ),
                        UiListTile(
                          title: 'Trade License / Certificate',
                          subtitle: 'Optional skill certification',
                          icon: Icons.verified_outlined,
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: vStatus == 'APPROVED' ? const Color(0xFFE8F5E9) : const Color(0xFFFFF3E0),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              vStatus == 'APPROVED' ? 'Approved' : 'Pending',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: vStatus == 'APPROVED' ? const Color(0xFF2E7D32) : const Color(0xFFE65100),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Security notice tag
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: UiColors.line),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.security_rounded, size: 20, color: UiColors.indigo),
                              const SizedBox(width: 10),
                              Expanded(
                                child: uiText(
                                  'All documents are encrypted and accessible exclusively by compliance administrators.',
                                  size: 11.5,
                                  color: UiColors.muted,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }
}
