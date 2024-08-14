import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Historique extends StatefulWidget {
  const Historique({super.key});

  @override
  State<Historique> createState() => _HistoriqueState();
}

class _HistoriqueState extends State<Historique> {
  List<Map<String, dynamic>> items = [];

  Future<void> fetchData() async {
    try {
      final response = await http.get(
        Uri.parse("http://192.168.43.149:81/projetSV/chargerrapport.php"),
      );

      setState(() {
        items = List<Map<String, dynamic>>.from(json.decode(response.body));
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to load items'),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    fetchData(); // Load initial data when the app starts
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        centerTitle: true,
        title: const Text('Historique des Operations'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const Padding(padding: EdgeInsets.only(left: 50)),
            Container(
              height: 1325,
              width: 1350,
              color: Colors.grey.shade100,
              child: Card(
                child: DataTable(
                  columns: const [
                    DataColumn(
                      label: Text('Operateurs et operations'),
                    ),
                    DataColumn(
                      label: Text('Heure_Entree'),
                    ),
                      DataColumn(
                      label: Text('Heure_sortie'),
                    ),
                  ],
                  rows: items.map<DataRow>((item) {
                    return DataRow(
                      color: MaterialStateColor.resolveWith(
                        (states) {
                          // Mettez ici la couleur que vous souhaitez pour la première ligne
                          return Colors.grey.shade200;
                        },
                      ),
                      cells: [
                        DataCell(
                          Text(
                            item['Email'].toString(),
                          ),
                        ),
                        DataCell(
                          Text(item['Heure_Entree']),
                        ),
                         DataCell(
                          Text(item['Heure_sortie']),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}