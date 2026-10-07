import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

class PickupMapPage extends StatefulWidget {
  final LatLng? initialPoint;
  const PickupMapPage({super.key, this.initialPoint});

  @override
  State<PickupMapPage> createState() => _PickupMapPageState();
}

class _PickupMapPageState extends State<PickupMapPage> {
  final _controller = MapController();
  LatLng? _point;
  bool _locating = false;
  String? _message;

  @override
  void initState() {
    super.initState();
    _point = widget.initialPoint;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _locate() async {
    setState(() { _locating = true; _message = null; });
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        throw Exception('Aktifkan GPS di pengaturan HP, lalu coba lagi.');
      }
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever) {
        throw Exception('Izin lokasi diblokir. Buka pengaturan aplikasi atau ketuk titik di peta.');
      }
      if (permission == LocationPermission.denied) {
        throw Exception('Izin lokasi belum diberikan. Kamu tetap bisa memilih titik di peta.');
      }
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 20),
        ),
      );
      if (!mounted) return;
      final point = LatLng(position.latitude, position.longitude);
      setState(() => _point = point);
      _controller.move(point, 17);
    } catch (error) {
      if (!mounted) return;
      setState(() => _message = error is Exception && error.toString().startsWith('Exception: ')
          ? error.toString().substring(11)
          : 'Lokasi belum tersedia. Coba lagi atau ketuk titik di peta.');
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Titik Penjemputan')),
    body: Column(children: [
      const Padding(
        padding: EdgeInsets.all(12),
        child: Text('Ketuk peta untuk memilih titik. Periksa posisi pin sebelum menyimpan.'),
      ),
      Expanded(child: FlutterMap(
        mapController: _controller,
        options: MapOptions(
          initialCenter: _point ?? const LatLng(3.5952, 98.6722),
          initialZoom: _point == null ? 12 : 16,
          maxZoom: 19,
          onTap: (_, point) => setState(() => _point = point),
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.bersihlaundry.app',
            maxNativeZoom: 19,
            tileProvider: _CachedMapTiles(),
          ),
          if (_point != null) MarkerLayer(markers: [
            Marker(point: _point!, width: 48, height: 48,
              child: const Icon(Icons.location_pin, color: Colors.red, size: 46)),
          ]),
          Align(alignment: Alignment.bottomRight, child: ColoredBox(
            color: Colors.white,
            child: TextButton(
              onPressed: () async {
                await launchUrl(Uri.parse('https://www.openstreetmap.org/copyright'),
                  mode: LaunchMode.externalApplication);
              },
              child: const Text('© OpenStreetMap contributors', style: TextStyle(fontSize: 11)),
            ),
          )),
        ],
      )),
      SafeArea(top: false, child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          if (_message != null) Text(_message!, style: const TextStyle(color: Colors.red)),
          if (_point != null) Text('${_point!.latitude.toStringAsFixed(6)}, ${_point!.longitude.toStringAsFixed(6)}'),
          TextButton.icon(
            onPressed: _locating ? null : _locate,
            icon: const Icon(Icons.my_location),
            label: Text(_locating ? 'Mencari lokasi…' : 'Gunakan lokasi saya'),
          ),
          SizedBox(width: double.infinity, child: ElevatedButton(
            onPressed: _point == null ? null : () => Navigator.pop(context, _point),
            child: const Text('Gunakan titik ini'),
          )),
        ]),
      )),
    ]),
  );
}

class _CachedMapTiles extends TileProvider {
  @override
  ImageProvider getImage(TileCoordinates coordinates, TileLayer options) {
    return CachedNetworkImageProvider(
      getTileUrl(coordinates, options),
      headers: const {'User-Agent': 'BersihLaundry/1.1 (com.bersihlaundry.app)'},
    );
  }
}
