import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:operateur/admin/firstpage.dart';
import '../home.dart';

class LoginAdmin extends StatefulWidget {
  const LoginAdmin({super.key});

  @override
  State<LoginAdmin> createState() => _LoginAdminState();
}

class _LoginAdminState extends State<LoginAdmin> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  int _attempts = 0; // Variable pour suivre les tentatives
  bool _fieldsDisabled =
      false; // Variable pour savoir si les champs sont désactivés

  // Fonction pour gérer la connexion
  Future<void> loginUser() async {
    if (_fieldsDisabled) return; // Ne rien faire si les champs sont désactivés

    final url = 'http://192.168.43.149:81/projetSV/selectAdmin.php';
    final response = await http.post(
      Uri.parse(url),
      body: {
        'email': emailController.text,
        'passwords': passwordController.text,
      },
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      if (responseData['success']) {
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => const Myfirstpage(),
        ));
      } else {
        _attempts++;
        if (_attempts >= 3) {
          setState(() {
            _fieldsDisabled = true; // Désactiver les champs après 3 tentatives
          });
          _showErrorDialog(context,
              'Vous avez fait plusieurs tentatives infructueuses. Accès refusé.');
        } else {
          _showErrorDialog(
              context, 'Identifiants incorrects. Veuillez réessayer.');
        }
      }
    } else {
      _showErrorDialog(
          context, 'Erreur de connexion. Veuillez réessayer plus tard.');
    }
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Erreur de connexion'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Center(
        child: Container(
          height: h * 0.7,
          width: 750,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Card(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Connexion Administrateur',
                      style: Theme.of(context).textTheme.headline5,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(18.0),
                      child: TextField(
                        controller: emailController,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          border: OutlineInputBorder(),
                          errorText: _attempts >= 3
                              ? 'Tentatives multiples échouées'
                              : null,
                        ),
                        keyboardType: TextInputType.emailAddress,
                        enabled: !_fieldsDisabled,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(18.0),
                      child: TextField(
                        controller: passwordController,
                        decoration: InputDecoration(
                          labelText: 'Mot de passe',
                          border: OutlineInputBorder(),
                          errorText: _attempts >= 3
                              ? 'Tentatives multiples échouées'
                              : null,
                        ),
                        obscureText: true,
                        enabled: !_fieldsDisabled,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () {
                            // Action pour Fingerprint
                          },
                          child: const Card(
                            elevation: 4,
                            child: SizedBox(
                              width: 100,
                              height: 100,
                              child: Center(
                                child: Icon(
                                  Icons.fingerprint,
                                  size: 50,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.only(left: 20),
                        ),
                        GestureDetector(
                          onTap: () {
                            // Action pour Face ID
                          },
                          child: const Card(
                            elevation: 4,
                            child: SizedBox(
                              width: 100,
                              height: 100,
                              child: Center(
                                child: Icon(
                                  Icons.face,
                                  size: 50,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 45,
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: loginUser,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color.fromARGB(255, 187, 142, 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text('Soumettre'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
