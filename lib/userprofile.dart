import 'dart:io';
import 'package:flutter/material.dart';
import 'edit.dart';
import 'login.dart';
import 'form.dart'; // ✅ Import UserData
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// ✅ Global store for profile photo
class ProfileStore {
  static String? profileImagePath; // local only
}

class UserProfile extends StatefulWidget {
  const UserProfile({super.key});

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  late String name = '';
  late String email = '';
  late String phone = '';
  late String address = '';
  late String vehicleNumber = '';
  late String dob = '';

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserDataFromFirestore();
  }

  Future<void> _loadUserDataFromFirestore() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        final snapshot = await FirebaseFirestore.instance
            .collection('Users')
            .doc(currentUser.uid)
            .get();

        if (snapshot.exists) {
          final data = snapshot.data()!;
          setState(() {
            name = data['name'] ?? UserData.name;
            email = data['email'] ?? UserData.email;
            phone = data['phone'] ?? UserData.phone;
            address = data['address'] ?? UserData.address;
            vehicleNumber = data['vehicleNumber'] ?? UserData.vehicleNumber;
            dob = data['dob'] ?? UserData.dob;
            isLoading = false;
          });

          // ✅ Update UserData global store too
          UserData.name = name;
          UserData.email = email;
          UserData.phone = phone;
          UserData.address = address;
          UserData.vehicleNumber = vehicleNumber;
          UserData.dob = dob;
        } else {
          _loadFromLocal(); // fallback if doc doesn’t exist
        }
      } else {
        _loadFromLocal();
      }
    } catch (e) {
      _loadFromLocal();
    }
  }

  void _loadFromLocal() {
    setState(() {
      name = UserData.name.isNotEmpty ? UserData.name : 'Not provided';
      email = UserData.email.isNotEmpty ? UserData.email : 'Not provided';
      phone = UserData.phone.isNotEmpty ? UserData.phone : 'Not provided';
      address = UserData.address.isNotEmpty ? UserData.address : 'Not provided';
      vehicleNumber =
      UserData.vehicleNumber.isNotEmpty ? UserData.vehicleNumber : 'Not provided';
      dob = UserData.dob.isNotEmpty ? UserData.dob : 'Not provided';
      isLoading = false;
    });
  }

  Widget buildField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 16, color: Colors.black54)),
          const SizedBox(height: 1),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300, width: 2),
              borderRadius: BorderRadius.circular(12),
              color: Colors.white,
            ),
            child: Text(value, style: const TextStyle(fontSize: 18)),
          ),
        ],
      ),
    );
  }

  Future<void> navigateToEdit() async {
    final updatedData = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const EditProfilePage()),
    );

    if (updatedData != null) {
      setState(() {
        name = updatedData['name'] ?? name;
        email = updatedData['email'] ?? email;
        phone = updatedData['phone'] ?? phone;
        address = updatedData['address'] ?? address;
        vehicleNumber = updatedData['vehicleNumber'] ?? vehicleNumber;
        dob = updatedData['dob'] ?? dob;

        // ✅ Update UserData
        UserData.name = name;
        UserData.email = email;
        UserData.phone = phone;
        UserData.address = address;
        UserData.vehicleNumber = vehicleNumber;
        UserData.dob = dob;

        // ✅ Update Firestore too
        final currentUser = FirebaseAuth.instance.currentUser;
        if (currentUser != null) {
          FirebaseFirestore.instance.collection('Users').doc(currentUser.uid).set({
            "name": name,
            "email": email,
            "phone": phone,
            "address": address,
            "vehicleNumber": vehicleNumber,
            "dob": dob,
          }, SetOptions(merge: true));
        }

        // ✅ Update local profile photo
        if (updatedData['profileImagePath'] != null) {
          ProfileStore.profileImagePath = updatedData['profileImagePath'];
        }
      });
    }
  }

  Future<void> logout() async {
    try {
      await FirebaseAuth.instance.signOut();
      UserData.clear();
      ProfileStore.profileImagePath = null;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
            (Route<dynamic> route) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Logout failed: $e")),
      );
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("My Profile"),
        backgroundColor: const Color(0xFFF9B43E),
        centerTitle: true,
        elevation: 0,
      ),
      body: ListView(
        children: [
          const SizedBox(height: 20),
          Center(
            child: CircleAvatar(
              radius: 70,
              backgroundColor: Colors.grey,
              backgroundImage: ProfileStore.profileImagePath != null
                  ? FileImage(File(ProfileStore.profileImagePath!))
                  : null,
              child: ProfileStore.profileImagePath == null
                  ? const Icon(Icons.person, size: 80, color: Colors.white)
                  : null,
            ),
          ),
          const SizedBox(height: 10),
          buildField('Name', name),
          buildField('Email', email),
          buildField('Phone Number', phone),
          buildField('Address', address),
          buildField('Vehicle Number', vehicleNumber),
          buildField('Date of Birth', dob),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ElevatedButton(
              onPressed: navigateToEdit,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF9B43E),
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Edit Profile',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 5),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: OutlinedButton.icon(
              onPressed: logout,
              icon: const Icon(Icons.logout, color: Colors.red),
              label: const Text(
                'Log Out',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                side: const BorderSide(color: Colors.red),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
