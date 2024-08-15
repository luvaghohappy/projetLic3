import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  String? nom;
  String? postnom;
  String? prenom;
  String? imagePath;
  bool isDarkMode = false;
  List<Map<String, String>> numbers = [];

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadTheme();
  }

  Future<void> _saveNumbersToSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('stored_numbers', json.encode(numbers));
  }

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      nom = prefs.getString('nom');
      postnom = prefs.getString('postnom');
      prenom = prefs.getString('prenom');
      imagePath = prefs.getString('image_path');

      String? storedNumbers = prefs.getString('stored_numbers');
      if (storedNumbers != null) {
        List<dynamic> decodedNumbers = json.decode(storedNumbers);
        numbers = decodedNumbers.map((item) {
          // Convert each dynamic item to Map<String, String>
          return Map<String, String>.from(item as Map<String, dynamic>);
        }).toList();
      }
    });
  }

  Future<void> _loadTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isDarkMode = prefs.getBool('isDarkMode') ?? false;
    });
  }

  Future<void> _saveTheme(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isDarkMode', value);
  }

  void _toggleTheme() {
    setState(() {
      isDarkMode = !isDarkMode;
      _saveTheme(isDarkMode);
    });
  }

  void _showAddNumberDialog() {
    TextEditingController _numero1Controller = TextEditingController();
    TextEditingController _numero2Controller = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Ajouter numéros de proches'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _numero1Controller,
                decoration: const InputDecoration(labelText: 'Numéro 1'),
                keyboardType: TextInputType.phone,
              ),
              TextField(
                controller: _numero2Controller,
                decoration: const InputDecoration(labelText: 'Numéro 2'),
                keyboardType: TextInputType.phone,
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('Annuler'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Enregistrer'),
              onPressed: () {
                if (_numero1Controller.text.isNotEmpty &&
                    _numero2Controller.text.isNotEmpty) {
                  // Check if the numbers already exist
                  bool numberExists = numbers.any((item) =>
                      item['numero1'] == _numero1Controller.text &&
                      item['numero2'] == _numero2Controller.text);

                  if (!numberExists) {
                    setState(() {
                      numbers.add({
                        'numero1': _numero1Controller.text,
                        'numero2': _numero2Controller.text,
                      });
                    });
                    Navigator.of(context).pop();
                    _addPhoneNumbers(
                      numero1: _numero1Controller.text,
                      numero2: _numero2Controller.text,
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Ce numéro existe déjà.'),
                      ),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Veuillez remplir les deux numéros.'),
                    ),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _addPhoneNumbers({
    required String numero1,
    required String numero2,
  }) async {
    try {
      final response = await http.post(
        Uri.parse("http://192.168.43.148:81/projetSV/insertnumber.php"),
        body: {
          'nom': nom,
          'postnom': postnom,
          'prenom': prenom,
          'numero1': numero1,
          'numero2': numero2,
        },
      );

      final responseData = json.decode(response.body);
      if (responseData['status'] == 'success') {
        // Add numbers to the list and save to SharedPreferences
        setState(() {
          numbers.add({'numero1': numero1, 'numero2': numero2});
          _saveNumbersToSharedPreferences();
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Numéros ajoutés avec succès'),
          ),
        );
      } else {
        throw Exception(responseData['message']);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de l\'ajout des numéros: $e'),
        ),
      );
    }
  }

  Future<void> _deleteAccount() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Compte supprimé avec succès'),
      ),
    );
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    setState(() {
      numbers.clear();
    });
    Navigator.of(context).pop();
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Supprimer le compte'),
          content:
              const Text('Êtes-vous sûr de vouloir supprimer votre compte ?'),
          actions: [
            TextButton(
              child: const Text('Annuler'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Supprimer'),
              onPressed: () {
                _deleteAccount();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = imagePath != null
        ? "http://192.168.43.148:81/projetSV/$imagePath"
        : null;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: ListView(
          children: [
            Row(
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 20),
                ),
                CircleAvatar(
                  radius: 22,
                  backgroundImage:
                      imageUrl != null ? NetworkImage(imageUrl) : null,
                  backgroundColor: Colors.grey,
                  child: imageUrl == null
                      ? const Icon(Icons.person, size: 20)
                      : null,
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${nom ?? ''} ${prenom ?? ''} ${postnom ?? ''}',
                      style: const TextStyle(
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.only(top: 40),
            ),
            const ListTile(
              leading: Icon(
                Icons.settings,
                size: 25,
                color: Colors.black,
              ),
              title: Text(
                'Paramètres',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(
                Icons.phone,
                color: Colors.green,
              ),
              title: const Text('Ajouter numéros d\'urgence'),
              onTap: _showAddNumberDialog,
            ),
            // Afficher les numéros après le texte
            if (numbers.isNotEmpty)
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: numbers.length,
                itemBuilder: (context, index) {
                  final item = numbers[index];
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.call, size: 12),
                          title: Text(
                            item['numero1'] ?? 'N/A',
                            style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                color: Colors.green,
                                iconSize: 20,
                                icon: const Icon(Icons.edit),
                                onPressed: () {
                                  // Handle edit action
                                },
                              ),
                              const SizedBox(width: 10),
                              IconButton(
                                color: Colors.red,
                                iconSize: 20,
                                icon: const Icon(Icons.delete),
                                onPressed: () {
                                  // Handle delete action
                                },
                              ),
                            ],
                          ),
                        ),
                        ListTile(
                          leading: const Icon(Icons.call, size: 12),
                          title: Text(
                            item['numero2'] ?? 'N/A',
                            style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                color: Colors.green,
                                iconSize: 20,
                                icon: const Icon(Icons.edit),
                                onPressed: () {
                                  // Handle edit action
                                },
                              ),
                              const SizedBox(width: 10),
                              IconButton(
                                color: Colors.red,
                                iconSize: 20,
                                icon: const Icon(Icons.delete),
                                onPressed: () {
                                  // Handle delete action
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),

            ListTile(
              leading: const Icon(
                Icons.security,
                color: Colors.blue,
              ),
              title: const Text('Confidentialité'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(
                Icons.policy,
                color: Colors.yellow,
              ),
              title: const Text('Politique de l\'application'),
              onTap: () {
                // Code pour afficher la politique de l'application
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.delete_forever,
                color: Colors.red,
              ),
              title: const Text('Supprimer le compte'),
              onTap: _showDeleteAccountDialog,
            ),
            const SizedBox(height: 20),
            const Text(
              'Autres paramètres',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SwitchListTile(
              title: const Text('Mode sombre'),
              value: isDarkMode,
              onChanged: (value) {
                _toggleTheme();
              },
              secondary: const Icon(Icons.dark_mode),
            ),
          ],
        ),
      ),
    );
  }
}
