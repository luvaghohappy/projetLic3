import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class MyForm extends StatefulWidget {
  @override
  _MyFormState createState() => _MyFormState();
}

class _MyFormState extends State<MyForm> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController txtnom = TextEditingController();
  TextEditingController txtpostnom = TextEditingController();
  TextEditingController txtprenom = TextEditingController();
  TextEditingController txtdate_naiss = TextEditingController();
  TextEditingController txtAdresse = TextEditingController();
  TextEditingController txtnombre_enfant = TextEditingController();
  TextEditingController txtEtat_sanitaire = TextEditingController();
  TextEditingController txtalergie = TextEditingController();
  TextEditingController txttaille = TextEditingController();
  TextEditingController txtpoids = TextEditingController();
  TextEditingController txtnumero = TextEditingController();
  TextEditingController txtemail = TextEditingController();
  TextEditingController txtmotdepasse = TextEditingController();
  TextEditingController txtconfig = TextEditingController();

  File? _imageFile;
  final picker = ImagePicker();
  bool _obscureTextMotDePasse = true;
  bool _obscureTextConf = true;
  String? selectedsexe;
  String? selectedEtat;
  bool _isPasswordValid = true;
  bool _isPasswordMatch = true;

  Future<void> getImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _imageFile = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  Future<void> saveUserData(String key, String value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(key, value);
  }

  @override
  void initState() {
    super.initState();
  }

  Future<void> insertData() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez corriger les erreurs avant de soumettre.'),
        ),
      );
      return;
    }

    var request = http.MultipartRequest(
      'POST',
      Uri.parse("http://192.168.43.149:81/projetSV/victime.php"),
    );

    request.fields['nom'] = txtnom.text;
    request.fields['postnom'] = txtpostnom.text;
    request.fields['prenom'] = txtprenom.text;
    request.fields['sexe'] = selectedsexe ?? '';
    request.fields['Date_naissance'] = txtdate_naiss.text;
    request.fields['Adresse'] = txtAdresse.text;
    request.fields['Etat_civil'] = selectedEtat ?? '';
    if (selectedEtat == 'Marié(e)') {
      request.fields['nombre_enfant'] = txtnombre_enfant.text;
    }
    request.fields['Etat_sanitaire'] = txtEtat_sanitaire.text;
    request.fields['allergie'] = txtalergie.text;
    request.fields['Taille'] = txttaille.text;
    request.fields['Poids'] = txtpoids.text;
    request.fields['Numero'] = txtnumero.text;
    request.fields['email'] = txtemail.text;
    request.fields['mot_de_passe'] = txtmotdepasse.text;
    request.fields['conf_passe'] = txtconfig.text;

    if (_imageFile != null) {
      request.files.add(
        await http.MultipartFile.fromPath(
          'image',
          _imageFile!.path,
        ),
      );
    }

    final response = await request.send();

    if (response.statusCode == 200) {
      final responseBody = await response.stream.bytesToString();

      try {
        final responseJson = jsonDecode(responseBody);

        if (responseJson['status'] == 'success') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: const [
                  Icon(Icons.check, color: Colors.white),
                  SizedBox(width: 8),
                  Text('Enregistrement réussi avec succès'),
                ],
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 5),
              behavior: SnackBarBehavior.floating,
            ),
          );
          await saveUserData('nom', txtnom.text);
          await saveUserData('postnom', txtpostnom.text);
          await saveUserData('prenom', txtprenom.text);
          await saveUserData('sexe', selectedsexe ?? '');
          await saveUserData('Date_naissance', txtdate_naiss.text);
          await saveUserData('Adresse', txtAdresse.text);
          await saveUserData('Etat_civil', selectedEtat ?? '');
          await saveUserData('nombre_enfant', txtnombre_enfant.text);
          await saveUserData('Etat_sanitaire', txtEtat_sanitaire.text);
          await saveUserData('allergie', txtalergie.text);
          await saveUserData('Taille', txttaille.text);
          await saveUserData('Poids', txtpoids.text);
          await saveUserData('Numero', txtnumero.text);
          await saveUserData('email', txtemail.text);
          await saveUserData('mot_de_passe', txtmotdepasse.text);
          await saveUserData('image_path', responseJson['image_path']);

          // Effacer les champs après un enregistrement réussi
          _formKey.currentState!.reset();
          setState(() {
            _imageFile = null;
            txtnom.clear();
            txtpostnom.clear();
            txtprenom.clear();
            selectedsexe = null;
            txtdate_naiss.clear();
            txtAdresse.clear();
            selectedEtat = null;
            txtnombre_enfant.clear();
            txtEtat_sanitaire.clear();
            txtalergie.clear();
            txttaille.clear();
            txtpoids.clear();
            txtnumero.clear();
            txtemail.clear();
            txtmotdepasse.clear();
            txtconfig.clear();
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'Erreur lors de l\'enregistrement: ${responseJson['error']}'),
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur de décodage JSON: $responseBody'),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erreur lors de l\'enregistrement'),
        ),
      );
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      setState(() {
        txtdate_naiss.text = "${pickedDate.toLocal()}"
            .split(' ')[0]; // Format date as YYYY-MM-DD
      });
    }
  }

  void _validatePassword() {
    setState(() {
      if (txtmotdepasse.text.length < 8) {
        _isPasswordValid = false;
      } else {
        _isPasswordValid = true;
      }

      if (txtmotdepasse.text != txtconfig.text) {
        _isPasswordMatch = false;
      } else {
        _isPasswordMatch = true;
      }
    });
  }

  InputDecoration buildInputDecoration(String labelText, String hintText,
      [Widget? suffix]) {
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: const BorderSide(color: Colors.grey),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: const BorderSide(color: Colors.blue),
      ),
      suffixIcon: suffix,
      errorText: null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 20),
                ),
                const Padding(
                  padding: EdgeInsets.only(left: 20),
                  child: Text(
                    "FORMULAIRE D'ENREGISTREMENT",
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 10),
                const Padding(
                  padding: EdgeInsets.only(top: 10),
                ),
                GestureDetector(
                  onTap: getImage,
                  child: CircleAvatar(
                    backgroundColor: const Color.fromARGB(255, 192, 146, 9),
                    radius: 50,
                    backgroundImage:
                        _imageFile != null ? FileImage(_imageFile!) : null,
                    child: _imageFile == null
                        ? const Icon(
                            Icons.add_a_photo,
                            size: 20,
                            color: Colors.white,
                          )
                        : null,
                  ),
                ),
                const Text('Choisissez une photo de profil'),
                const Padding(
                  padding: EdgeInsets.only(top: 20),
                ),
                const Text("Veuillez remplir tous les champs avant d'inserer"),
                const Padding(
                  padding: EdgeInsets.only(top: 10),
                ),
                TextFormField(
                  controller: txtnom,
                  decoration: buildInputDecoration('Nom', 'Entrez votre nom'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer votre nom';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: txtpostnom,
                  decoration:
                      buildInputDecoration('Postnom', 'Entrez votre postnom'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer votre postnom';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: txtprenom,
                  decoration:
                      buildInputDecoration('Prénom', 'Entrez votre prénom'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer votre prénom';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: selectedsexe,
                  items: ['Masculin', 'Féminin']
                      .map((label) => DropdownMenuItem(
                            child: Text(label),
                            value: label,
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedsexe = value;
                    });
                  },
                  decoration:
                      buildInputDecoration('Sexe', 'Sélectionnez votre sexe'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez sélectionner votre sexe';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: txtdate_naiss,
                  decoration: buildInputDecoration(
                    'Date de naissance',
                    'Entrez votre date de naissance',
                    IconButton(
                      iconSize: 16,
                      onPressed: () => _selectDate(context),
                      icon: const Icon(Icons.calendar_today),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer votre date de naissance';
                    }
                    return null;
                  },
                  readOnly: true,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: txtAdresse,
                  decoration:
                      buildInputDecoration('Adresse', 'Entrez votre adresse'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer votre adresse';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: selectedEtat,
                  items: ['Célibataire', 'Marié(e)', 'Divorcé(e)', 'Veuf(ve)']
                      .map(
                        (label) => DropdownMenuItem(
                          child: Text(label),
                          value: label,
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedEtat = value;
                    });
                  },
                  decoration: buildInputDecoration(
                      'État civil', 'Sélectionnez votre état civil'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez sélectionner votre état civil';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                if (selectedEtat == 'Marié(e)')
                  TextFormField(
                    controller: txtnombre_enfant,
                    decoration: buildInputDecoration(
                        'Nombre d\'enfants', 'Entrez le nombre d\'enfants'),
                    validator: (value) {
                      if (selectedEtat == 'Marié(e)' &&
                          (value == null || value.isEmpty)) {
                        return 'Veuillez entrer le nombre d\'enfants';
                      }
                      return null;
                    },
                  ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: txtEtat_sanitaire,
                  decoration: buildInputDecoration(
                      'État sanitaire', 'Entrez votre état sanitaire'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer votre état sanitaire';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: txtalergie,
                  decoration: buildInputDecoration('Allergie',
                      'Entrez vos allergies (si aucun, mettre "aucun")'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer vos allergies';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: txttaille,
                  decoration:
                      buildInputDecoration('Taille', 'Entrez votre taille'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer votre taille';
                    } else {
                      // Convertir la taille en nombre et vérifier qu'elle ne dépasse pas 2.5
                      final taille = double.tryParse(value);
                      if (taille == null) {
                        return 'Veuillez entrer un nombre valide pour la taille';
                      } else if (taille > 2.5) {
                        return 'La taille ne doit pas dépasser 2.5';
                      }
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: txtpoids,
                  decoration:
                      buildInputDecoration('Poids', 'Entrez votre poids'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer votre poids';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: txtnumero,
                  decoration: buildInputDecoration('Numéro de téléphone',
                      'Entrez votre numéro de téléphone'),
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer votre numéro de téléphone';
                    } else if (!RegExp(r'^\d{1,15}$').hasMatch(value)) {
                      return 'Le numéro de téléphone doit contenir entre 1 et 15 chiffres';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  keyboardType: TextInputType.emailAddress,
                  controller: txtemail,
                  decoration:
                      buildInputDecoration('Email', 'Entrez votre email'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer votre email';
                    } else if (!RegExp(r'^[\w-]+@([\w-]+\.)+[\w-]{2,4}$')
                        .hasMatch(value)) {
                      return 'Veuillez entrer un email valide';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: txtmotdepasse,
                  obscureText: _obscureTextMotDePasse,
                  decoration: buildInputDecoration(
                    'Mot de passe',
                    'Entrez votre mot de passe',
                    IconButton(
                      icon: Icon(_obscureTextMotDePasse
                          ? Icons.visibility
                          : Icons.visibility_off),
                      onPressed: () {
                        setState(() {
                          _obscureTextMotDePasse = !_obscureTextMotDePasse;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer un mot de passe';
                    } else if (value.length < 8) {
                      return 'Le mot de passe doit comporter au moins 8 caractères';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    _validatePassword();
                  },
                ),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.only(top: 8.0),
                    child: Text(
                      'Le mot de passe doit comporter au moins 8 caractères',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: txtconfig,
                  obscureText: _obscureTextConf,
                  decoration: buildInputDecoration(
                    'Confirmer mot de passe',
                    'Confirmez votre mot de passe',
                    IconButton(
                      icon: Icon(
                        _isPasswordMatch ? Icons.check : Icons.close,
                        color: _isPasswordMatch ? Colors.green : Colors.red,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureTextConf = !_obscureTextConf;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez confirmer votre mot de passe';
                    } else if (value != txtmotdepasse.text) {
                      return 'Les mots de passe ne correspondent pas';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    _validatePassword();
                  },
                ),
                const Padding(
                  padding: EdgeInsets.only(top: 10),
                ),
                SizedBox(
                  height: 45,
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: insertData,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 187, 142, 8),
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
    );
  }
}
