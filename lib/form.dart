import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'welcome.dart';

class UserData {
  static String name = '';
  static String email = '';
  static String dob = '';
  static String vehicleNumber = '';
  static String address = '';
  static String phone = '';
  static String? photo;

  static bool get isLoggedIn {
    return name.isNotEmpty &&
        email.isNotEmpty &&
        dob.isNotEmpty &&
        vehicleNumber.isNotEmpty &&
        address.isNotEmpty &&
        phone.isNotEmpty;
  }

  static void clear() {
    name = '';
    email = '';
    dob = '';
    vehicleNumber = '';
    address = '';
    phone = '';
    photo = null;
  }
}

class FormPage extends StatefulWidget {
  const FormPage({super.key});

  @override
  State<FormPage> createState() => _FormPageState();
}

class _FormPageState extends State<FormPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _vehicleController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    if (UserData.isLoggedIn) {
      _nameController.text = UserData.name;
      _emailController.text = UserData.email;
      _dobController.text = UserData.dob;
      _vehicleController.text = UserData.vehicleNumber;
      _addressController.text = UserData.address;
      _phoneController.text = UserData.phone;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _dobController.dispose();
    _vehicleController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _saveToFirestore() async {
    try {
      final userDoc = FirebaseFirestore.instance
          .collection('User')
          .doc(_emailController.text);

      // ✅ Save to User collection (using email as document id)
      await userDoc.set({
        'name': _nameController.text,
        'email': _emailController.text,
        'phone': _phoneController.text,
        'dob': _dobController.text,
        'vehicleNumber': _vehicleController.text,
        'address': _addressController.text,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // ✅ Also save to Requests collection with same userId
      await FirebaseFirestore.instance.collection('Requests').add({
        'userId': userDoc.id,
        'username': _nameController.text,
        'email': _emailController.text,
        'phone': _phoneController.text,
        'dob': _dobController.text,
        'vehicleNumber': _vehicleController.text,
        'address': _addressController.text,
        'vehicleType': '',
        'problem': '',
        'status': 'profile_saved',
        'timestamp': FieldValue.serverTimestamp(),
        'mechanicId': '',
        'mechanicName': '',
      });

      print("✅ User + initial request saved to Firestore");

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile saved successfully")),
      );
    } catch (e) {
      print("❌ Error saving user: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to save data: $e")),
      );
    }
  }

  bool _validateFields() {
    if (_nameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _phoneController.text.isEmpty ||
        _dobController.text.isEmpty ||
        _vehicleController.text.isEmpty ||
        _addressController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("All fields are required")),
      );
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            width: double.infinity,
            height: screenHeight,
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 30),
                Center(
                  child: ClipOval(
                    child: Image.asset(
                      'assets/mecho.jpg',
                      width: 120,
                      height: 120,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Enter your details to proceed",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 34),
                _buildLabel("Name", required: true),
                _buildTextField(_nameController),
                const SizedBox(height: 18),
                _buildLabel("Email", required: true),
                _buildTextField(_emailController),
                const SizedBox(height: 18),
                _buildLabel("Phone Number", required: true),
                _buildTextField(_phoneController, keyboard: TextInputType.phone),
                const SizedBox(height: 18),
                _buildLabel("DOB", required: true),
                _buildDOBField(),
                const SizedBox(height: 18),
                _buildLabel("Vehicle Number", required: true),
                _buildTextField(_vehicleController),
                const SizedBox(height: 18),
                _buildLabel("Address", required: true),
                _buildTextField(_addressController),
                const SizedBox(height: 38),
                SizedBox(
                  width: double.infinity,
                  height: screenHeight * 0.06,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFA629),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () async {
                      if (_validateFields()) {
                        // Save locally
                        UserData.name = _nameController.text;
                        UserData.email = _emailController.text;
                        UserData.dob = _dobController.text;
                        UserData.vehicleNumber = _vehicleController.text;
                        UserData.address = _addressController.text;
                        UserData.phone = _phoneController.text;

                        // Save to Firestore
                        await _saveToFirestore();

                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const WelcomePage(),
                          ),
                        );
                      }
                    },
                    child: const Text(
                      "Save",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text, {bool required = false}) {
    return Row(
      children: [
        Text(
          text,
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (required)
          const Text(
            " *",
            style: TextStyle(
              color: Colors.red,
              fontSize: 18,
            ),
          ),
      ],
    );
  }

  Widget _buildTextField(TextEditingController controller,
      {TextInputType keyboard = TextInputType.text}) {
    return TextField(
      controller: controller,
      keyboardType: keyboard,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Widget _buildDOBField() {
    return TextField(
      controller: _dobController,
      readOnly: true,
      decoration: InputDecoration(
        hintText: "Select Date of Birth",
        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        suffixIcon: const Icon(Icons.calendar_month),
      ),
      onTap: () async {
        DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: DateTime(2000),
          firstDate: DateTime(1900),
          lastDate: DateTime.now(),
        );

        if (pickedDate != null) {
          setState(() {
            _dobController.text =
            "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
          });
        }
      },
    );
  }
}
