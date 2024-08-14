import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../menu.dart';
import 'operateur.dart';
import 'poste.dart';
import 'rapport.dart';

class Myfirstpage extends StatefulWidget {
  const Myfirstpage({Key? key}) : super(key: key);

  @override
  State<Myfirstpage> createState() => _MyfirstpageState();
}

class _MyfirstpageState extends State<Myfirstpage> {
  List<TableInfo> tableInfoList = [];
  List<Color> colors = [
    Colors.blue,
    Colors.red,
    Colors.green,
    Colors.orange,
    Colors.purple
  ];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      final response = await http.get(
        Uri.parse("http://192.168.43.149:81/projetSV/state.php"),
      );

      if (response.statusCode == 200) {
        final body = response.body;
        print("Response body: $body");
        final decodedResponse = json.decode(body);

        if (decodedResponse is List) {
          setState(() {
            tableInfoList = decodedResponse
                .map((item) => TableInfo.fromJson(item))
                .toList();
            print("Table info list updated: $tableInfoList");
          });
        } else if (decodedResponse is Map &&
            decodedResponse.containsKey('message')) {
          String message = decodedResponse['message'];
          print("Message in response: $message");
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
            ),
          );
        } else if (decodedResponse is Map &&
            decodedResponse.containsKey('error')) {
          String error = decodedResponse['error'];
          print("Error in response: $error");
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to load items: $error'),
            ),
          );
        } else {
          throw const FormatException('Unexpected response format');
        }
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      print("Error while fetching data: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to load items'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade300,
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Dashboard',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              child: Center(
                child: Column(
                  children: [
                    Image.asset(
                      'assets/logo.jpg',
                      width: 300,
                      height: 130,
                    ),
                  ],
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(top: 10),
            ),
            ListTile(
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const Users2(),
                ));
              },
              leading: const Icon(
                Icons.support_agent,
                color: Colors.green,
              ),
              title: const Text('Operateurs'),
            ),
            const Padding(
              padding: EdgeInsets.only(top: 20),
            ),
            ListTile(
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const Postes(),
                ));
              },
              leading: const Icon(
                Icons.work_history_outlined,
                color: Color.fromARGB(255, 201, 124, 23),
              ),
              title: const Text('Postes'),
            ),
            const Padding(
              padding: EdgeInsets.only(top: 20),
            ),
            ListTile(
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const Rapports(),
                ));
              },
              leading: const Icon(
                Icons.book,
                color: Colors.brown,
              ),
              title: const Text('Rapports'),
            ),
            const Padding(
              padding: EdgeInsets.only(top: 240),
            ),
            ListTile(
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const Menu(),
                ));
              },
              leading: const Icon(
                Icons.login_outlined,
                color: Colors.red,
              ),
              title: const Text('Deconnexion'),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 40),
            ),
            Expanded(
              child: Row(
                children: [
                  // Left column for first three table names
                  Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: tableInfoList.asMap().entries.map((entry) {
                        int index = entry.key;
                        TableInfo info = entry.value;
                        return index < 3
                            ? Container(
                                height: 120,
                                width: 200,
                                margin:
                                    const EdgeInsets.symmetric(vertical: 10),
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: colors[index % colors.length],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  children: [
                                    Text(
                                      info.recordCount.toString(),
                                      style: const TextStyle(
                                          color: Colors.white, fontSize: 25),
                                    ),
                                    Text(
                                      info.tableName,
                                      style: const TextStyle(
                                          color: Colors.white, fontSize: 18),
                                    ),
                                  ],
                                ),
                              )
                            : Container();
                      }).toList(),
                    ),
                  ),
                  const SizedBox(width: 20),
                  // Center for Graphique
                  Expanded(
                    flex: 2,
                    child: Column(
                      children: [
                        const Text(
                          'STATISTIQUES',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          height:
                              400, // Adjust the height of the graph container
                          child: BarChart(
                            BarChartData(
                              maxY: 50, // Maximum Y value
                              barTouchData: BarTouchData(
                                touchTooltipData: BarTouchTooltipData(
                                  tooltipBgColor: Colors.grey,
                                ),
                                touchCallback:
                                    (FlTouchEvent event, response) {},
                              ),
                              titlesData: FlTitlesData(
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    reservedSize: 40,
                                    getTitlesWidget: (value, meta) {
                                      int index = value.toInt();
                                      return SideTitleWidget(
                                        axisSide: meta.axisSide,
                                        child: Text(
                                          tableInfoList.isNotEmpty &&
                                                  index < tableInfoList.length
                                              ? tableInfoList[index].tableName
                                              : '',
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                leftTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    reservedSize: 40,
                                    getTitlesWidget: (value, meta) {
                                      List<int> yTitles = [
                                        1,
                                        10,
                                        20,
                                        30,
                                        40,
                                        50
                                      ];
                                      return SideTitleWidget(
                                        axisSide: meta.axisSide,
                                        child: Text(
                                          yTitles.contains(value.toInt())
                                              ? value.toString()
                                              : '',
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                topTitles: AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                                rightTitles: AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                              ),
                              borderData: FlBorderData(
                                show: false,
                              ),
                              gridData: FlGridData(
                                show: false,
                              ),
                              barGroups:
                                  List.generate(tableInfoList.length, (i) {
                                return BarChartGroupData(
                                  x: i,
                                  barRods: [
                                    BarChartRodData(
                                      toY: tableInfoList[i]
                                          .recordCount
                                          .toDouble(),
                                      color: colors[i % colors.length],
                                      width: 15, // Adjust the width of bars
                                    )
                                  ],
                                );
                              }),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 20),
                  // Right column for remaining two table names
                  Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: tableInfoList.asMap().entries.map((entry) {
                        int index = entry.key;
                        TableInfo info = entry.value;
                        return index >= 3
                            ? Container(
                                width: 200,
                                height: 120,
                                margin:
                                    const EdgeInsets.symmetric(vertical: 10),
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: colors[index % colors.length],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  children: [
                                    Text(
                                      info.recordCount.toString(),
                                      style: const TextStyle(
                                          color: Colors.white, fontSize: 25),
                                    ),
                                    Text(
                                      info.tableName,
                                      style: const TextStyle(
                                          color: Colors.white, fontSize: 18),
                                    ),
                                  ],
                                ),
                              )
                            : Container();
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TableInfo {
  final String tableName;
  final int recordCount;

  TableInfo({
    required this.tableName,
    required this.recordCount,
  });

  factory TableInfo.fromJson(Map<String, dynamic> json) {
    return TableInfo(
      tableName: json['table_names'] ?? 'Unknown',
      recordCount: json['record_count'] ?? 0,
    );
  }
}
