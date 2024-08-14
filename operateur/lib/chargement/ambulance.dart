import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_map/flutter_map.dart';
import 'package:operateur/admin/login.dart';
import 'package:operateur/menu.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:audioplayers/audioplayers.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import '../admin/poste.dart';
import '../mespages/poste.dart';
import '../utilisateur.dart';
import 'dart:async';

class Ambulances extends StatefulWidget {
  const Ambulances({Key? key}) : super(key: key);

  @override
  State<Ambulances> createState() => _AmbulancesState();
}

class _AmbulancesState extends State<Ambulances> {
  Map<int, bool> successStatus = {};
  List<Map<String, dynamic>> items = [];
  List<Map<String, dynamic>> filteredItems = [];
  int? recordCount;
  AudioPlayer audioPlayer = AudioPlayer();
  Timer? _timer; // Declare the timer

  @override
  void initState() {
    super.initState();
    _loadCheckboxState();
    fetchData();
    fetchRecordCount();

    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      fetchData();
      fetchRecordCount();
    });
  }

  @override
  void dispose() {
    _timer?.cancel(); // Cancel the timer when the widget is disposed
    super.dispose();
  }

  Future<void> fetchData() async {
    try {
      final response = await http.get(
        Uri.parse("http://192.168.43.149:81/projetSV/ambulance.php"),
      );
      if (response.statusCode == 200) {
        final List<Map<String, dynamic>> newItems =
            List<Map<String, dynamic>>.from(json.decode(response.body))
                .reversed
                .toList();

        setState(() {
          items = newItems;
          filteredItems = items;
          _initializeStatus();
        });
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      print('Error fetching data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to load items'),
        ),
      );
    }
  }

  Future<void> fetchRecordCount() async {
    try {
      final response = await http.get(
        Uri.parse(
            "http://192.168.43.149:81/projetSV/recordstate.php?table_names=ambulance&services=ambulance"),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data != null && data['record_count'] != null) {
          int newRecordCount = data['record_count'];

          if (recordCount != null && newRecordCount > recordCount!) {
            playNotificationSound(); // Jouer la sirène si nouveau enregistrement détecté
          }

          setState(() {
            recordCount = newRecordCount;
          });
        } else {
          print("Record count not found in response");
          print("Response body: ${response.body}");
        }
      } else {
        throw Exception('Failed to load record count');
      }
    } catch (e) {
      print('Error fetching record count: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to load record count'),
        ),
      );
    }
  }

  void playNotificationSound() {
    final player = AudioPlayer();
    const assetPath = 'assets/sirene.mp3';

    player.setSource(AssetSource(assetPath));
    player.play(AssetSource(assetPath));
  }

  void _initializeStatus() {
    setState(() {
      successStatus = Map.fromIterable(
        List.generate(items.length, (index) => index),
        key: (item) => item,
        value: (item) => successStatus[item] ?? false,
      );
    });
  }

  Future<void> _saveCheckboxState() async {
    final prefs = await SharedPreferences.getInstance();
    for (int i = 0; i < items.length; i++) {
      await prefs.setBool('success_$i', successStatus[i] ?? false);
    }
  }

  Future<void> _loadCheckboxState() async {
    final prefs = await SharedPreferences.getInstance();
    for (int i = 0; i < items.length; i++) {
      successStatus[i] = prefs.getBool('success_$i') ?? false;
    }
    setState(
        () {}); // Mettre à jour l'interface utilisateur après le chargement
  }

  Future<void> _openGoogleMaps(double lat, double lon) async {
    try {
      Position position = await _determinePosition();
      final currentLat = position.latitude;
      final currentLon = position.longitude;

      final url =
          'https://www.google.com/maps/dir/?api=1&origin=$currentLat,$currentLon&destination=$lat,$lon';
      if (await canLaunch(url)) {
        await launch(url);
      } else {
        throw 'Could not open Google Maps';
      }
    } catch (e) {
      print('Error getting current location: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not get current location'),
        ),
      );
    }
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    return await Geolocator.getCurrentPosition();
  }

  void _moveToLocation(String location, int index) {
    if (location.isNotEmpty) {
      try {
        final coordinates =
            location.replaceAll('POINT(', '').replaceAll(')', '').split(' ');
        final lat = double.parse(coordinates[1]);
        final lon = double.parse(coordinates[0]);

        _openGoogleMaps(lat, lon);

        setState(() {
          successStatus[index] = true;
        });
        _saveCheckboxState(); // Sauvegarder l'état après le changement
      } catch (e) {
        print('Error parsing location: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invalid location format'),
          ),
        );
      }
    }
  }

  void _filterItems(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredItems = items;
      } else {
        filteredItems = items.where((user) {
          final name = '${user['nom']} ${user['postnom']} ${user['prenom']}';
          return name.toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Center(
          child: Text('Signales des détresses Ambulance'),
        ),
        leading: PopupMenuButton<String>(
          onSelected: (String result) {
            print('Selected: $result');
            switch (result) {
              case 'Utilisateurs':
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const Utilisateurs(),
                  ),
                );
                break;

              case 'Postes':
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const Chargerposte(),
                  ),
                );
                break;
            }
          },
          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
            const PopupMenuItem<String>(
              value: 'Utilisateurs',
              child: Text('Utilisateurs'),
            ),
            const PopupMenuItem<String>(
              value: 'Postes',
              child: Text('Postes'),
            ),
          ],
          icon: const Icon(Icons.menu),
        ),
        actions: [
          Row(
            children: [
              Stack(
                children: [
                  IconButton(
                    color: Colors.white,
                    onPressed: () async {
                      setState(() {
                        recordCount =
                            null; // Réinitialiser le compteur d'enregistrements
                      });
                      await fetchRecordCount(); // Recharger les nouvelles données
                    },
                    icon: const Icon(Icons.notifications_on_outlined),
                  ),
                  if (recordCount != null && recordCount! > 0)
                    Positioned(
                      right: 4,
                      top: 4,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 10,
                          minHeight: 6,
                        ),
                        child: Text(
                          '+$recordCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.only(left: 10),
          ),
          IconButton(
            color: Colors.white,
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => const Menu(),
              ));
            },
            icon: const Icon(Icons.logout_outlined),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(18.0),
              child: Align(
                alignment: Alignment.centerRight,
                child: SizedBox(
                  width: 300,
                  child: TextField(
                    onChanged: _filterItems,
                    decoration: InputDecoration(
                      hintText: 'Rechercher...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      prefixIcon: const Icon(Icons.search),
                    ),
                  ),
                ),
              ),
            ),
            DataTable(
              columns: const [
                DataColumn(label: Text('#')),
                DataColumn(label: Text('Nom')),
                DataColumn(label: Text('Postnom')),
                DataColumn(label: Text('Prenom')),
                DataColumn(label: Text('Sexe')),
                DataColumn(label: Text('Locations')),
                DataColumn(label: Text('Date_Heure')),
                DataColumn(label: Text('Status')),
              ],
              rows: List<DataRow>.generate(
                filteredItems.length,
                (int index) {
                  final item = filteredItems[index];
                  return DataRow(
                    cells: [
                      DataCell(Text((index + 1).toString())),
                      DataCell(Text(item['nom'] ?? '')),
                      DataCell(Text(item['postnom'] ?? '')),
                      DataCell(Text(item['prenom'] ?? '')),
                      DataCell(Text(item['sexe'] ?? '')),
                      DataCell(
                        InkWell(
                          onTap: () {
                            _moveToLocation(item['locations'], index);
                          },
                          child: Text(
                            item['locations'] ?? '',
                            style: const TextStyle(
                              color: Colors.blue,
                            ),
                          ),
                        ),
                      ),
                      DataCell(Text(item['created_at'] ?? '')),
                      DataCell(
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: successStatus[index] ?? false
                                ? Colors.green
                                : Colors.red,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
