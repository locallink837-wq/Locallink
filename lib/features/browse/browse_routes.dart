import 'package:flutter/widgets.dart';

import 'views/guest_home_view.dart';
import 'views/home_view.dart';
import 'views/browse_services_view.dart';
import 'views/browse_places_view.dart';
import 'views/browse_shops_view.dart';
import 'views/listing_list_view.dart';
import 'views/search_results_view.dart';
import 'views/shop_detail_view.dart';
import 'views/place_detail_view.dart';
import 'views/provider_detail_view.dart';
import 'views/map_view.dart';
import 'views/reviews_list_view.dart';
import 'views/report_wrong_info_view.dart';
import 'views/saved_places_view.dart';

/// All routes of this feature. Only the owner (A) edits this file.
final Map<String, WidgetBuilder> browseRoutes = {
  GuestHomeView.route: (_) => const GuestHomeView(),
  HomeView.route: (_) => const HomeView(),
  BrowseServicesView.route: (_) => const BrowseServicesView(),
  BrowsePlacesView.route: (_) => const BrowsePlacesView(),
  BrowseShopsView.route: (_) => const BrowseShopsView(),
  ListingListView.route: (_) => const ListingListView(),
  SearchResultsView.route: (_) => const SearchResultsView(),
  ShopDetailView.route: (_) => const ShopDetailView(),
  PlaceDetailView.route: (_) => const PlaceDetailView(),
  ProviderDetailView.route: (_) => const ProviderDetailView(),
  MapView.route: (_) => const MapView(),
  ReviewsListView.route: (_) => const ReviewsListView(),
  ReportWrongInfoView.route: (_) => const ReportWrongInfoView(),
  SavedPlacesView.route: (_) => const SavedPlacesView(),
};
