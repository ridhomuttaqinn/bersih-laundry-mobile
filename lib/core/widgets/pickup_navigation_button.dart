import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Opens only a Google Maps destination generated from the stored address.
class PickupNavigationButton extends StatelessWidget {
  final String address;
  const PickupNavigationButton({super.key, required this.address});

  @override
  Widget build(BuildContext context) => OutlinedButton.icon(
    icon: const Icon(Icons.directions),
    label: const Text('Buka navigasi penjemputan'),
    onPressed: () async {
      final match = RegExp(r'https://www\.google\.com/maps/search/\?api=1&query=(-?\d+(?:\.\d+)?),(-?\d+(?:\.\d+)?)').firstMatch(address);
      final destination = match == null ? address.trim() : '${match.group(1)},${match.group(2)}';
      final uri = Uri.https('www.google.com', '/maps/dir/', {
        'api': '1', 'destination': destination,
      });
      try {
        final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
        if (!opened) throw Exception('No map app');
      } catch (_) {
        if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Peta belum bisa dibuka. Pastikan browser atau Google Maps tersedia.')),
        );
      }
    },
  );
}
