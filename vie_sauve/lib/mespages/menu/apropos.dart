import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Apropos extends StatefulWidget {
  const Apropos({super.key});

  @override
  State<Apropos> createState() => _AproposState();
}

class _AproposState extends State<Apropos> {
  final List<String> services = [
    "Signalement d'incidents",
    "Partage de localisation en temps réel",
    "Instructions de premiers secours",
    "Suivi des incidents",
    "Communication rapide avec les services d'urgence"
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 30),
              ),
              const Text(
                'À propos de VIE-SAUVE',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const Padding(
                padding: EdgeInsets.only(top: 10),
              ),
              Text(
                "VIE-SAUVE est une application mobile innovante conçue pour améliorer la sécurité et la gestion des urgences dans des situations critiques. En offrant une plateforme qui permet de signaler rapidement des incidents, de partager des localisations en temps réel, et de recevoir des instructions de premiers secours, VIE-SAUVE vise à sauver des vies en réduisant les délais d'intervention.",
                style: GoogleFonts.abel(),
              ),
              const Padding(
                padding: EdgeInsets.only(top: 10),
              ),
              const Text(
                'Objectif',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const Padding(
                padding: EdgeInsets.only(top: 10),
              ),
              Text(
                "L'objectif principal de VIE-SAUVE est de faciliter et d'accélérer l'intervention des services d'urgence en offrant aux utilisateurs un outil fiable pour signaler et gérer les situations d'urgence. Nous voulons fournir une tranquillité d'esprit en offrant des services de localisation précise, de communication rapide, et de suivi des incidents.",
                style: GoogleFonts.abel(),
              ),
              const Padding(
                padding: EdgeInsets.only(top: 10),
              ),
              const Text(
                'Nos Services',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const Padding(
                padding: EdgeInsets.only(top: 10),
              ),
              ...services.map(
                (service) => Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '• ',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Expanded(
                        child: Text(
                          service,
                          style: GoogleFonts.abel(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(top: 10),
              ),
              const Text(
                'Engagement',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const Padding(
                padding: EdgeInsets.only(top: 10),
              ),
              Text(
                "Nous croyons fermement que VIE-SAUVE contribuera à renforcer la sécurité et la résilience de notre communauté. En permettant des interventions plus rapides et en offrant des outils de gestion des urgences efficaces, nous aspirons à sauver des vies et à réduire les impacts des incidents critiques.",
                style: GoogleFonts.abel(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
