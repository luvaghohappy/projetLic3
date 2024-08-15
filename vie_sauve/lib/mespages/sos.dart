import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'dart:convert';
import '../live/operateur.dart';

class SOS extends StatefulWidget {
  const SOS({super.key});

  @override
  State<SOS> createState() => _SOSState();
}

class _SOSState extends State<SOS> {
  String? nom;
  String? postnom;
  String? prenom;
  String? sexe;
  double? latitude;
  double? longitude;
  bool isLoading = false;

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
    });
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      return Future.error('Location services are disabled.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      latitude = position.latitude;
      longitude = position.longitude;
    });
  }

  Future<void> _sendData(String type) async {
    setState(() {
      isLoading = true;
    });

    await _getCurrentLocation();
    if (nom != null &&
        postnom != null &&
        prenom != null &&
        sexe != null &&
        latitude != null &&
        longitude != null) {
      try {
        final response = await http.post(
          Uri.parse('http://192.168.43.149:81/projetSV/calls.php'),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({
            'nom': nom!,
            'postnom': postnom!,
            'prenom': prenom!,
            'sexe': sexe!,
            'latitude': latitude.toString(),
            'longitude': longitude.toString(),
            'type': type,
          }),
        );

        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: const [
                  Icon(Icons.check, color: Colors.white),
                  SizedBox(width: 8),
                  Text('Demande soumise avec succès'),
                ],
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 10),
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: const [
                  Icon(Icons.error, color: Colors.white),
                  SizedBox(width: 8),
                  Text('Échec de l\'envoi des données'),
                ],
              ),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 5),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 8),
                Text('Erreur: $e'),
              ],
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
            behavior: SnackBarBehavior.floating,
          ),
        );
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: const [
              Icon(Icons.warning, color: Colors.white),
              SizedBox(width: 8),
              Text('Données utilisateur ou localisation manquantes'),
            ],
          ),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 5),
          behavior: SnackBarBehavior.floating,
        ),
      );
      setState(() {
        isLoading = false;
      });
    }
  }
  

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 60),
              ),
              const Padding(
                padding: EdgeInsets.only(left: 20),
                child: Text(
                  'VIE_SAUVE URGENCES',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 80),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SOSButton(
                    text: 'SOS AMBULANCE',
                    imageUrl: 'assets/ambulance.png',
                    onPressed: () {
                      _sendData('ambulance');
                    },
                  ),
                  SOSButton(
                    text: 'SOS POLICE',
                    imageUrl: 'assets/policier.jpg',
                    onPressed: () {
                      _sendData('police');
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SOSButton(
                    text: 'SOS POMPIER',
                    imageUrl: 'assets/pompier.png',
                    onPressed: () {
                      _sendData('pompier');
                    },
                  ),
                  SOSButton(
                    text: 'CHAT LIVE',
                    imageUrl: 'assets/chat.jpg',
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => const Livechat(),
                      ));
                    },
                  ),
                ],
              ),
            ],
          ),
          if (isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}

class SOSButton extends StatelessWidget {
  final String text;
  final String imageUrl;
  final VoidCallback onPressed;

  const SOSButton({
    required this.text,
    required this.imageUrl,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: onPressed,
          child: Material(
            elevation: 5,
            shape: const CircleBorder(),
            shadowColor: Colors.black,
            child: CircleAvatar(
              radius: 70,
              backgroundColor: const Color.fromARGB(255, 202, 155, 13),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: CircleAvatar(
                  radius: 40,
                  backgroundImage: AssetImage(imageUrl),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 5),
        Text(
          text,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
