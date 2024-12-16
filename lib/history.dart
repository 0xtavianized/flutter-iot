import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  String? field1Data;
  String? field2Data;
  String? field3Data;
  String? suhuData;
  String? selectedField;
  String? airHilang;
  DateTime? selectedDate;
  TimeOfDay? startTime;
  TimeOfDay? endTime;
  List<Map<String, dynamic>> historyData = [];
  bool isLoading = false;

  final List<Map<String, String>> fields = [
    {'value': 'field1', 'label': 'Saluran 1'},
    {'value': 'field2', 'label': 'Saluran 2'},
    {'value': 'field3', 'label': 'Saluran 3'},
    {'value': 'field4', 'label': 'Suhu'},
    {'value': 'Semua', 'label': 'Semua'}
  ];

  Future<void> fetchHistoryData() async {
    if (selectedField == null || selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Harap pilih saluran dan tanggal.')),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    const channelId = '2783698';
    const apiKey = 'FOH29NJIHQ4DT1E7';
    final String formattedDate =
        "${selectedDate!.year}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.day.toString().padLeft(2, '0')}";

    final url =
        'https://api.thingspeak.com/channels/$channelId/feeds.json?api_key=$apiKey&start=$formattedDate%2000:00:00&end=$formattedDate%2023:59:59';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        final feeds = jsonResponse['feeds'] as List<dynamic>;

        setState(() {
          if (selectedField == 'Semua') {
            historyData = feeds
                .map((feed) => {
                      'Saluran 1': feed['field1'] ?? 'No Data',
                      'Saluran 2': feed['field2'] ?? 'No Data',
                      'Saluran 3': feed['field3'] ?? 'No Data',
                      'Suhu': feed['field4'] ?? 'No Data',
                      'created_at': feed['created_at'] ?? 'Unknown Time',
                    })
                .toList();
          } else {
            historyData = feeds
                .map((feed) => {
                      'value': feed[selectedField] ?? 'No Data',
                      'created_at': feed['created_at'] ?? 'Unknown Time',
                    })
                .toList();
          }

          if (feeds.isNotEmpty) {
            final lastFeed = feeds.last;
            final field1Data = lastFeed['field1'] ?? '0';
            final field2Data = lastFeed['field2'] ?? '0';
            final field3Data = lastFeed['field3'] ?? '0';
            final suhuData = lastFeed['field4'] ?? '0';

            final double debit1 = double.tryParse(field1Data) ?? 0;
            final double debit2 = double.tryParse(field2Data) ?? 0;
            final double debit3 = double.tryParse(field3Data) ?? 0;
            final double suhu = double.tryParse(suhuData) ?? 0;

            if (debit2 + debit3 < debit1) {
              airHilang = (debit1 - (debit2 + debit3)).toStringAsFixed(2);
            } else {
              airHilang = '0';
            }
          } else {
            airHilang = 'No Data';
          }

          final startDateTime = DateTime(
            selectedDate!.year,
            selectedDate!.month,
            selectedDate!.day,
            startTime?.hour ?? 0,
            startTime?.minute ?? 0,
          );
          final endDateTime = DateTime(
            selectedDate!.year,
            selectedDate!.month,
            selectedDate!.day,
            endTime?.hour ?? 23,
            endTime?.minute ?? 59,
          );

          historyData = historyData.where((item) {
            final createdAt =
                DateFormat("yyyy-MM-ddTHH:mm:ssZ").parse(item['created_at']);
            return createdAt.isAfter(startDateTime) &&
                createdAt.isBefore(endDateTime);
          }).toList();

          isLoading = false;
        });
      } else {
        if (!mounted) {
          return;
        }
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${response.statusCode}')),
        );
      }
    } catch (e) {
      if (!mounted) {
        return;
      }
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> pickDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (pickedDate != null) {
      setState(() {
        selectedDate = pickedDate;
      });
    }
  }

  Future<void> pickStartTime() async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (pickedTime != null) {
      setState(() {
        startTime = pickedTime;
      });
    }
  }

  Future<void> pickEndTime() async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (pickedTime != null) {
      setState(() {
        endTime = pickedTime;
      });
    }
  }

  String formatTime(String createdAt) {
    try {
      final dateTimeUtc = DateTime.parse(createdAt);

      final dateTimeLocal = dateTimeUtc.add(Duration(hours: 7));

      return DateFormat('HH:mm:ss').format(dateTimeLocal);
    } catch (e) {
      return 'Invalid Time';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'History',
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Pilih Saluran',
                border: OutlineInputBorder(),
              ),
              items: fields
                  .map((field) => DropdownMenuItem(
                        value: field['value'],
                        child: Text(field['label']!),
                      ))
                  .toList(),
              value: selectedField,
              onChanged: (value) {
                setState(() {
                  selectedField = value;
                });
              },
            ),
            const SizedBox(height: 16.0),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(
                      Icons.calendar_today,
                      color: Colors.black,
                    ),
                    label: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        selectedDate != null
                            ? "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}"
                            : 'Pilih Tanggal',
                        style: const TextStyle(color: Colors.black),
                      ),
                    ),
                    onPressed: pickDate,
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 55),
                      alignment: Alignment.centerLeft,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.access_time, color: Colors.black),
                    label: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        startTime != null
                            ? startTime!.format(context)
                            : 'Jam Awal',
                        style: const TextStyle(color: Colors.black),
                      ),
                    ),
                    onPressed: pickStartTime,
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 55),
                      alignment: Alignment.centerLeft,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8.0),
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.access_time, color: Colors.black),
                    label: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        endTime != null
                            ? endTime!.format(context)
                            : 'Jam Akhir',
                        style: const TextStyle(color: Colors.black),
                      ),
                    ),
                    onPressed: pickEndTime,
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 55),
                      alignment: Alignment.centerLeft,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: fetchHistoryData,
              style: ElevatedButton.styleFrom(
                textStyle: const TextStyle(fontSize: 16.0, letterSpacing: 1.2),
                foregroundColor: Colors.white,
                backgroundColor: Colors.blueAccent,
                minimumSize: const Size(200, 50),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero,
                ),
              ),
              child: const Text('Tampilkan'),
            ),
            const SizedBox(height: 16.0),
            Expanded(
                child: historyData.isEmpty
                    ? const Center(
                        child: Text(
                          'Tidak ada data',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    : ListView.builder(
                        itemCount: historyData.length,
                        itemBuilder: (context, index) {
                          final item = historyData[index];
                          return Card(
                            child: ListTile(
                              title: Text(
                                selectedField == 'Semua'
                                    ? 'Saluran 1 : ${item['Saluran 1']} L/d\nSaluran 2 : ${item['Saluran 2']} L/d\nSaluran 3 : ${item['Saluran 3']} L/d\nSuhu : ${item['Suhu']}°C\nAir Hilang : $airHilang L/d'
                                    : selectedField ==
                                            'field4' // jika memilih saluran suhu
                                        ? 'Suhu : ${item['value']}°C' // tampilkan suhu dalam format yang benar
                                        : 'Debit: ${item['value']} L/d',
                              ),
                              subtitle: Text(
                                  'Waktu : ${formatTime(item['created_at'])}'),
                            ),
                          );
                        },
                      )),
          ],
        ),
      ),
    );
  }
}
