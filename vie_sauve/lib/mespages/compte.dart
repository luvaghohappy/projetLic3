import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'login.dart';

class MonComptePage extends StatefulWidget {
  @override
  _MonComptePageState createState() => _MonComptePageState();
}

class _MonComptePageState extends State<MonComptePage> {
  String? nom,
      postnom,
      prenom,
      sexe,
      dateNaissance,
      adresse,
      etatCivil,
      nombreEnfant,
      etatSanitaire,
      allergie,
      taille,
      poids,
      numero,
      email,
      imagePath,
      userId;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      nom = prefs.getString('nom');
      postnom = prefs.getString('postnom');
      prenom = prefs.getString('prenom');
      sexe = prefs.getString('sexe');
      dateNaissance = prefs.getString('Date_naissance');
      adresse = prefs.getString('Adresse');
      etatCivil = prefs.getString('Etat_civil');
      nombreEnfant = prefs.getString('nombre_enfant');
      etatSanitaire = prefs.getString('Etat_sanitaire');
      allergie = prefs.getString('allergie');
      taille = prefs.getString('Taille');
      poids = prefs.getString('Poids');
      numero = prefs.getString('Numero');
      email = prefs.getString('email');
      imagePath = prefs.getString('image_path');
      userId = prefs.getString('Userid'); // Load the UserId
    });
  }

  Future<void> _updateUserInfo() async {
    if (userId == null) return;

    final response = await http.post(
      Uri.parse("http://192.168.43.149:81/projetSV/updateuser.php"),
      body: {
        'Userid': userId!,
        'nom': nom!,
        'postnom': postnom!,
        'prenom': prenom!,
        'sexe': sexe!,
        'Date_naissance': dateNaissance!,
        'Adresse': adresse!,
        'Etat_civil': etatCivil!,
        'nombre_enfant': nombreEnfant!,
        'Etat_sanitaire': etatSanitaire!,
        'allergie': allergie!,
        'Taille': taille!,
        'Poids': poids!,
        'Numero': numero!,
        'email': email!,
      },
    );

    final result = json.decode(response.body);
    if (result['status'] == 'success') {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('nom', nom!);
      await prefs.setString('postnom', postnom!);
      await prefs.setString('prenom', prenom!);
      await prefs.setString('sexe', sexe!);
      await prefs.setString('Date_naissance', dateNaissance!);
      await prefs.setString('Adresse', adresse!);
      await prefs.setString('Etat_civil', etatCivil!);
      await prefs.setString('nombre_enfant', nombreEnfant!);
      await prefs.setString('Etat_sanitaire', etatSanitaire!);
      await prefs.setString('allergie', allergie!);
      await prefs.setString('Taille', taille!);
      await prefs.setString('Poids', poids!);
      await prefs.setString('Numero', numero!);
      await prefs.setString('email', email!);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Informations mises à jour avec succès'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de la mise à jour : ${result['error']}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Clear SharedPreferences
    await prefs.clear();

    // Show success Snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Déconnexion réussie'),
        backgroundColor: Colors.green,
      ),
    );

    // Navigate to login page after logout
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => MyForm()),
    );
  }

  void _showEditDialog() {
    final TextEditingController nomController =
        TextEditingController(text: nom);
    final TextEditingController postnomController =
        TextEditingController(text: postnom);
    final TextEditingController prenomController =
        TextEditingController(text: prenom);
    final TextEditingController sexeController =
        TextEditingController(text: sexe);
    final TextEditingController dateNaissanceController =
        TextEditingController(text: dateNaissance);
    final TextEditingController adresseController =
        TextEditingController(text: adresse);
    final TextEditingController etatCivilController =
        TextEditingController(text: etatCivil);
    final TextEditingController nombreEnfantController =
        TextEditingController(text: nombreEnfant);
    final TextEditingController etatSanitaireController =
        TextEditingController(text: etatSanitaire);
    final TextEditingController allergieController =
        TextEditingController(text: allergie);
    final TextEditingController tailleController =
        TextEditingController(text: taille);
    final TextEditingController poidsController =
        TextEditingController(text: poids);
    final TextEditingController numeroController =
        TextEditingController(text: numero);
    final TextEditingController emailController =
        TextEditingController(text: email);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Modifier les informations'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTextField('Nom', nomController),
                _buildTextField('Postnom', postnomController),
                _buildTextField('Prénom', prenomController),
                _buildTextField('Sexe', sexeController),
                _buildTextField('Date de Naissance', dateNaissanceController),
                _buildTextField('Adresse', adresseController),
                _buildTextField('État Civil', etatCivilController),
                _buildTextField('Nombre d\'enfants', nombreEnfantController),
                _buildTextField('État Sanitaire', etatSanitaireController),
                _buildTextField('Allergies', allergieController),
                _buildTextField('Taille', tailleController),
                _buildTextField('Poids', poidsController),
                _buildTextField('Numéro', numeroController),
                _buildTextField('Email', emailController),
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
                setState(() {
                  nom = nomController.text;
                  postnom = postnomController.text;
                  prenom = prenomController.text;
                  sexe = sexeController.text;
                  dateNaissance = dateNaissanceController.text;
                  adresse = adresseController.text;
                  etatCivil = etatCivilController.text;
                  nombreEnfant = nombreEnfantController.text;
                  etatSanitaire = etatSanitaireController.text;
                  allergie = allergieController.text;
                  taille = tailleController.text;
                  poids = poidsController.text;
                  numero = numeroController.text;
                  email = emailController.text;
                });
                Navigator.of(context).pop();
                _updateUserInfo();
              },
              child: const Text('Enregistrer'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  Future<void> deleteUserAccount(String id) async {
    final response = await http.post(
      Uri.parse("http://192.168.43.149:81/projetSV/deleteuser.php"),
      body: {'Userid': id},
    );

    if (response.statusCode == 200) {
      final result = json.decode(response.body);
      if (result['status'] == 'success') {
        // Clear SharedPreferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.clear();

        // Show success Snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Compte supprimé avec succès'),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate to login page after account deletion
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => MyForm()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la suppression : ${result['error']}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erreur lors de la suppression'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Supprimer le compte'),
          content: const Text(
              'Êtes-vous sûr de vouloir supprimer votre compte ? Cette action est irréversible.'),
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
                if (userId != null) {
                  deleteUserAccount(userId!);
                }
              },
              child: const Text('Supprimer'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = imagePath != null
        ? "http://192.168.43.149:81/projetSV/$imagePath"
        : null;
    print('Image URL: $imageUrl');

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 25),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 170),
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => MyForm(),
                  ));
                },
                child: Container(
                  height: 30,
                  width: 120,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black26),
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Center(
                    child: Text('Créer un compte'),
                  ),
                ),
              ),
            ),
            Container(
              alignment: Alignment.topCenter,
              padding: const EdgeInsets.only(top: 30),
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 70,
                    backgroundColor: Colors.blue,
                    backgroundImage:
                        imageUrl != null ? NetworkImage(imageUrl) : null,
                    child: imageUrl == null
                        ? const Icon(Icons.person, size: 20, color: Colors.grey)
                        : null,
                  ),
                  Positioned(
                    bottom: -1,
                    right: -1,
                    child: Container(
                      width: 35,
                      height: 35,
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors
                              .white, // Optionnel: ajoute une bordure blanche
                          width: 2, // Optionnel: largeur de la bordure
                        ),
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        size: 20,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(top: 20),
            ),
            _buildInfoCard(Icons.person, Colors.blue, 'Nom:', nom),
            _buildInfoCard(
                Icons.person_outline, Colors.green, 'Postnom:', postnom),
            _buildInfoCard(Icons.person_pin, Colors.purple, 'Prénom:', prenom),
            _buildInfoCard(Icons.wc, Colors.orange, 'Sexe:', sexe),
            _buildInfoCard(
                Icons.cake, Colors.pink, 'Date de Naissance:', dateNaissance),
            _buildInfoCard(Icons.home, Colors.red, 'Adresse:', adresse),
            _buildInfoCard(Icons.group, Colors.teal, 'État Civil:', etatCivil),
            _buildInfoCard(Icons.child_care, Colors.brown, 'Nombre d\'enfants:',
                nombreEnfant),
            _buildInfoCard(Icons.local_hospital, Colors.indigo,
                'État Sanitaire:', etatSanitaire),
            _buildInfoCard(Icons.healing, Colors.amber, 'Allergies:', allergie),
            _buildInfoCard(Icons.straighten, Colors.cyan, 'Taille:', taille),
            _buildInfoCard(Icons.line_weight, Colors.lime, 'Poids:', poids),
            _buildInfoCard(Icons.phone, Colors.deepPurple, 'Numéro:', numero),
            _buildInfoCard(Icons.email, Colors.deepOrange, 'Email:', email),
            const Padding(
              padding: EdgeInsets.only(top: 20),
            ),
            Text(
              "Bonjour, ${prenom}! Merci d'utiliser VIE-SAUVE. Assurez-vous que toutes vos informations sont à jour pour bénéficier pleinement de nos services.",
              style: GoogleFonts.abel(),
            ),
            const Padding(
              padding: EdgeInsets.only(top: 20),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 170),
              child: GestureDetector(
                onTap: _showEditDialog,
                child: Container(
                  height: 40,
                  width: 150,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black26),
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      'Modifier Compte',
                      style: GoogleFonts.poppins(color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(top: 20),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 170),
              child: GestureDetector(
                onTap: _logout,
                child: Container(
                  height: 40,
                  width: 150,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black26),
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      'Se Déconnecter',
                      style: GoogleFonts.poppins(color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(top: 20),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 170),
              child: GestureDetector(
                onTap: _showDeleteDialog,
                child: Container(
                  height: 40,
                  width: 150,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black26),
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      'Supprimer Compte',
                      style: GoogleFonts.poppins(color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(top: 20),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(
      IconData icon, Color iconColor, String label, String? value) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Icon(icon, color: iconColor),
            const SizedBox(width: 8.0),
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16.0,
              ),
            ),
            const SizedBox(width: 8.0),
            Expanded(
              child: Text(
                value ?? 'N/A',
                style: const TextStyle(fontSize: 16.0),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
