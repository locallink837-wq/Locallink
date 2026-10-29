import 'package:flutter/widgets.dart';

import 'views/register_shop_view.dart';
import 'views/shop_location_view.dart';
import 'views/shop_hours_photo_view.dart';
import 'views/product_types_view.dart';
import 'views/register_place_view.dart';
import 'views/place_location_view.dart';
import 'views/claim_listing_view.dart';
import 'views/vendor_dashboard_view.dart';
import 'views/edit_listing_view.dart';
import 'views/verification_status_view.dart';

/// All routes of this feature. Only the owner (C) edits this file.
final Map<String, WidgetBuilder> vendorRoutes = {
  RegisterShopView.route: (_) => const RegisterShopView(),
  ShopLocationView.route: (_) => const ShopLocationView(),
  ShopHoursPhotoView.route: (_) => const ShopHoursPhotoView(),
  ProductTypesView.route: (_) => const ProductTypesView(),
  RegisterPlaceView.route: (_) => const RegisterPlaceView(),
  PlaceLocationView.route: (_) => const PlaceLocationView(),
  ClaimListingView.route: (_) => const ClaimListingView(),
  VendorDashboardView.route: (_) => const VendorDashboardView(),
  '/vendor/dashboard': (_) => const VendorDashboardView(),
  EditListingView.route: (_) => const EditListingView(),
  VerificationStatusView.route: (_) => const VerificationStatusView(),
};
