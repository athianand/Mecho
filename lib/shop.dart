import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart'; // ✅ For calling
import 'status.dart';
import 'select.dart';// Your status page

class ShopPage extends StatefulWidget {
  final String bookingId; // Booking document ID
  const ShopPage({super.key, required this.bookingId});

  @override
  State<ShopPage> createState() => _ShopPageState();
}

class _ShopPageState extends State<ShopPage> {
  String mechanicName = "";
  String mechanicId = "";
  String mechanicAddress = "";
  String mechanicPhone = "";
  String garageName = "Garage Name Not Provided"; // ✅ default
  String eta = "";
  double rating = 4.5; // demo rating
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchMechanicDetails();
  }

  Future<void> _fetchMechanicDetails() async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection("Requests")
          .doc(widget.bookingId)
          .get();

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;

        String mechId = (data["mechanicid"] ?? "").toString();

        // fetch mechanic details
        DocumentSnapshot mechDoc = await FirebaseFirestore.instance
            .collection("mechanicDetails")
            .doc(mechId)
            .get();

        String phone = "";
        String garage = "Garage Name Not Provided";
        if (mechDoc.exists) {
          final mechData = mechDoc.data() as Map<String, dynamic>;
          phone = (mechData["phone"] ?? "").toString();
          garage = (mechData["garage"]?.toString().trim().isEmpty ?? true)
              ? "Garage Name Not Provided"
              : mechData["garage"];
        }

        setState(() {
          mechanicName = (data["mechanicname"] ?? "Unknown Mechanic").toString();
          mechanicId = mechId;
          mechanicAddress = (data["address"] ?? "Not Available").toString();
          mechanicPhone = phone;
          garageName = garage;
          eta = (data["eta"] ?? "10 min").toString();
          isLoading = false;
        });
      } else {
        setState(() {
          mechanicName = "Not Found";
          mechanicId = "";
          mechanicAddress = "Not Found";
          mechanicPhone = "";
          garageName = "Garage Name Not Provided";
          eta = "--";
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error fetching mechanic: $e");
      setState(() {
        mechanicName = "Error";
        mechanicId = "";
        mechanicAddress = "Error";
        mechanicPhone = "";
        garageName = "Garage Name Not Provided";
        eta = "--";
        isLoading = false;
      });
    }
  }

  Future<void> _callMechanic() async {
    if (mechanicPhone.isNotEmpty) {
      final Uri uri = Uri(scheme: "tel", path: mechanicPhone);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        debugPrint("Could not launch dialer");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: ListView(
        children: [
          Page9(
            mechanicName: mechanicName,
            mechanicId: mechanicId,
            mechanicAddress: mechanicAddress,
            mechanicPhone: mechanicPhone,
            garageName: garageName,
            eta: eta,
            rating: rating,
            onCallTap: _callMechanic,
          ),
        ],
      ),
    );
  }
}

class Page9 extends StatelessWidget {
  final String mechanicName;
  final String mechanicId;
  final String mechanicAddress;
  final String mechanicPhone;
  final String garageName;
  final String eta;
  final double rating;
  final VoidCallback onCallTap;

  const Page9({
    super.key,
    required this.mechanicName,
    required this.mechanicId,
    required this.mechanicAddress,
    required this.mechanicPhone,
    required this.garageName,
    required this.eta,
    required this.rating,
    required this.onCallTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          height: 877,
          clipBehavior: Clip.antiAlias,
          decoration: ShapeDecoration(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
            shadows: const [
              BoxShadow(
                color: Color(0x3F000000),
                blurRadius: 4,
                offset: Offset(0, 4),
              )
            ],
          ),
          child: Stack(
            children: [
              // Header
              Positioned(
                left: 0,
                top: 0,
                child: Container(
                  width: 412,
                  height: 88,
                  decoration: const BoxDecoration(color: Color(0xFFF9B43E)),
                  child: Center(
                    child: Text(
                      mechanicName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),

              // Profile Icon
              Positioned(
                left: 133,
                top: 116,
                child: Container(
                  width: 147,
                  height: 152,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey.shade400,
                  ),
                  child: const Icon(
                    Icons.person,
                    size: 100,
                    color: Colors.white,
                  ),
                ),
              ),

              // ✅ Garage Name
              Positioned(
                left: 14,
                top: 300,
                child: Text(
                  garageName,
                  style: const TextStyle(
                    color: Color(0xFFF9B43E),
                    fontSize: 32,
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              // Mechanic Details
              Positioned(
                left: 16,
                top: 350,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.badge, color: Colors.black54),
                        const SizedBox(width: 8),
                        Text(
                          "Mechanic ID: $mechanicId",
                          style: const TextStyle(fontSize: 18),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.person, color: Colors.black54),
                        const SizedBox(width: 8),
                        Text(
                          "Mechanic Name: $mechanicName",
                          style: const TextStyle(fontSize: 18),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // ✅ Call Button only (no raw number)
                    ElevatedButton.icon(
                      onPressed: onCallTap,
                      icon: const Icon(Icons.call, color: Colors.white),
                      label: const Text("Call Mechanic"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                      ),
                    ),
                  ],
                ),
              ),

              // Address
              Positioned(
                left: 16,
                top: 480,
                child: SizedBox(
                  width: 350,
                  child: Text(
                    mechanicAddress,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ),
              ),

              // Rating
              Positioned(
                left: 16,
                top: 520,
                child: Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 28),
                    const SizedBox(width: 6),
                    Text(
                      rating.toStringAsFixed(1),
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),

              // Estimated arrival
              const Positioned(
                left: 16,
                top: 570,
                child: Text(
                  'Estimated arrival',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 24,
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              Positioned(
                left: 234,
                top: 570,
                child: Container(
                  width: 88,
                  height: 26,
                  decoration: ShapeDecoration(
                    color: Color(0xFFF3DE70),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      eta,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ),
                ),
              ),

              // CONFIRM Button
              Positioned(
                left: 81,
                top: 650,
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const StatusPage()),
                    );
                  },
                  child: Container(
                    width: 249,
                    height: 56,
                    decoration: ShapeDecoration(
                      color: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: const Center(
                      child: Text(
                        'CONFIRM',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // DECLINE Button
              // DECLINE Button
              Positioned(
                left: 81,
                top: 720,
                child: GestureDetector(
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SelectPage(), // ✅ Navigate to select.dart
                      ),
                    );
                  },
                  child: Container(
                    width: 249,
                    height: 56,
                    decoration: ShapeDecoration(
                      color: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: const Center(
                      child: Text(
                        'DECLINE',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
