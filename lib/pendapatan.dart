import 'package:flutter/material.dart';

class PendapatanPage extends StatelessWidget {
  final double volume1;
  final double volume2;
  final double volume3;
  final double volumeAirHilang;

  const PendapatanPage({
    super.key,
    required this.volume1,
    required this.volume2,
    required this.volume3,
    required this.volumeAirHilang,
  });

  double calculateRevenue(double volume) {
    if (volume < 100) {
      return (volume / 100) * 2500;
    } else {
      return (volume / 100) * 3200;
    }
  }

  double calculateLoss(double volume) {
    if (volume < 100) {
      return (volume / 100) * 2500;
    } else {
      return (volume / 100) * 3200;
    }
  }

  @override
  Widget build(BuildContext context) {
    double revenue1 = calculateRevenue(volume1);
    double revenue2 = calculateRevenue(volume2);
    double revenue3 = calculateRevenue(volume3);
    double loss = calculateLoss(volumeAirHilang);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Data Pendapatan',
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildRevenueCard('Pendapatan Saluran 1', revenue1),
            const SizedBox(height: 16.0),
            _buildRevenueCard('Pendapatan Saluran 2', revenue2),
            const SizedBox(height: 16.0),
            _buildRevenueCard('Pendapatan Saluran 3', revenue3),
            const SizedBox(height: 16.0),
            _buildLossCard('Kerugian (Air Hilang)', loss),
          ],
        ),
      ),
    );
  }

  Widget _buildRevenueCard(String title, double revenue) {
    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            const Icon(
              Icons.monetization_on,
              size: 30,
              color: Colors.greenAccent,
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
                  Text(
                    'Rp ${revenue.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
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

  Widget _buildLossCard(String title, double loss) {
    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
      color: Colors.red.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            const Icon(
              Icons.warning,
              size: 30,
              color: Colors.red,
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
                  Text(
                    'Rp ${loss.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
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
