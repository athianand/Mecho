import 'package:flutter/material.dart';

class StatusPage extends StatelessWidget {
  const StatusPage({super.key});

  void _showPopup(BuildContext context, String title, String actionText) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: const Text("Do you want to proceed?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("$actionText action confirmed")),
              );
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Full screen white background
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(height: 10),

              // Profile icon
              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.grey.shade300,
                child:
                const Icon(Icons.person, size: 50, color: Colors.black54),
              ),
              const SizedBox(height: 12),

              // Name & subtitle
              const Text(
                "Ravi Kumar",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              const Text(
                "Auto Repairs",
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 20),

              // Car image - full and not cropped
              Image.asset(
                "assets/car.jpg",
                width: double.infinity,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 20),

              // Track button
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFA629),
                  padding:
                  const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                onPressed: () {},
                child: const Text(
                  "Track Your Mechanic",
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 25),

              // Status text
              const Text(
                "Mechanic is on the way",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 40),

              // Call & Chat buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  OutlinedButton.icon(
                    icon: const Icon(Icons.call, color: Colors.orange),
                    label: const Text(
                      "Call Support",
                      style: TextStyle(color: Colors.black),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFFFA629)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(34),
                      ),
                    ),
                    onPressed: () =>
                        _showPopup(context, "Call Support", "Call"),
                  ),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.chat, color: Colors.orange),
                    label: const Text(
                      "Chat with Mech",
                      style: TextStyle(color: Colors.black),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFFFA629)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(34),
                      ),
                    ),
                    onPressed: () =>
                        _showPopup(context, "Chat with Mechanic", "Chat"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
