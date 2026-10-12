import 'package:flutter/material.dart';

import '../models/listing.dart';

class ListingCard extends StatelessWidget {
  final Listing listing;
  final VoidCallback? onTap;
  const ListingCard({super.key, required this.listing, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(listing.name),
        subtitle: Text(listing.category),
        trailing: listing.verified ? const Icon(Icons.verified) : null,
        onTap: onTap,
      ),
    );
  }
}
