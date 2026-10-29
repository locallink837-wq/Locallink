import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../core/widgets/ui_kit.dart';
import '../data/vendor_repository.dart';
import '../../../app/shells/vendor_shell.dart';

/// Screen 7.4: Product Types / Inventory Tags.
/// Reads product chips from Firestore config/shopProducts (field 'items') and executes final atomic write.
class ProductTypesView extends StatefulWidget {
  const ProductTypesView({super.key});

  static const route = '/vendor/product-types';

  @override
  State<ProductTypesView> createState() => _ProductTypesViewState();
}

class _ProductTypesViewState extends State<ProductTypesView> {
  final _repo = VendorRepository();
  List<String> _productsList = [];
  final Set<String> _selectedProducts = {};
  bool _isLoading = true;
  bool _isSubmitting = false;
  String? _errorMessage;
  bool _configMissing = false;

  @override
  void initState() {
    super.initState();
    _loadProductsConfig();
  }

  Future<void> _loadProductsConfig() async {
    try {
      final items = await _repo.fetchShopProductsConfig();
      if (!mounted) return;
      setState(() {
        if (items.isEmpty) {
          _configMissing = true;
          // Fallback tags if config document not populated yet
          _productsList = ['Pipes', 'Paint', 'Tools', 'Locks', 'Switches', 'Cables', 'Fittings', 'Hardware'];
        } else {
          _productsList = items;
        }
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _configMissing = true;
        _productsList = ['Pipes', 'Paint', 'Tools', 'Locks', 'Switches'];
        _isLoading = false;
      });
    }
  }

  Future<void> _onSubmit() async {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    if (uid.isEmpty) {
      setState(() => _errorMessage = 'Please sign in to complete registration.');
      return;
    }

    if (_selectedProducts.isEmpty) {
      setState(() => _errorMessage = 'Please select at least one product tag.');
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      final args = (ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?) ?? {};
      final listingId = args['listingId'] as String? ?? _repo.generateListingId();

      await _repo.submitShopRegistration(
        listingId: listingId,
        uid: uid,
        name: (args['name'] ?? 'Shop').toString(),
        category: (args['category'] ?? 'Hardware').toString(),
        phone: (args['phone'] ?? '').toString(),
        address: (args['address'] ?? '').toString(),
        latitude: (args['latitude'] ?? 18.5204) as double,
        longitude: (args['longitude'] ?? 73.8567) as double,
        open24x7: (args['open24x7'] ?? false) as bool,
        opensAt: (args['opensAt'] ?? '09:00').toString(),
        closesAt: (args['closesAt'] ?? '21:00').toString(),
        weeklyOff: List<int>.from(args['weeklyOff'] ?? [7]),
        products: _selectedProducts.toList(),
        photoUrl: args['photoUrl'] as String?,
      );

      if (!mounted) return;
      // Navigate directly to VendorShell
      Navigator.pushNamedAndRemoveUntil(
        context,
        VendorShell.route,
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _errorMessage = 'Registration submission error: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: uiFeatureTheme(context, UiColors.amber),
      child: UiScaffold(
        title: 'What do you sell',
        bottomButton: UiMainButton(
          label: 'Save and submit',
          customAccent: UiColors.amber,
          isLoading: _isSubmitting,
          onPressed: _onSubmit,
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

                    if (_configMissing) ...[
                      Container(
                        padding: const EdgeInsets.all(10),
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF3E0),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: uiText(
                          'Note: config/shopProducts document is missing in Firestore. Showing default suggested items.',
                          size: 11.5,
                          color: const Color(0xFFE65100),
                        ),
                      ),
                    ],

                    uiText('Select product categories and items you keep in stock', size: 13.5, weight: FontWeight.w700),
                    const SizedBox(height: 6),
                    uiText('Customers searching for these items will find your shop nearby', size: 12, color: UiColors.muted),
                    const SizedBox(height: 14),

                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final item in _productsList)
                          UiChip(
                            label: item,
                            customAccent: UiColors.amber,
                            isSelected: _selectedProducts.contains(item),
                            onTap: () {
                              setState(() {
                                if (_selectedProducts.contains(item)) {
                                  _selectedProducts.remove(item);
                                } else {
                                  _selectedProducts.add(item);
                                }
                              });
                            },
                          ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
      ),
    );
  }
}
