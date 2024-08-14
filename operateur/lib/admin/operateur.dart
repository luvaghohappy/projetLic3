import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:html' as html;
import 'dart:typed_data';
import 'package:http/http.dart' as http;

class Users2 extends StatefulWidget {
  const Users2({super.key});

  @override
  State<Users2> createState() => _Users2State();
}

class _Users2State extends State<Users2> {
  TextEditingController txtnom = TextEditingController();
  TextEditingController txtpostnom = TextEditingController();
  TextEditingController txtprenom = TextEditingController();
  TextEditingController txtemail = TextEditingController();
  TextEditingController txtpassword = TextEditingController();
  TextEditingController txtrole = TextEditingController();
  TextEditingController txtservice = TextEditingController();
  Uint8List? _selectedFileBytes;

  Future<void> _getImage() async {
    final html.FileUploadInputElement input = html.FileUploadInputElement();
    input.accept = 'image/*';
    input.click();

    input.onChange.listen((event) {
      final file = input.files!.first;
      final reader = html.FileReader();
      reader.readAsArrayBuffer(file);

      reader.onLoadEnd.listen((e) {
        setState(() {
          _selectedFileBytes = reader.result as Uint8List;
        });
      });
    });
  }

  Future<void> insertData() async {
    if (_selectedFileBytes != null) {
      try {
        print('Starting data insertion...');

        var request = http.MultipartRequest(
          'POST',
          Uri.parse("http://192.168.43.149:81/projetSV/insertuser.php"),
        );
        request.fields['nom'] = txtnom.text;
        request.fields['postnom'] = txtpostnom.text;
        request.fields['prenom'] = txtprenom.text;
        request.fields['email'] = txtemail.text;
        request.fields['passwords'] = txtpassword.text;
        request.fields['roles'] = txtrole.text;
        request.fields['services'] = txtservice.text; // Service

        var image = _selectedFileBytes != null
            ? http.MultipartFile.fromBytes(
                'profil',
                _selectedFileBytes!,
                filename: 'image.jpg',
              )
            : null;

        if (image != null) {
          request.files.add(image);
        }

        var response = await request.send();

        print('Response status: ${response.statusCode}');
        print('Response reason: ${response.reasonPhrase}');

        if (response.statusCode == 200) {
          print('Data inserted successfully');

          _selectedFileBytes = null;
          txtnom.clear();
          txtpostnom.clear();
          txtprenom.clear();
          txtemail.clear();
          txtpassword.clear();
          txtrole.clear();
          txtservice.clear();

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Enregistrement réussi'),
            ),
          );
          fetchData(); // Charger les données après l'insertion
        } else {
          throw Exception('Erreur lors de l\'enregistrement');
        }
      } catch (e) {
        print('Error during insertion: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de l\'enregistrement: $e'),
          ),
        );
      }
    } else {
      print('No image selected');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez choisir une image'),
        ),
      );
    }
  }

  List<Map<String, dynamic>> items = [];

  Future<void> fetchData() async {
    try {
      final response = await http.get(
        Uri.parse("http://192.168.43.149:81/projetSV/chargeruser.php"),
      );

      setState(() {
        items = List<Map<String, dynamic>>.from(json.decode(response.body));
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Échec du chargement des données'),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    fetchData(); // Load initial data when the app starts
  }

  String obscurePassword(String password) {
    if (password.length <= 4) return password;
    return '${password.substring(0, 2)}...${password.substring(password.length - 2)}';
  }

  Future<void> showInsertDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: const Text('Ajouter Formation'),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 80,
                      width: 120,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                        border: Border.all(color: Colors.grey),
                      ),
                      child: _selectedFileBytes != null
                          ? Image.memory(_selectedFileBytes!)
                          : IconButton(
                              onPressed: () async {
                                final html.FileUploadInputElement input =
                                    html.FileUploadInputElement();
                                input.accept = 'image/*';
                                input.click();

                                input.onChange.listen((event) {
                                  final file = input.files!.first;
                                  final reader = html.FileReader();
                                  reader.readAsArrayBuffer(file);

                                  reader.onLoadEnd.listen((e) {
                                    setState(() {
                                      _selectedFileBytes =
                                          reader.result as Uint8List;
                                    });
                                  });
                                });
                              },
                              icon: const Icon(Icons.file_upload),
                            ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: TextField(
                        controller: txtnom,
                        cursorColor: Colors.black,
                        decoration: const InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.blue),
                          ),
                          labelText: 'Nom',
                          labelStyle: TextStyle(color: Colors.black),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: TextField(
                        controller: txtpostnom,
                        cursorColor: Colors.black,
                        decoration: const InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.blue),
                          ),
                          labelText: 'Postnom',
                          labelStyle: TextStyle(color: Colors.black),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: TextField(
                        controller: txtprenom,
                        cursorColor: Colors.black,
                        decoration: const InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.blue),
                          ),
                          labelText: 'Prenom',
                          labelStyle: TextStyle(color: Colors.black),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: TextField(
                        controller: txtemail,
                        cursorColor: Colors.black,
                        decoration: const InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.blue),
                          ),
                          labelText: 'Email',
                          labelStyle: TextStyle(color: Colors.black),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: TextField(
                        controller: txtpassword,
                        cursorColor: Colors.black,
                        decoration: const InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.blue),
                          ),
                          labelText: 'Password',
                          labelStyle: TextStyle(color: Colors.black),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: TextField(
                        controller: txtrole,
                        cursorColor: Colors.black,
                        decoration: const InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.blue),
                          ),
                          labelText: 'Role',
                          labelStyle: TextStyle(color: Colors.black),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: TextField(
                        controller: txtservice,
                        cursorColor: Colors.black,
                        decoration: const InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.blue),
                          ),
                          labelText: 'Service',
                          labelStyle: TextStyle(color: Colors.black),
                        ),
                      ),
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
                  onPressed: insertData,
                  child: const Text('Enregistrer'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _confirmDelete(String? operatorId) async {
    if (operatorId == null || operatorId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('ID opérateur invalide'),
        ),
      );
      print('OperatorId est nul ou vide');
      return;
    }

    print('OperatorId avant confirmation: $operatorId');

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
      print('Suppression confirmée pour OperatorId: $operatorId');
      await deleteOperator(operatorId);
      await fetchData(); // Fetch data after deletion
    } else {
      print('Suppression annulée');
    }
  }

  Future<void> deleteOperator(String operatorId) async {
    try {
      print(
          'Envoi de la demande de suppression pour l\'opérateur ID: $operatorId');
      final response = await http.post(
        Uri.parse("http://192.168.43.148:81/projetSV/deleteop.php"),
        body: {'id': operatorId},
      );

      print('Statut de la réponse: ${response.statusCode}');
      print('Corps de la réponse: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        print('Réponse JSON: $jsonResponse');

        if (jsonResponse['status'] == 'success') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Opérateur supprimé avec succès'),
            ),
          );
          await fetchData(); // Re-fetch data after successful deletion
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Échec de la suppression de l\'opérateur'),
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Échec de la communication avec le serveur'),
          ),
        );
      }
    } catch (e) {
      print('Erreur lors de la suppression de l\'opérateur: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erreur lors de la suppression'),
        ),
      );
    }
  }

  Future<void> _showEditDialog(Map<String, dynamic> item) async {
    txtnom.text = item['nom'] ?? '';
    txtpostnom.text = item['postnom'] ?? '';
    txtprenom.text = item['prenom'] ?? '';
    txtemail.text = item['email'] ?? '';
    txtpassword.text = item['passwords'] ?? '';
    txtrole.text = item['roles'] ?? '';
    txtservice.text = item['services'] ?? '';

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Modifier Utilisateur'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: txtnom,
                  decoration: const InputDecoration(labelText: 'Nom'),
                ),
                TextField(
                  controller: txtpostnom,
                  decoration: const InputDecoration(labelText: 'Postnom'),
                ),
                TextField(
                  controller: txtprenom,
                  decoration: const InputDecoration(labelText: 'Prenom'),
                ),
                TextField(
                  controller: txtemail,
                  decoration: const InputDecoration(labelText: 'Email'),
                ),
                TextField(
                  controller: txtpassword,
                  decoration: const InputDecoration(labelText: 'Mot de passe'),
                ),
                TextField(
                  controller: txtrole,
                  decoration: const InputDecoration(labelText: 'Rôles'),
                ),
                TextField(
                  controller: txtservice,
                  decoration: const InputDecoration(labelText: 'Services'),
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
                updateData(item['userId'].toString());
              },
              child: const Text('Modifier'),
            ),
          ],
        );
      },
    );
  }

  Future<void> updateData(String id) async {
    final nom = txtnom.text;
    final postnom = txtpostnom.text;
    final prenom = txtprenom.text;
    final email = txtemail.text;
    final passwords = txtpassword.text;
    final roles = txtrole.text;
    final services = txtservice.text;

    try {
      final response = await http.post(
        Uri.parse("http://192.168.43.148:81/projetSV/updateop.php"),
        body: {
          'nom': nom,
          'postnom': postnom,
          'prenom': prenom,
          'email': email,
          'passwords': passwords,
          'roles': roles,
          'services': services,
          'userId': id,
        },
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Mise à jour réussie'),
          ),
        );
        // Actualiser les données après la mise à jour
        fetchData();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erreur lors de la mise à jour'),
          ),
        );
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
        backgroundColor: Colors.blue,
        centerTitle: true,
        title: const Text('Agents Operateurs'),
      ),
      body: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Padding(
              padding: const EdgeInsets.all(18.0),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.black12,
                  ), // Bordure noire
                ),
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('Nom')),
                    DataColumn(label: Text('Postnom')),
                    DataColumn(label: Text('Prenom')),
                    DataColumn(label: Text('Email')),
                    DataColumn(label: Text('Password')),
                    DataColumn(label: Text('Role')),
                    DataColumn(label: Text('Service')),
                    DataColumn(label: Text('Actions')),
                  ],
                  rows: items.map((item) {
                    return DataRow(
                      cells: [
                        DataCell(Text(item['nom'] ?? '')),
                        DataCell(Text(item['postnom'] ?? '')),
                        DataCell(Text(item['prenom'] ?? '')),
                        DataCell(Text(item['email'] ?? '')),
                        DataCell(Text(obscurePassword(item['passwords']))),
                        DataCell(Text(item['roles'] ?? '')),
                        DataCell(Text(item['services'] ?? '')),
                        DataCell(
                          Row(
                            children: [
                              IconButton(
                                iconSize: 16,
                                color: Colors.green,
                                icon: const Icon(Icons.edit),
                                onPressed: () {
                                  _showEditDialog(item);
                                },
                              ),
                              IconButton(
                                iconSize: 16,
                                color: Colors.red,
                                icon: const Icon(Icons.delete),
                                onPressed: () {
                                  _confirmDelete(item['id'].toString());
                                },
                              )
                            ],
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showInsertDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}
