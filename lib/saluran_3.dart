import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Saluran3Page extends StatefulWidget {
  const Saluran3Page({super.key});

  @override
  State<Saluran3Page> createState() => _Saluran3PageState();
}

class _Saluran3PageState extends State<Saluran3Page> {
  String? data;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    const channelId = '2783698';
    const apiKey = 'FOH29NJIHQ4DT1E7';
    const url =
        'https://api.thingspeak.com/channels/$channelId/feeds.json?api_key=$apiKey&results=1';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        setState(() {
          data = jsonResponse['feeds'][0]['field3'] ?? 'No Data';
          isLoading = false;
        });
      } else {
        setState(() {
          data = 'Failed to fetch data';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        data = 'Error: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Saluran 3',
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
      body: Center(
        child: isLoading
            ? const CircularProgressIndicator()
            : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Card(
                  elevation: 6.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundColor: Colors.blue[50],
                          child: const Icon(
                            Icons.water_drop,
                            size: 40,
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(height: 16.0),
                        const Text(
                          'Debit Air 3',
                          style: TextStyle(
                            fontSize: 22.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueAccent,
                          ),
                        ),
                        const SizedBox(height: 16.0),
                        RichText(
                          text: TextSpan(
                            style: const TextStyle(
                              fontSize: 20.0,
                              color: Colors.black,
                            ),
                            children: [
                              TextSpan(
                                text: data,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 24.0,
                                ),
                              ),
                              const TextSpan(
                                text: ' L/d',
                                style: TextStyle(
                                  fontWeight: FontWeight.normal,
                                  fontSize: 18.0,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}
