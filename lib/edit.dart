import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'form.dart'; // ✅ UserData
import 'userprofile.dart' show ProfileStore;

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _addressController;
  late TextEditingController _vehicleController;
  late TextEditingController _dobController;

  File? _profileImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: UserData.name);
    _emailController = TextEditingController(text: UserData.email);
    _addressController = TextEditingController(text: UserData.address);
    _vehicleController = TextEditingController(text: UserData.vehicleNumber);
    _dobController = TextEditingController(text: UserData.dob);

    if (ProfileStore.profileImagePath != null) {
      _profileImage = File(ProfileStore.profileImagePath!);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _vehicleController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _profileImage = File(image.path);
      });
    }
  }

  Future<void> _confirmChanges() async {
    // ✅ Update local store
    UserData.name = _nameController.text;
    UserData.email = _emailController.text;
    UserData.address = _addressController.text;
    UserData.vehicleNumber = _vehicleController.text;
    UserData.dob = _dobController.text;

    if (_profileImage != null) {
      ProfileStore.profileImagePath = _profileImage!.path;
    }

    // ✅ Update Firestore (User collection)
    try {
      final query = await FirebaseFirestore.instance
          .collection('User')
          .where('email', isEqualTo: UserData.email)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        await FirebaseFirestore.instance
            .collection('User')
            .doc(query.docs.first.id)
            .update({
          'name': UserData.name,
          'email': UserData.email,
          'address': UserData.address,
          'vehicleNumber': UserData.vehicleNumber,
          'dob': UserData.dob,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      print("Error updating Firestore: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to update profile: $e")),
      );
    }

    // ✅ Return updated data back to UserProfile
    Navigator.pop(context, {
      'name': UserData.name,
      'email': UserData.email,
      'address': UserData.address,
      'vehicleNumber': UserData.vehicleNumber,
      'dob': UserData.dob,
      'profileImagePath': ProfileStore.profileImagePath,
    });
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20), // 🔽 reduced space
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 16, color: Colors.black54)),
          const SizedBox(height: 4),
          TextField(
            controller: controller,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300, width: 2),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Cancel → go back without changes
            },
            child: const Text(
              "Cancel",
              style: TextStyle(color: Colors.red, fontSize: 16),
            ),
          ),
        ],
      ),
      body: ListView(
        children: [
          const SizedBox(height: 20),
          Center(
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.grey.shade300,
                  backgroundImage: _profileImage != null
                      ? FileImage(_profileImage!)
                      : (ProfileStore.profileImagePath != null
                      ? FileImage(File(ProfileStore.profileImagePath!))
                      : null),
                  child: (_profileImage == null && ProfileStore.profileImagePath == null)
                      ? const Icon(Icons.person, size: 60, color: Colors.white)
                      : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: _pickImage,
                    child: CircleAvatar(
                      radius: 18,
                      backgroundColor: Colors.orange,
                      child: const Icon(Icons.edit, color: Colors.white, size: 20),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _buildTextField('Name', _nameController),
          _buildTextField('Email', _emailController),
          _buildTextField('Address', _addressController),
          _buildTextField('Bike No', _vehicleController),
          _buildTextField('Date of Birth', _dobController),
          const SizedBox(height: 30),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ElevatedButton(
              onPressed: _confirmChanges,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF9B43E),
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text(
                'Confirm',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
