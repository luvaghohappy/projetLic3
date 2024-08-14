import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class Numero extends StatefulWidget {
  const Numero({super.key});

  @override
  State<Numero> createState() => _NumeroState();
}

class _NumeroState extends State<Numero> {
  List<Map<String, dynamic>> items = [];
  List<Map<String, dynamic>> filteredItems = [];
  String searchQuery = '';

  Future<void> fetchData() async {
    try {
      final response = await http.get(
        Uri.parse("http://192.168.43.149:81/projetSV/numero.php"),
      );

      if (response.statusCode == 200) {
        setState(() {
          items = List<Map<String, dynamic>>.from(json.decode(response.body));
          filteredItems = items;
        });
      } else {
        throw Exception('Failed to load items');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to load items'),
        ),
      );
    }
  }

  void _filterItems(String query) {
    setState(() {
      searchQuery = query;
      if (query.isEmpty) {
        filteredItems = items;
      } else {
        filteredItems = items.where((user) {
          final name = '${user['nom']} ${user['postnom']} ${user['prenom']}';
          return name.toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Utilisateurs numero urgences',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Stack(
        children: [
          filteredItems.isEmpty
              ? const Center(
                  child: Text(
                    'Aucun utilisateur trouvé',
                    style: TextStyle(fontSize: 18),
                  ),
                )
              : ListView.separated(
                  itemCount: filteredItems.length,
                  separatorBuilder: (context, index) => const Divider(
                    color: Colors.grey,
                    height: 1.0,
                    thickness: 1.0,
                  ),
                  itemBuilder: (context, index) {
                    final user = filteredItems[index];
                    return ListTile(
                      contentPadding: const EdgeInsets.all(10),
                      leading: const Icon(Icons.call),
                      title: Text(
                          '${user['nom']} ${user['postnom']} ${user['prenom']}'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '-numero 1: ${user['numero1']}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const Padding(
                            padding: EdgeInsets.only(left: 10),
                          ),
                          Text(
                            '-numero 2: ${user['numero2']}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const Padding(
                            padding: EdgeInsets.only(left: 10),
                          ),
                        ],
                      ),
                      trailing: const CircleAvatar(
                        radius: 15,
                        backgroundColor: Colors.green,
                        child: Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 10,
                        ),
                      ),
                    );
                  },
                ),
          Positioned(
            top: 10,
            right: 10,
            child: SizedBox(
              width: 300,
              child: TextField(
                onChanged: _filterItems,
                decoration: InputDecoration(
                  hintText: 'Rechercher un utilisateur...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: const BorderSide(color: Colors.white),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  prefixIcon: const Icon(Icons.search),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
