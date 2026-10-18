import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:localink/features/browse/views/map_view.dart';

void main() {
  testWidgets('MapView builds without throwing', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: MapView(),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byType(MapView), findsOneWidget);
  });

  test('PolylineLayer compiles and instantiates', () {
    final layer = PolylineLayer(
      polylines: [
        Polyline(
          points: const [LatLng(18.52, 73.85), LatLng(18.53, 73.86)],
          strokeWidth: 5.0,
          color: Colors.blue,
        ),
      ],
    );
    expect(layer.polylines.length, 1);
  });
}
