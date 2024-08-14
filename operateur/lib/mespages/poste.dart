import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class Chargerposte extends StatefulWidget {
  const Chargerposte({super.key});

  @override
  State<Chargerposte> createState() => _ChargerposteState();
}

class _ChargerposteState extends State<Chargerposte> {
  List<Map<String, dynamic>> items = [];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      final response = await http.get(
        Uri.parse("http://192.168.43.149:81/projetSV/selectposte.php"),
      );

      if (response.statusCode == 200) {
        setState(() {
          items = List<Map<String, dynamic>>.from(json.decode(response.body));
        });
      } else {
        throw Exception('Failed to load items');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to load items'),
        ),
      );
    }
  }

  Future<void> _launchGoogleMaps(String address) async {
    final encodedAddress = Uri.encodeComponent(address);
    final url =
        'https://www.google.com/maps/search/?api=1&query=$encodedAddress';

    if (await canLaunch(url)) {
      await launch(url);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Impossible d\'ouvrir Google Maps'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Postes Disponibles'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: DataTable(
            columns: const [
              DataColumn(label: Text('Nom du Poste')),
              DataColumn(label: Text('Adresse')),
              DataColumn(label: Text('Action')),
            ],
            rows: items.map((item) {
              return DataRow(
                cells: [
                  DataCell(Text(item['nom_post'])),
                  DataCell(
                    GestureDetector(
                      onTap: () => _launchGoogleMaps(item['adresse']),
                      child: Text(
                        item['adresse'],
                        style:
                            const TextStyle(color: Colors.blue, fontSize: 17),
                      ),
                    ),
                  ),
                  DataCell(
                    IconButton(
                      iconSize: 20,
                      color: Colors.red,
                      icon: const Icon(Icons.location_pin),
                      onPressed: () {
                        _launchGoogleMaps(item['adresse']);
                      },
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
