import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

class Agents extends StatefulWidget {
  const Agents({super.key});

  @override
  State<Agents> createState() => _AgentsState();
}

class _AgentsState extends State<Agents> {
  final TextEditingController _searchController = TextEditingController();
  final MapController _mapController = MapController();
  double _currentZoom = 13.0;
  LatLng? _currentLocation;
  List<Map<String, dynamic>> postes = [];

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _listenToLocationChanges();
    _fetchPostes(); // Fetch postes on init
  }

  Future<void> _fetchPostes() async {
    try {
      print("Fetching postes from the server...");
      final response = await http.get(
        Uri.parse('http://192.168.43.148:81/projetSV/selectposte.php'),
      );

      if (response.statusCode == 200) {
        if (response.body.isNotEmpty) {
          print("Successfully fetched postes data.");
          print("Response body: ${response.body}");
          setState(() {
            postes =
                List<Map<String, dynamic>>.from(json.decode(response.body));
            print("Postes list updated: $postes");
          });
        } else {
          print("Response body is empty.");
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('La réponse du serveur est vide.')),
          );
        }
      } else {
        print("Failed to load postes with status code: ${response.statusCode}");
        throw Exception('Failed to load postes');
      }
    } catch (e) {
      print("Error while fetching postes: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur de chargement des postes: $e'),
        ),
      );
    }
  }

  Future<void> _getCurrentLocation() async {
    print("Getting current location...");
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _currentLocation = LatLng(position.latitude, position.longitude);
      print("Current location: $_currentLocation");
    });
    _mapController.move(_currentLocation!, _currentZoom);
  }

  void _listenToLocationChanges() {
    print("Listening to location changes...");
    Geolocator.getPositionStream(
            locationSettings: const LocationSettings(
                accuracy: LocationAccuracy.high, distanceFilter: 10))
        .listen((Position position) {
      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
        print("Location updated: $_currentLocation");
      });
      _mapController.move(_currentLocation!, _currentZoom);
    });
  }

  Future<void> _searchLocation(String query) async {
    final url = Uri.parse(
        'https://nominatim.openstreetmap.org/search?q=${Uri.encodeQueryComponent(query)},+Goma,+RDC&format=json&limit=1');
    print("Searching location: $query");
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        print("Search response: ${response.body}");
        final List results = json.decode(response.body);
        if (results.isNotEmpty) {
          final LatLng location = LatLng(
            double.parse(results[0]['lat']),
            double.parse(results[0]['lon']),
          );

          setState(() {
            _currentLocation = location;
            print("Search location found: $location");
          });
          Future.microtask(() {
            _mapController.move(location, _currentZoom);
          });
        } else {
          print("Location not found.");
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Lieu non trouvé.')),
          );
        }
      }
    } catch (error) {
      print("Error in search location: $error");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur de requête: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Postes disponibles',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              center: _currentLocation ?? LatLng(-4.4419, 15.2663),
              zoom: _currentZoom,
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                subdomains: const ['a', 'b', 'c'],
                userAgentPackageName: 'com.example.app',
              ),
              // Marqueurs pour les postes
              MarkerLayer(
                markers: postes.map((poste) {
                  print("Adding marker for poste: $poste");
                  return Marker(
                    point: LatLng(poste['latitude'], poste['longitude']),
                    builder: (context) => Container(
                      width: 20,
                      height: 20,
                      child: Column(
                        children: [
                          const Icon(
                            Icons.location_on,
                            color: Colors.blue,
                            size: 40,
                          ),
                          Text(
                            poste['nom'],
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              if (_currentLocation != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _currentLocation!,
                      builder: (context) => const Icon(
                        Icons.location_on,
                        color: Colors.red,
                        size: 40,
                      ),
                    ),
                  ],
                ),
            ],
          ),
          Positioned(
            top: 20,
            right: 20,
            child: Container(
              width: 350,
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Rechercher...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  suffixIcon: const Icon(
                    Icons.search,
                    size: 18,
                    color: Colors.black,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                onSubmitted: (value) {
                  if (value.isNotEmpty) {
                    _searchLocation(value);
                  }
                },
              ),
            ),
          ),
          Positioned(
            bottom: 20,
            right: 10,
            child: Column(
              children: [
                FloatingActionButton(
                  onPressed: () {
                    setState(() {
                      _currentZoom++;
                      Future.microtask(() {
                        _mapController.move(
                            _mapController.center, _currentZoom);
                      });
                    });
                  },
                  child: const Icon(Icons.zoom_in),
                ),
                const SizedBox(height: 10),
                FloatingActionButton(
                  onPressed: () {
                    setState(() {
                      _currentZoom--;
                      Future.microtask(() {
                        _mapController.move(
                            _mapController.center, _currentZoom);
                      });
                    });
                  },
                  child: const Icon(Icons.zoom_out),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
