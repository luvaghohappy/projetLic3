import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Postes extends StatefulWidget {
  const Postes({super.key});

  @override
  State<Postes> createState() => _PostesState();
}

class _PostesState extends State<Postes> {
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

  Future<void> _insertAddress(String nomPoste, String adresse) async {
    if (nomPoste.isEmpty || adresse.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez entrer le nom du poste et l\'adresse.'),
        ),
      );
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('http://192.168.43.149:81/projetSV/poste.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'nom': nomPoste,
          'adresse': adresse,
        }),
      );

      if (response.statusCode == 200) {
        var responseData = jsonDecode(response.body);
        if (responseData['success']) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  Text('Poste ajouté avec succès, ID: ${responseData['id']}'),
            ),
          );
          fetchData(); // Recharger les données après ajout
        } else {
          throw Exception(responseData['message']);
        }
      } else {
        throw Exception('Erreur réseau');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e')),
      );
    }
  }

  void _showAddPostDialog() {
    final TextEditingController nomPosteController = TextEditingController();
    final TextEditingController adresseController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ajouter un Poste'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nomPosteController,
              decoration: const InputDecoration(labelText: 'Nom du Poste'),
            ),
            TextField(
              controller: adresseController,
              decoration: const InputDecoration(labelText: 'Adresse'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _insertAddress(nomPosteController.text, adresseController.text);
            },
            child: const Text('Ajouter'),
          ),
        ],
      ),
    );
  }

  Future<void> deleteData(String id) async {
    if (id.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('ID utilisateur invalide'),
        ),
      );
      return;
    }

    try {
      final response = await http.post(
        Uri.parse("http://192.168.43.149:81/projetSV/deleteposte.php"),
        body: {'id': id},
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        if (result['status'] == 'success') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Suppression réussie'),
            ),
          );
          fetchData();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  Text('Erreur lors de la suppression : ${result['message']}'),
            ),
          );
        }
      } else {
        throw Exception('Erreur lors de la suppression');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de la suppression: $e'),
        ),
      );
    }
  }

  Future<void> _confirmDelete(String id) async {
    if (id.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('ID utilisateur invalide'),
        ),
      );
      return;
    }

    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmation de suppression'),
          content: const Text(
            'Êtes-vous sûr de vouloir supprimer cet enregistrement ?',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Supprimer'),
            ),
          ],
        );
      },
    );

    if (shouldDelete == true) {
      await deleteData(id);
    }
  }

  TextEditingController txtnompost = TextEditingController();
  TextEditingController txtadresse = TextEditingController();

  Future<void> _showEditDialog(Map<String, dynamic> item) async {
    // Initialiser les contrôleurs avec les valeurs de l'élément
    txtnompost.text = item['nom_post'] ?? '';
    txtadresse.text = item['adresse'] ?? '';

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Modifier Poste'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: txtnompost,
                  decoration: const InputDecoration(labelText: 'Nom Poste'),
                ),
                TextField(
                  controller: txtadresse,
                  decoration: const InputDecoration(labelText: 'Adresse'),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                updateData(item['id'].toString());
              },
              child: const Text('Modifier'),
            ),
          ],
        );
      },
    );
  }

  Future<void> updateData(String id) async {
    final nomposte = txtnompost.text;
    final adresse = txtadresse.text;

    try {
      final response = await http.post(
        Uri.parse("http://192.168.43.149:81/projetSV/updateposte.php"),
        body: {
          'nom_post': nomposte,
          'adresse': adresse,
          'id': id,
        },
      );

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        if (result['success']) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Données mises à jour avec succès'),
            ),
          );
          fetchData(); // Recharger les données après mise à jour
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  Text('Erreur lors de la mise à jour : ${result['message']}'),
            ),
          );
        }
      } else {
        throw Exception('Erreur lors de la mise à jour');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de la mise à jour: $e'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Postes'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index]; 
                  return ListTile(
                    title: Text(item['nom_post']),
                    subtitle: Text('Adresse: ${item['adresse']}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        IconButton(
                          iconSize: 16,
                          icon: const Icon(Icons.edit),
                          onPressed: () =>
                              _showEditDialog(item), 
                        ),
                        IconButton(
                          iconSize: 16,
                          color: Colors.red,
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            _confirmDelete(item['id'].toString());
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddPostDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
