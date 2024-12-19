import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';

class PendapatanPage extends StatefulWidget {
  const PendapatanPage({super.key});

  @override
  State<PendapatanPage> createState() => _PendapatanState();
}

class _PendapatanState extends State<PendapatanPage> {
  String? field5Data;
  String? field6Data;
  String? field7Data;
  bool isLoading = true;
  late Timer timer;

  double volume1 = 0.0;
  double volume5 = 0.0;
  double volume6 = 0.0;
  double volume7 = 0.0;
  double volumeAirHilang = 0.0;
  double revenueField5 = 0.0;
  double revenueField6 = 0.0;
  double revenueField7 = 0.0;
  double loss = 0.0;

  String selectedMonth = '01';
  String selectedYear = '2024';

  double calculateRevenue(double volume) {
    return (volume / 100) * (volume <= 100 ? 2500 : 3200);
  }

  @override
  void initState() {
    super.initState();
    _fetchData();
    timer = Timer.periodic(const Duration(seconds: 15), (timer) {
      _fetchData();
    });
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  Future<void> _fetchData() async {
    const channelId = '2783698';
    const apiKey = 'FOH29NJIHQ4DT1E7';

    final url =
        'https://api.thingspeak.com/channels/$channelId/feeds.json?api_key=$apiKey&start=$selectedYear-$selectedMonth-01&end=$selectedYear-$selectedMonth-30';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        setState(() {
          field5Data = jsonResponse['feeds'][0]['field5'] ?? '0';
          field6Data = jsonResponse['feeds'][0]['field6'] ?? '0';
          field7Data = jsonResponse['feeds'][0]['field7'] ?? '0';

          final double debit5 = double.tryParse(field5Data!) ?? 0;
          final double debit6 = double.tryParse(field6Data!) ?? 0;
          final double debit7 = double.tryParse(field7Data!) ?? 0;

          const double timeInMinutes = 1.0;

          volume5 = debit5 * timeInMinutes;
          volume6 = debit6 * timeInMinutes;
          volume7 = debit7 * timeInMinutes;

          revenueField5 = calculateRevenue(volume5);
          revenueField6 = calculateRevenue(volume6);
          revenueField7 = calculateRevenue(volume7);

          if ((volume6 + volume7) < volume5) {
            volumeAirHilang =
                ((volume5 - (volume6 + volume7)) * timeInMinutes).abs();
            loss = calculateRevenue(volumeAirHilang);
          } else {
            volumeAirHilang = 0.0;
            loss = 0.0;
          }

          isLoading = false;
        });
      } else {
        setState(() {
          field5Data = 'Error';
          field6Data = 'Error';
          field7Data = 'Error';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        field5Data = 'Error: $e';
        field6Data = 'Error: $e';
        field7Data = 'Error: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Data Pendapatan / Kerugian',
          style: TextStyle(fontSize: 24, color: Colors.white),
        ),
        backgroundColor: Colors.blueAccent,
        toolbarHeight: 69,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: Colors.white,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButton<String>(
                            value: selectedMonth,
                            items: [
                              {'01': 'Januari'},
                              {'02': 'Februari'},
                              {'03': 'Maret'},
                              {'04': 'April'},
                              {'05': 'Mei'},
                              {'06': 'Juni'},
                              {'07': 'Juli'},
                              {'08': 'Agustus'},
                              {'09': 'September'},
                              {'10': 'Oktober'},
                              {'11': 'November'},
                              {'12': 'Desember'},
                            ].map((month) {
                              final key = month.keys.first;
                              final value = month[key]!;
                              return DropdownMenuItem<String>(
                                value: key,
                                child: Text(value),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                selectedMonth = value!;
                                isLoading = true;
                              });
                              _fetchData();
                            },
                          ),
                        ),
                        const SizedBox(width: 16.0),
                        Expanded(
                          child: DropdownButton<String>(
                            value: selectedYear,
                            items: List.generate(5, (index) {
                              int year = DateTime.now().year - index;
                              return DropdownMenuItem<String>(
                                value: year.toString(),
                                child: Text(year.toString()),
                              );
                            }),
                            onChanged: (value) {
                              setState(() {
                                selectedYear = value!;
                                isLoading = true;
                              });
                              _fetchData();
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16.0),
                    _buildDataCard(
                      title:
                          'Biaya Kontribusi Distribusi Air SPAM Petanglong Batang',
                      value: revenueField5.toStringAsFixed(2),
                      unit: 'Rp',
                      volume: volume5,
                      icon: Icons.attach_money_outlined,
                      color: Colors.green,
                    ),
                    const SizedBox(height: 16.0),
                    _buildDataCard(
                      title: 'Pendapatan DMA 1',
                      value: revenueField6.toStringAsFixed(2),
                      unit: 'Rp',
                      volume: volume6,
                      icon: Icons.attach_money_outlined,
                      color: Colors.green,
                    ),
                    const SizedBox(height: 16.0),
                    _buildDataCard(
                      title: 'Pendapatan DMA 2',
                      value: revenueField7.toStringAsFixed(2),
                      unit: 'Rp',
                      volume: volume7,
                      icon: Icons.attach_money_outlined,
                      color: Colors.green,
                    ),
                    const SizedBox(height: 16.0),
                    _buildAirHilangCard(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildAirHilangCard() {
    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: Colors.red.withOpacity(0.2),
              child: const Icon(Icons.attach_money_outlined,
                  size: 30, color: Colors.red),
            ),
            const SizedBox(width: 16.0),
            Expanded(
              child: Text(
                'Kerugian: Rp ${loss.toStringAsFixed(2)}\nVolume: ${volumeAirHilang.toStringAsFixed(2)} L',
                style: const TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataCard({
    required String title,
    required String value,
    required String unit,
    required double volume,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: color.withOpacity(0.2),
              child: Icon(icon, size: 30, color: color),
            ),
            const SizedBox(width: 16.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: '$unit ',
                          style: const TextStyle(fontSize: 16.0),
                        ),
                        TextSpan(
                          text: value,
                          style: TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                            color: color,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    'Volume: ${volume.toStringAsFixed(2)} L',
                    style: const TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
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
