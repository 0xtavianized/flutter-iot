import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';

class SaluranAllPage extends StatefulWidget {
  const SaluranAllPage({super.key});

  @override
  State<SaluranAllPage> createState() => _SaluranAllState();
}

class _SaluranAllState extends State<SaluranAllPage> {
  String? field1Data;
  String? field2Data;
  String? field3Data;
  String? field4Data;
  String? airHilang;
  bool isLoading = true;
  late Timer timer;

  double volume1 = 0.0;
  double volume2 = 0.0;
  double volume3 = 0.0;
  double volumeAirHilang = 0.0;

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
    const url =
        'https://api.thingspeak.com/channels/$channelId/feeds/last.json?api_key=$apiKey';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        setState(() {
          field1Data = jsonResponse['field1'] ?? '0';
          field2Data = jsonResponse['field2'] ?? '0';
          field3Data = jsonResponse['field3'] ?? '0';
          field4Data = jsonResponse['field4'] ?? '0';

          final double debit1 = double.tryParse(field1Data!) ?? 0;
          final double debit2 = double.tryParse(field2Data!) ?? 0;
          final double debit3 = double.tryParse(field3Data!) ?? 0;

          const double timeInMinutes = 1.0;

          volume1 = debit1 * timeInMinutes;
          volume2 = debit2 * timeInMinutes;
          volume3 = debit3 * timeInMinutes;

          if (debit2 + debit3 < debit1) {
            volumeAirHilang = (debit1 - (debit2 + debit3)) * timeInMinutes;
            airHilang = volumeAirHilang.toStringAsFixed(2);
          } else {
            airHilang = '0';
            volumeAirHilang = 0.0;
          }

          isLoading = false;
        });
      } else {
        setState(() {
          field1Data = 'Error';
          field2Data = 'Error';
          field3Data = 'Error';
          field4Data = 'Error';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        field1Data = 'Error: $e';
        field2Data = 'Error: $e';
        field3Data = 'Error: $e';
        field4Data = 'Error: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Semua Data Air',
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
                    _buildDataCard(
                      title: 'Debit Air 1',
                      value: field1Data ?? 'No Data',
                      unit: 'L/m',
                      volume: volume1,
                      icon: Icons.water,
                      color: Colors.blue,
                    ),
                    const SizedBox(height: 16.0),
                    _buildDataCard(
                      title: 'Debit Air 2',
                      value: field2Data ?? 'No Data',
                      unit: 'L/m',
                      volume: volume2,
                      icon: Icons.water_drop,
                      color: Colors.green,
                    ),
                    const SizedBox(height: 16.0),
                    _buildDataCard(
                      title: 'Debit Air 3',
                      value: field3Data ?? 'No Data',
                      unit: 'L/m',
                      volume: volume3,
                      icon: Icons.opacity,
                      color: Colors.teal,
                    ),
                    const SizedBox(height: 16.0),
                    _buildSuhuCard(
                      title: 'Suhu Air',
                      value: field4Data ?? 'No Data',
                      unit: '°C',
                      icon: Icons.thermostat,
                      color: Colors.yellow,
                    ),
                    if (airHilang != null) ...[
                      const SizedBox(height: 16.0),
                      _buildairHilangCard(),
                    ],
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSuhuCard({
    required String title,
    required String value,
    required String unit,
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
                          text: value,
                          style: const TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        TextSpan(
                          text: ' $unit',
                          style: const TextStyle(fontSize: 16.0),
                        ),
                      ],
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

  Widget _buildairHilangCard() {
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
              child: const Icon(Icons.warning, size: 30, color: Colors.red),
            ),
            const SizedBox(width: 16.0),
            Expanded(
              child: Text(
                'Debit air hilang: $airHilang L/m\nVolume: ${volumeAirHilang.toStringAsFixed(2)} L',
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
                          text: value,
                          style: TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                            color: color,
                          ),
                        ),
                        TextSpan(
                          text: ' $unit',
                          style: const TextStyle(fontSize: 16.0),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    'Volume: ${volume.toStringAsFixed(2)} L',
                    style: const TextStyle(
                      fontSize: 16.0,
                      color: Colors.grey,
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
