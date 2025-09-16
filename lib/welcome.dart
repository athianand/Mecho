import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login.dart';
import 'select.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  Future<void> _logout(BuildContext context) async {
    try {
      // ✅ Sign out from Firebase
      await FirebaseAuth.instance.signOut();

      // ✅ Remove all previous routes and go to LoginScreen
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
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
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Welcome",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.red),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          width: width,
          height: height,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 30),
              const Text(
                'Welcome',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 40,
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'You have successfully registered',
                style: TextStyle(
                  color: Color.fromARGB(201, 0, 0, 0),
                  fontSize: 24,
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w400,
                ),
              ),
              SizedBox(height: height * 0.05),
              Center(
                child: Image.asset(
                  'assets/illu-2.png',
                  height: height * 0.30,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 20),
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    'You’re ready to book a service. Get started by exploring the options below',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color.fromARGB(201, 0, 0, 0),
                      fontSize: 20,
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              Center(
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SelectPage()),
                    );
                  },
                  child: Container(
                    width: width * 0.85,
                    height: 69,
                    margin: const EdgeInsets.only(bottom: 120),
                    decoration: ShapeDecoration(
                      color: const Color(0xFFF9B43E),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Center(
                      child: Text(
                        'EXPLORE OPTIONS',
                        style: TextStyle(
                          color: Color(0xFFFFFBFB),
                          fontSize: 28,
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
      ),
    );
  }
}
