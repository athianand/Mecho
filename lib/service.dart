import 'package:flutter/material.dart';

class ServicePage extends StatelessWidget {
  const ServicePage({super.key});

  // Static history list to store all booked problems until user logs out
  static List<Map<String, dynamic>> problemHistory = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 18, 32, 47),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Service History',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: problemHistory.isEmpty
          ? const Center(
        child: Text(
          "No bookings yet",
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
      )
          : ListView(
        padding: const EdgeInsets.all(16),
        children: problemHistory.reversed.map((entry) {
          String vehicle = entry['vehicle'] ?? '';
          String problem = entry['problem'] ?? '';
          String time = entry['time'] ?? DateTime.now().toString().substring(0, 16);
          return Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 25,
                  backgroundColor: Colors.grey.shade300,
                  child: vehicle == 'Bike'
                      ? Image.asset('assets/bike.png', height: 30)
                      : Image.asset('assets/car.png', height: 30),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        problem,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        time,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Auto Repairs',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                )
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
