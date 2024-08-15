import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:url_launcher/url_launcher.dart';

class Livechat extends StatefulWidget {
  const Livechat({super.key});

  @override
  State<Livechat> createState() => _LivechatState();
}

class _LivechatState extends State<Livechat> {
  final number = '+243999582152';
  final numberwatshapp = '+243997110903';
  String? imagePath;
  String? prenom;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      prenom = prefs.getString('prenom');
      imagePath = prefs.getString('image_path');
    });
  }

  Future<void> _launchWhatsApp() async {
    String url = 'https://wa.me/$numberwatshapp?text=Hello';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = imagePath != null
        ? "http://192.168.43.149:81/projetSV/$imagePath"
        : null;
    print('Image URL: $imageUrl');
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'VIE_SAUVE',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        leading: const CircleAvatar(
          radius: 15,
          backgroundImage: AssetImage('assets/logo.jpg'),
        ),
        actions: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: Colors.blue,
                backgroundImage:
                    imageUrl != null ? NetworkImage(imageUrl) : null,
                child: imageUrl == null
                    ? const Icon(Icons.person, size: 20, color: Colors.grey)
                    : null,
              ),
              const SizedBox(width: 10),
              Center(
                child: Text(
                  prenom ?? '',
                  style: const TextStyle(color: Colors.black),
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                
                const Text(
                  'Communiquez avec les operateurs',
                  style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 20),
                ),
                const SizedBox(height: 120),
                _buildActionButton(
                  color: Colors.orange,
                  icon: Icons.live_tv_outlined,
                  text: 'Appel Video',
                  onTap: _launchWhatsApp,
                ),
                const SizedBox(height: 20),
                _buildActionButton(
                  color: Colors.green,
                  icon: Icons.call,
                  text: 'Appelez',
                  onTap: () async {
                    await FlutterPhoneDirectCaller.callNumber(number);
                  },
                ),
                const SizedBox(height: 20),
                _buildActionButton(
                  color: Colors.blue,
                  icon: Icons.chat,
                  text: 'Chat',
                  onTap: () async {
                    final Uri smsUri = Uri(
                      scheme: 'sms',
                      path: number,
                    );
                    if (await canLaunchUrl(smsUri)) {
                      await launchUrl(smsUri);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                              'Impossible d\'ouvrir l\'application de messagerie.'),
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required Color color,
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 60,
        width: 250,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 30,
                color: Colors.white,
              ),
              const SizedBox(width: 10),
              Text(
                text,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
