import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final MapController _mapController = MapController();
  final List<Map<String, dynamic>> _friends = [
    {'name': 'Jean', 'position': LatLng(48.8566, 2.3522), 'avatar': 'J'},
    {'name': 'Marie', 'position': LatLng(48.8584, 2.2945), 'avatar': 'M'},
    {'name': 'Pierre', 'position': LatLng(48.8534, 2.3488), 'avatar': 'P'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: LatLng(
                48.8566,
                2.3522,
              ), // Changé de center à initialCenter
              initialZoom: 13.0, // Changé de zoom à initialZoom
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                subdomains: ['a', 'b', 'c'],
              ),
              MarkerLayer(
                markers: [
                  for (final friend in _friends)
                    Marker(
                      point: friend['position'],
                      width: 60,
                      height: 60,
                      child: GestureDetector(
                        onTap: () => _showFriendInfo(friend),
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [Colors.yellow[600]!, Colors.red[600]!],
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(2),
                            child: CircleAvatar(
                              backgroundColor: Colors.black,
                              child: Text(
                                friend['avatar'],
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
          Positioned(
            top: 40,
            left: 16,
            right: 16,
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey[900],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.search, color: Colors.white),
                        SizedBox(width: 8),
                        Text(
                          'Rechercher',
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: Colors.grey[900],
                  child: const Icon(Icons.settings, color: Colors.white),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 20,
            right: 20,
            child: FloatingActionButton(
              backgroundColor: Colors.yellow[600],
              onPressed:
                  () => _mapController.move(LatLng(48.8566, 2.3522), 13.0),
              child: const Icon(Icons.my_location, color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  void _showFriendInfo(Map<String, dynamic> friend) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: Colors.yellow[600],
                child: Text(
                  friend['avatar'],
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                friend['name'],
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'En ligne il y a 15min',
                style: TextStyle(color: Colors.grey[400]),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.yellow[600],
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text('Envoyer un message'),
              ),
            ],
          ),
        );
      },
    );
  }
}
