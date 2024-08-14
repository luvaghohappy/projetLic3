import 'dart:ui';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'admin/firstpage.dart';
import 'chargement/ambulance.dart';
import 'chargement/police.dart';
import 'chargement/pompier.dart';
import 'package:google_fonts/google_fonts.dart';
import 'home.dart';

class Menu extends StatefulWidget {
  const Menu({Key? key}) : super(key: key);

  @override
  State<Menu> createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  bool inLoginProcess = false;
  bool _obscureText = true;
  bool isAdminMode = false; // Ajout pour gérer le mode admin

  double _sigmaX = 5; // from 0-10
  double _sigmaY = 5; // from 0-10
  double _opacity = 0.2;

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  int _attempts = 0;
  bool _fieldsDisabled = false;

  Future<void> loginUser() async {
    if (_fieldsDisabled) return;

    final url = isAdminMode
        ? 'http://192.168.43.149:81/projetSV/selectAdmin.php'
        : 'http://192.168.43.149:81/projetSV/selectUser.php';

    final response = await http.post(
      Uri.parse(url),
      body: {
        'email': emailController.text,
        'passwords': passwordController.text,
      },
    );

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      if (responseData['success']) {
        emailController.clear();
        passwordController.clear();
        if (isAdminMode) {
          Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (context) => const Myfirstpage(),
          ));
        } else {
          String service = responseData['service'];
          switch (service) {
            case 'pompier':
              Navigator.of(context).pushReplacement(MaterialPageRoute(
                builder: (context) => const Pompier(),
              ));
              break;
            case 'police':
              Navigator.of(context).pushReplacement(MaterialPageRoute(
                builder: (context) => const Polices(),
              ));
              break;
            case 'ambulance':
              Navigator.of(context).pushReplacement(MaterialPageRoute(
                builder: (context) => const Ambulances(),
              ));
              break;
            default:
              _showErrorDialog(context, 'Service inconnu.');
              break;
          }
        }
      } else {
        _attempts++;
        if (_attempts >= 3) {
          setState(() {
            _fieldsDisabled = true;
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
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                "assets/photo.png",
                fit: BoxFit.cover,
                color: Colors.black.withOpacity(0.5),
                colorBlendMode: BlendMode.darken,
              ),
            ),
            Center(
              child: ClipRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: _sigmaX, sigmaY: _sigmaY),
                  child: Container(
                    height: 400,
                    padding: const EdgeInsets.all(20.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      // color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    width: MediaQuery.of(context).size.width * 0.5,
                    child: Row(
                      children: [
                        // Image de login à gauche
                        Padding(
                          padding: const EdgeInsets.only(right: 20.0),
                          child: Image.asset(
                            'log.jpg',
                            width: 300,
                            height: 320,
                          ),
                        ),
                        Expanded(
                          child: Column(
                            children: [
                              const Padding(
                                padding: EdgeInsets.only(top: 20),
                              ),
                              Text(
                                'WELCOME ...',
                                style: GoogleFonts.abel(
                                    fontSize: 25, fontWeight: FontWeight.bold),
                              ),
                              const Padding(
                                padding: EdgeInsets.only(top: 10),
                              ),
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Opérateur d'urgence",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                        fontSize: 17),
                                  ),
                                  if (isAdminMode) ...[
                                    const Text(
                                      "Mode Admin",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                          fontSize: 17),
                                    ),
                                    const Padding(
                                      padding: EdgeInsets.only(top: 20),
                                    ),
                                    _buildTextField(
                                      controller: emailController,
                                      label: 'Email Admin',
                                      hint: 'Votre email',
                                    ),
                                    _buildTextField(
                                      controller: passwordController,
                                      label: 'Mot de passe Admin',
                                      hint: 'Votre mot de passe',
                                      obscureText: _obscureText,
                                      onSuffixIconPressed: () {
                                        setState(() {
                                          _obscureText = !_obscureText;
                                        });
                                      },
                                    ),
                                    _buildLoginButton(),
                                    _buildSwitchModeButton(),
                                  ] else ...[
                                    _buildTextField(
                                      controller: emailController,
                                      label: 'Email',
                                      hint: 'Votre email',
                                    ),
                                    _buildTextField(
                                      controller: passwordController,
                                      label: 'Mot de passe',
                                      hint: 'Votre mot de passe',
                                      obscureText: _obscureText,
                                      onSuffixIconPressed: () {
                                        setState(() {
                                          _obscureText = !_obscureText;
                                        });
                                      },
                                    ),
                                    _buildLoginButton(),
                                    _buildSwitchModeButton(),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    bool obscureText = false,
    void Function()? onSuffixIconPressed,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: TextField(
        controller: controller,
        cursorColor: Colors.black,
        obscureText: obscureText,
        decoration: InputDecoration(
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey.shade800),
          ),
          label: Text(
            label,
            style: const TextStyle(color: Colors.black),
          ),
          hintText: hint,
          suffixIcon: obscureText
              ? IconButton(
                  icon: Icon(
                    obscureText ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: onSuffixIconPressed,
                )
              : null,
        ),
        enabled: !_fieldsDisabled,
      ),
    );
  }

  Widget _buildLoginButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: GestureDetector(
        onTap: loginUser,
        child: Container(
          height: 45,
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 43, 130, 201),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Center(
            child: Text('Se Connecter', style: TextStyle(color: Colors.white)),
          ),
        ),
      ),
    );
  }

  Widget _buildSwitchModeButton() {
    return TextButton(
      onPressed: () {
        setState(() {
          isAdminMode = !isAdminMode;
        });
      },
      child: Center(
        child: Text(
          isAdminMode
              ? "Se connecter en tant qu'opérateur"
              : "Se connecter en tant qu'admin",
          style: const TextStyle(color: Colors.blue),
        ),
      ),
    );
  }
}
