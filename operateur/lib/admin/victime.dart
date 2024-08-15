import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:operateur/mespages/numero.dart';

class Utilisateurs extends StatefulWidget {
  const Utilisateurs({super.key});

  @override
  State<Utilisateurs> createState() => _UtilisateursState();
}

class _UtilisateursState extends State<Utilisateurs> {
  List<Map<String, dynamic>> items = [];
  List<Map<String, dynamic>> filteredItems = [];
  String searchQuery = '';

  Future<void> fetchData() async {
    try {
      final response = await http.get(
        Uri.parse("http://192.168.43.148:81/projetSV/selectvictime.php"),
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

  void _editUser(int id) {
    // Implémentez la logique de modification de l'utilisateur ici
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Modifier l\'utilisateur avec ID: $id')),
    );
  }

  void _deleteUser(int id) async {
    final response = await http.post(
      Uri.parse('http://192.168.43.148:81/projetSV/deletevictime.php'),
      body: json.encode({'id': id}),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      setState(() {
        filteredItems.removeWhere((item) => item['id'] == id);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Utilisateur supprimé avec succès')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Échec de la suppression de l\'utilisateur')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        leading: GestureDetector(
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => const Numero(),
            ));
          },
          child: SizedBox(
            width: 250,
            child: Container(
              height: 50,
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black),
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(15),
              ),
              alignment: Alignment.center,
              child: const Text(
                "Numéro d'urgences",
                style: TextStyle(color: Colors.black),
              ),
            ),
          ),
        ),
        title: const Text(
          'Utilisateurs de vie sauve',
          style: TextStyle(color: Colors.black),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(40.0),
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Align(
              alignment: Alignment.centerRight,
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
          ),
        ),
      ),
      body: filteredItems.isEmpty
          ? const Center(
              child: Text(
                'Aucun utilisateur trouvé',
                style: TextStyle(fontSize: 18),
              ),
            )
          : ListView.separated(
              itemCount: filteredItems.length,
              separatorBuilder: (context, index) => const Divider(
                color: Colors.grey,
                height: 1.0,
                thickness: 1.0,
              ),
              itemBuilder: (context, index) {
                final user = filteredItems[index];
                return ListTile(
                  contentPadding: const EdgeInsets.all(10),
                  leading: CircleAvatar(
                    radius: 17,
                    backgroundColor: Colors.blue,
                    backgroundImage: user['image_path'] != null
                        ? NetworkImage(
                            "http://192.168.43.148:81/projetSV/uploads/${user['image_path']}")
                        : null,
                    child: user['image_path'] == null
                        ? const Icon(Icons.image, size: 10, color: Colors.grey)
                        : null,
                  ),
                  title: Text(
                      '${user['nom']} ${user['postnom']} ${user['prenom']}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            '-Sexe: ${user['sexe']}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const Padding(
                            padding: EdgeInsets.only(left: 10),
                          ),
                          Text(
                            '-Date de naissance: ${user['Date_naissance']}',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Text(
                            '-Email: ${user['email']}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const Padding(
                            padding: EdgeInsets.only(left: 10),
                          ),
                          Text(
                            '-Adresse: ${user['Adresse']}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const Padding(
                            padding: EdgeInsets.only(left: 10),
                          ),
                          Text(
                            '-Numéro: ${user['Numero']}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Text(
                            '-État civil: ${user['Etat_civil']}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const Padding(
                            padding: EdgeInsets.only(left: 10),
                          ),
                          Text(
                            '-Nombre d\'enfants: ${user['nombre_enfant'] ?? 'N/A'}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Text(
                            '-État sanitaire: ${user['Etat_sanitaire']}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const Padding(
                            padding: EdgeInsets.only(left: 10),
                          ),
                          Text(
                            '-Allergie: ${user['allergie']}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const Padding(
                            padding: EdgeInsets.only(left: 10),
                          ),
                          Text(
                            '-Taille: ${user['Taille']}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const Padding(
                            padding: EdgeInsets.only(left: 10),
                          ),
                          Text(
                            '-Poids: ${user['Poids']}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                  trailing: const CircleAvatar(
                    radius: 15,
                    backgroundColor: Colors.green,
                    child: Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 10,
                    ),
                  ),
                );
              },
            ),
    );
  }
}
