import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'mespages/numero.dart';

class Utilisateurs extends StatefulWidget {
  const Utilisateurs({super.key});

  @override
  State<Utilisateurs> createState() => _UtilisateursState();
}

class _UtilisateursState extends State<Utilisateurs> {
  List<Map<String, dynamic>> items = [];
  List<Map<String, dynamic>> filteredItems = [];
  String searchQuery = '';

  final ScrollController _horizontalScrollController = ScrollController();
  final ScrollController _verticalScrollController = ScrollController();

  Future<void> fetchData() async {
    try {
      final response = await http.get(
        Uri.parse("http://192.168.43.149:81/projetSV/selectvictime.php"),
      );

      if (response.statusCode == 200) {
        setState(() {
          items = List<Map<String, dynamic>>.from(json.decode(response.body));
          filteredItems = items;
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

  void _filterItems(String query) {
    setState(() {
      searchQuery = query;
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
  void initState() {
    super.initState();
    fetchData();
  }

  @override
  void dispose() {
    _horizontalScrollController.dispose();
    _verticalScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Utilisateurs de vie sauve',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Stack(
        children: [
          Positioned(
            top: 10,
            right: 10,
            child: SizedBox(
              width: 300,
              child: TextField(
                onChanged: _filterItems,
                decoration: InputDecoration(
                  hintText: 'Rechercher un utilisateur...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: const BorderSide(color: Colors.white),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  prefixIcon: const Icon(Icons.search),
                ),
              ),
            ),
          ),
          Positioned.fill(
            top: 80,
            child: Scrollbar(
              controller: _horizontalScrollController,
              thumbVisibility: true,
              thickness: 12.0,
              radius: const Radius.circular(10),
              trackVisibility: true,
              child: SingleChildScrollView(
                controller: _horizontalScrollController,
                scrollDirection: Axis.horizontal,
                child: Scrollbar(
                  controller: _verticalScrollController,
                  thumbVisibility: true,
                  thickness: 12.0,
                  radius: const Radius.circular(10),
                  trackVisibility: true,
                  child: SingleChildScrollView(
                    controller: _verticalScrollController,
                    scrollDirection: Axis.vertical,
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('#')),
                        DataColumn(label: Text('Nom')),
                        DataColumn(label: Text('Postnom')),
                        DataColumn(label: Text('Prénom')),
                        DataColumn(label: Text('Sexe')),
                        DataColumn(label: Text('Date de naissance')),
                        DataColumn(label: Text('Email')),
                        DataColumn(label: Text('Adresse')),
                        DataColumn(label: Text('Numéro')),
                        DataColumn(label: Text('État civil')),
                        DataColumn(label: Text('Nombre d\'enfants')),
                        DataColumn(label: Text('État sanitaire')),
                        DataColumn(label: Text('Allergie')),
                        DataColumn(label: Text('Taille')),
                        DataColumn(label: Text('Poids')),
                        DataColumn(label: Text('Image')),
                      ],
                      rows: List<DataRow>.generate(filteredItems.length,
                          (int index) {
                        final user = filteredItems[index];
                        return DataRow(
                          cells: [
                            DataCell(Text((index + 1).toString())),
                            DataCell(Text(user['nom'] ?? '')),
                            DataCell(Text(user['postnom'] ?? '')),
                            DataCell(Text(user['prenom'] ?? '')),
                            DataCell(Text(user['sexe'] ?? '')),
                            DataCell(Text(user['Date_naissance'] ?? '')),
                            DataCell(Text(user['email'] ?? '')),
                            DataCell(Text(user['Adresse'] ?? '')),
                            DataCell(Text(user['Numero'] ?? '')),
                            DataCell(Text(user['Etat_civil'] ?? '')),
                            DataCell(
                                Text(user['nombre_enfant']?.toString() ?? '')),
                            DataCell(Text(user['Etat_sanitaire'] ?? '')),
                            DataCell(Text(user['allergie'] ?? '')),
                            DataCell(Text(user['Taille'] ?? '')),
                            DataCell(Text(user['Poids'] ?? '')),
                            DataCell(
                              user['image_path'] != null
                                  ? Image.network(
                                      "http://192.168.43.149:81/projetSV/uploads/${user['image_path']}",
                                      width: 50,
                                      height: 50,
                                      errorBuilder: (BuildContext context,
                                          Object error,
                                          StackTrace? stackTrace) {
                                        return const Icon(Icons.error,
                                            size:
                                                50); // Placeholder en cas d'erreur
                                      },
                                    )
                                  : const Icon(Icons.image, size: 20),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => const Numero(),
          ));
        },
        child: const Icon(Icons.call),
      ),
    );
  }
}
