import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'form.dart'; // ✅ UserData
import 'logo.dart';
import 'profile.dart';
import 'service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

class SelectPage extends StatefulWidget {
  const SelectPage({super.key});

  @override
  State<SelectPage> createState() => _SelectPageState();
}

class _SelectPageState extends State<SelectPage> {
  Position? _currentPosition;
  String selectedVehicle = '';
  final TextEditingController _problemController = TextEditingController();
  bool isLoading = false;

  // ✅ Target mechanic FCM token
  final String mechanicFcmToken =
      "eCWF8QXuQaShmFxgzbvSWJ:APA91bEGbIdhIvcx8J6lJsgyl63ZjExxUS5PWexe8P2JJwo0qgC7So4kW6gZFfjFfPZX-a7ODAqoLKQ5lhz9iqaIIsht5asx4Z_JlEOtO6UXtIuFjOUU_8Y";

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _loadUserBookings();
  }

  @override
  void dispose() {
    _problemController.dispose();
    super.dispose();
  }

  // ✅ Load bookings from Firestore for the logged-in user
  Future<void> _loadUserBookings() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection("Requests")
          .where("email", isEqualTo: UserData.email)
          .orderBy("timestamp", descending: true)
          .get();

      ServicePage.problemHistory = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          "vehicle": data["vehicleType"] ?? "",
          "problem": data["problem"] ?? "",
          "timestamp": data["timestamp"]?.toDate().toString() ?? "",
        };
      }).toList();
    } catch (e) {
      print("🔥 Error loading bookings: $e");
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Location services are disabled")),
        );
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Location permissions are denied")),
          );
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Location permissions are permanently denied")),
        );
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _currentPosition = position;
      });
      print("📍 Current Position: ${position.latitude}, ${position.longitude}");
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error getting location: $e")),
      );
    }
  }

  Future<void> _sendBooking() async {
    if (_currentPosition == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enable location first")),
      );
      return;
    }

    if (selectedVehicle.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a vehicle")),
      );
      return;
    }

    if (_problemController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter the problem")),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      // 1️⃣ Add booking to Firestore
      final bookingRef =
      await FirebaseFirestore.instance.collection("Requests").add({
        "username": UserData.name,
        "email": UserData.email,
        "phone": UserData.phone,
        "dob": UserData.dob,
        "vehicleNumber": UserData.vehicleNumber,
        "address": UserData.address,
        "problem": _problemController.text,
        "vehicleType": selectedVehicle,
        "latitude": _currentPosition!.latitude.toString(),
        "longitude": _currentPosition!.longitude.toString(),
        "status": "pending",
        "timestamp": FieldValue.serverTimestamp(),
        "mechanicId": "",
        "mechanicName": "",
        "mechanicAddress": "",
        "eta": "",
      });

      // 2️⃣ Update local ServicePage history
      ServicePage.problemHistory.insert(0, {
        'vehicle': selectedVehicle,
        'problem': _problemController.text,
        'timestamp': DateTime.now().toString(),
      });

      // 3️⃣ Send notification to the mechanic
      await _sendNotificationViaServer(
        mechanicFcmToken,
        "New Booking!",
        "${UserData.name} booked a $selectedVehicle service.",
      );

      _problemController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Booking request sent successfully")),
      );

      // 4️⃣ Navigate to Logo page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => Logo(
            bookingId: bookingRef.id,
          ),
        ),
      );
    } catch (e) {
      print("🔥 Error sending booking: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error sending booking: $e")),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _sendNotificationViaServer(
      String token, String title, String body) async {
    try {
      String serverIP =
      Platform.isAndroid ? "10.0.2.2" : "192.168.x.x"; // replace LAN IP
      final url = Uri.parse("http://$serverIP:3000/sendNotification");

      print("📡 Sending notification to: $token via $url");

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "fcmToken": token,
          "title": title,
          "body": body,
        }),
      );

      if (response.statusCode == 200) {
        print("✅ Notification sent successfully: ${response.body}");
      } else {
        print("❌ Server error: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      print("🔥 Error sending notification via server: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ClipOval(
                    child: Image.asset(
                      'assets/mecho.jpg',
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Row(
                    children: [
                      // Bookings Icon
                      IconButton(
                        icon: const Icon(Icons.book, size: 36, color: Colors.black),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ServicePage(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 10),
                      // Profile Icon
                      IconButton(
                        icon: const Icon(Icons.person, size: 40, color: Colors.black),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const ProfilePage()),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Text('Book a Service',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 40),
            GestureDetector(
              onTap: () => setState(() => selectedVehicle = 'Bike'),
              child: Container(
                decoration: BoxDecoration(
                  boxShadow: selectedVehicle == 'Bike'
                      ? [
                    BoxShadow(
                        color: Colors.yellow.shade600.withOpacity(0.8),
                        blurRadius: 25,
                        spreadRadius: 4)
                  ]
                      : [],
                ),
                child: Image.asset('assets/bike.png', height: 250),
              ),
            ),
            const SizedBox(height: 50),
            GestureDetector(
              onTap: () => setState(() => selectedVehicle = 'Car'),
              child: Container(
                decoration: BoxDecoration(
                  boxShadow: selectedVehicle == 'Car'
                      ? [
                    BoxShadow(
                        color: Colors.yellow.shade600.withOpacity(0.8),
                        blurRadius: 25,
                        spreadRadius: 4)
                  ]
                      : [],
                ),
                child: Image.asset('assets/car.png', height: 250),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: TextField(
                controller: _problemController,
                decoration: InputDecoration(
                  labelText: 'Enter Problem',
                  border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
            const SizedBox(height: 20),
            isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
              onPressed: _sendBooking,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.yellow[700],
                padding: const EdgeInsets.symmetric(
                    horizontal: 50, vertical: 15),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text(
                'Book',
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 30),
            if (_currentPosition != null)
              Text(
                "Current Location: ${_currentPosition!.latitude}, ${_currentPosition!.longitude}",
                style: const TextStyle(color: Colors.black87),
              ),
          ],
        ),
      ),
    );
  }
}
