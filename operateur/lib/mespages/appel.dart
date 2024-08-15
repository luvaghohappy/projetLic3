// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:flutter_map/flutter_map.dart';
// import 'package:latlong2/latlong.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'dart:convert';
// import 'package:operateur/home.dart';
// import 'package:audioplayers/audioplayers.dart';

// class Urgences extends StatefulWidget {
//   const Urgences({super.key});

//   @override
//   State<Urgences> createState() => _UrgencesState();
// }

// class _UrgencesState extends State<Urgences> {
//   Map<int, bool> successStatus = {};
//   Map<int, bool> failureStatus = {};
//   List<Map<String, dynamic>> items = [];
//   List<Map<String, dynamic>> filteredItems = [];
//   final MapController _mapController = MapController();
//   final AudioPlayer _audioPlayer = AudioPlayer();
//   int _previousItemCount = 0;
//   String searchQuery = '';

//   @override
//   void initState() {
//     super.initState();
//     fetchData();
//   }

//   Future<void> fetchData() async {
//     try {
//       final response = await http.get(
//         Uri.parse("http://192.168.43.148:81/projetSV/get_data.php"),
//       );
//       if (response.statusCode == 200) {
//         final List<Map<String, dynamic>> newItems =
//             List<Map<String, dynamic>>.from(json.decode(response.body))
//                 .reversed
//                 .toList();

//         setState(() {
//           items = newItems;
//           filteredItems = items;
//           _previousItemCount = items.length;
//           successStatus = Map.fromIterable(
//             List.generate(items.length, (index) => index),
//             key: (item) => item,
//             value: (item) =>
//                 false, // Toutes les cases sont initialement non cochées (rouge par défaut)
//           );
//           failureStatus = Map.fromIterable(
//             List.generate(items.length, (index) => index),
//             key: (item) => item,
//             value: (item) =>
//                 true, // Rouge par défaut pour tout nouvel enregistrement
//           );
//           _loadCheckboxState();
//         });

//         _checkIfSirenShouldPlay();
//       } else {
//         throw Exception('Failed to load data');
//       }
//     } catch (e) {
//       print('Error fetching data: $e');
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Failed to load items'),
//         ),
//       );
//     }
//   }

//   void _checkIfSirenShouldPlay() {
//     bool shouldPlaySiren = failureStatus.values.contains(true);

//     if (shouldPlaySiren) {
//       _playNotificationSound(); // Jouer le son de notification s'il y a au moins une case rouge
//     }
//   }

//   Future<void> _playNotificationSound() async {
//     await _audioPlayer.play(AssetSource('sirene.mp3'));
//   }

//   DataCell _buildStatusCell(int index) {
//     return DataCell(
//       Row(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Checkbox(
//             value: successStatus[index] ?? false,
//             onChanged: (value) {
//               // Les cases vertes ne peuvent pas être modifiées par l'utilisateur
//             },
//             activeColor: Colors.green,
//             checkColor: Colors.white,
//             tristate: true,
//           ),
//           const SizedBox(width: 10),
//           Checkbox(
//             value: failureStatus[index] ?? false,
//             onChanged: (value) {
//               // Les cases rouges ne peuvent pas être modifiées par l'utilisateur
//             },
//             activeColor: Colors.red,
//             checkColor: Colors.white,
//             tristate: true,
//           ),
//         ],
//       ),
//     );
//   }

//   void _moveToLocation(String location, String service, int index) {
//     if (location != null && location.isNotEmpty) {
//       try {
//         final coordinates =
//             location.replaceAll('POINT(', '').replaceAll(')', '').split(' ');
//         final lat = double.parse(coordinates[1]);
//         final lon = double.parse(coordinates[0]);

//         WidgetsBinding.instance.addPostFrameCallback((_) {
//           _mapController.move(LatLng(lat, lon), 13.0);
//         });

//         setState(() {
//           successStatus[index] = true; // Cocher la case verte automatiquement
//           failureStatus[index] = false; // Décocher la case rouge
//         });
//         _saveCheckboxState();

//         Navigator.of(context).push(
//           MaterialPageRoute(
//             builder: (context) => Homepage(
//               email: '',
//               initialLocation: LatLng(lat, lon), service: '',
//             ),
//           ),
//         );
//       } catch (e) {
//         print('Error parsing location: $e');
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('Invalid location format'),
//           ),
//         );
//       }
//     }
//   }

//   Future<void> _saveCheckboxState() async {
//     final prefs = await SharedPreferences.getInstance();
//     for (int i = 0; i < items.length; i++) {
//       await prefs.setBool('success_$i', successStatus[i] ?? false);
//       await prefs.setBool('failure_$i', failureStatus[i] ?? true);
//     }
//   }

//   Future<void> _loadCheckboxState() async {
//     final prefs = await SharedPreferences.getInstance();
//     for (int i = 0; i < items.length; i++) {
//       successStatus[i] = prefs.getBool('success_$i') ?? false;
//       failureStatus[i] = prefs.getBool('failure_$i') ?? true;
//     }
//   }

//   void _filterItems(String query) {
//     setState(() {
//       searchQuery = query;
//       if (query.isEmpty) {
//         filteredItems = items;
//       } else {
//         filteredItems = items.where((user) {
//           final name = '${user['nom']} ${user['postnom']} ${user['prenom']}';
//           return name.toLowerCase().contains(query.toLowerCase());
//         }).toList();
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Column(
//         children: [
//           const Padding(
//             padding: EdgeInsets.only(top: 30),
//           ),
//           const Text(
//             'Signales des détresses',
//             style: TextStyle(
//                 color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
//           ),
//           PreferredSize(
//             preferredSize: const Size.fromHeight(40.0),
//             child: Padding(
//               padding: const EdgeInsets.all(10.0),
//               child: Align(
//                 alignment: Alignment.centerRight,
//                 child: SizedBox(
//                   width: 300,
//                   child: TextField(
//                     onChanged: _filterItems,
//                     decoration: InputDecoration(
//                       hintText: 'Rechercher...',
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(10.0),
//                         borderSide: const BorderSide(color: Colors.white),
//                       ),
//                       filled: true,
//                       fillColor: Colors.white,
//                       prefixIcon: const Icon(Icons.search),
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ),
//           Expanded(
//             child: SingleChildScrollView(
//               scrollDirection: Axis.horizontal,
//               child: SingleChildScrollView(
//                 scrollDirection: Axis.vertical,
//                 child: DataTable(
//                   columns: const [
//                     DataColumn(label: Text('Nom')),
//                     DataColumn(label: Text('Postnom')),
//                     DataColumn(label: Text('Prenom')),
//                     DataColumn(label: Text('Sexe')),
//                     DataColumn(label: Text('Locations')),
//                     DataColumn(label: Text('Date_Heure')),
//                     DataColumn(label: Text('Services')),
//                     DataColumn(label: Text('Etat')),
//                   ],
//                   rows: List.generate(filteredItems.length, (index) {
//                     final item = filteredItems[index];
//                     return DataRow(
//                       cells: [
//                         DataCell(Text(item['nom'] ?? '')),
//                         DataCell(Text(item['postnom'] ?? '')),
//                         DataCell(Text(item['prenom'] ?? '')),
//                         DataCell(Text(item['sexe'] ?? '')),
//                         DataCell(
//                           InkWell(
//                             onTap: () {
//                               _moveToLocation(
//                                   item['locations'], item['service'], index);
//                             },
//                             child: Text(
//                               item['locations'] ?? '',
//                               style: const TextStyle(color: Colors.blue),
//                             ),
//                           ),
//                         ),
//                         DataCell(Text(item['created_at'] ?? '')),
//                         DataCell(Text(item['service'] ?? '')),
//                         _buildStatusCell(index),
//                       ],
//                     );
//                   }),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
