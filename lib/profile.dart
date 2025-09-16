import 'package:flutter/material.dart';
import 'userprofile.dart'; // existing profile page
import 'service.dart';
import 'offer.dart';
import 'form.dart'; // ✅ UserData
import 'login.dart'; // ✅ for navigation after logout
import 'package:firebase_auth/firebase_auth.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  Future<void> _performLogout(BuildContext context) async {
    try {
      // ✅ Sign out from Firebase
      await FirebaseAuth.instance.signOut();

      // ✅ Clear local data
      UserData.clear();
      ProfileStore.profileImagePath = null;

      // ✅ Navigate to login
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
            (route) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Logout failed: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final options = [
      {'icon': Icons.person, 'text': 'Profile'},
      {'icon': Icons.directions_car, 'text': 'Service History'},
      {'icon': Icons.percent, 'text': 'Offers & Discounts'},
      {'icon': Icons.logout, 'text': 'Log Out'},
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: ListView(
        children: [
          Container(
            width: 412,
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
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Stack(
              children: [
                // Profile image
                Positioned(
                  left: 31,
                  top: 99,
                  child: Container(
                    width: 79,
                    height: 79,
                    decoration: const ShapeDecoration(
                      color: Colors.grey,
                      shape: OvalBorder(),
                    ),
                    child: const Icon(
                      Icons.person,
                      size: 50,
                      color: Colors.white,
                    ),
                  ),
                ),

                // Name
                const Positioned(
                  left: 132,
                  top: 108,
                  child: Text(
                    'David',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 40,
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),

                // Option containers with icons
                for (int i = 0; i < options.length; i++)
                  Positioned(
                    left: 19,
                    top: 224 + i * 80,
                    child: GestureDetector(
                      onTap: () async {
                        if (options[i]['text'] == 'Profile') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const UserProfile(),
                            ),
                          );
                        } else if (options[i]['text'] ==
                            'Service History') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ServicePage(),
                            ),
                          );
                        } else if (options[i]['text'] ==
                            'Offers & Discounts') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const OffersPage(),
                            ),
                          );
                        } else if (options[i]['text'] == 'Log Out') {
                          // ✅ Unified Log Out handling
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text("Log Out"),
                              content: const Text(
                                  "Are you sure you want to log out?"),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context),
                                  child: const Text("Cancel"),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    Navigator.pop(context); // close dialog
                                    await _performLogout(context);
                                  },
                                  child: const Text("Log Out"),
                                ),
                              ],
                            ),
                          );
                        }
                      },
                      child: Container(
                        width: 374,
                        height: 76,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            const SizedBox(width: 20),
                            Icon(
                              options[i]['icon'] as IconData,
                              size: 30,
                              color: Colors.yellow,
                            ),
                            const SizedBox(width: 50),
                            Text(
                              options[i]['text'] as String,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
