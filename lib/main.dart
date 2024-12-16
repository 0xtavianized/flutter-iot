import 'package:flutter/material.dart';
import 'saluran_1.dart';
import 'saluran_2.dart';
import 'saluran_3.dart';
import 'semua.dart';
import 'suhu.dart';
import 'history.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ThingSpeak Satya',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home',
            style: TextStyle(
                fontSize: 30,
                color: Colors.white,
                letterSpacing: 2,
                fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
        toolbarHeight: 69,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16.0,
          mainAxisSpacing: 16.0,
          children: [
            _buildIconCard(
              icon: Icons.water_sharp,
              label: 'Semua Saluran',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SaluranAllPage(),
                  ),
                );
              },
            ),
            _buildIconCard(
              icon: Icons.account_tree_outlined,
              label: 'Saluran 1',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const Saluran1Page(),
                  ),
                );
              },
            ),
            _buildIconCard(
              icon: Icons.account_tree_outlined,
              label: 'Saluran 2',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const Saluran2Page(),
                  ),
                );
              },
            ),
            _buildIconCard(
              icon: Icons.account_tree_outlined,
              label: 'Saluran 3',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const Saluran3Page(),
                  ),
                );
              },
            ),
            _buildIconCard(
              icon: Icons.thermostat,
              label: 'Suhu',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SuhuPage(),
                  ),
                );
              },
            ),
            _buildIconCard(
              icon: Icons.watch_later_outlined,
              label: 'History',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const HistoryPage(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconCard({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 4.0,
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: Colors.blueAccent, width: 2.2),
          borderRadius: BorderRadius.circular(7.0),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 45.0, color: Colors.blue),
            const SizedBox(height: 12.0),
            Text(
              label,
              style:
                  const TextStyle(fontSize: 17.0, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}
