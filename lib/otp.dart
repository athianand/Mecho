import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'form.dart';
import 'welcome.dart';
import 'login.dart';

class OtpPage extends StatefulWidget {
  final String phoneNumber;
  final String verificationId;

  const OtpPage({
    super.key,
    required this.phoneNumber,
    required this.verificationId,
  });

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  final TextEditingController otpController = TextEditingController();
  String otpCode = "";
  bool isLoading = false;

  Future<void> verifyOtp() async {
    if (otpCode.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter a valid 6-digit OTP ❌")),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: widget.verificationId,
        smsCode: otpCode,
      );

      // ✅ Sign in with credential
      UserCredential userCred =
      await FirebaseAuth.instance.signInWithCredential(credential);
      User? user = userCred.user;

      if (user == null) throw Exception("User not found");

      // 🔍 Check if user profile exists in Firestore
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid)
          .get();

      if (!mounted) return;

      if (snapshot.exists) {
        // ✅ Returning user → WelcomePage
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const WelcomePage()),
              (route) => false,
        );
      } else {
        // ✅ First-time user → FormPage
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => FormPage()),
              (route) => false,
        );
      }
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("OTP Error: ${e.message}")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Something went wrong: $e")),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final defaultPinTheme = PinTheme(
      width: size.width * 0.15,
      height: size.height * 0.07,
      textStyle: TextStyle(
        fontSize: size.height * 0.03,
        color: Colors.black,
        fontWeight: FontWeight.w600,
      ),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(6),
      ),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: size.width * 0.06),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: size.height * 0.05),
                Text(
                  "OTP Verification",
                  style: TextStyle(
                    fontSize: size.height * 0.035,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: size.height * 0.02),
                Text(
                  "Enter the OTP sent to ${widget.phoneNumber}",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: size.height * 0.02,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: size.height * 0.04),
                Image.asset(
                  "assets/illu-3.png",
                  height: size.height * 0.3,
                  fit: BoxFit.contain,
                ),
                SizedBox(height: size.height * 0.04),
                Pinput(
                  controller: otpController,
                  length: 6,
                  onChanged: (value) => otpCode = value,
                  onCompleted: (value) => otpCode = value,
                  defaultPinTheme: defaultPinTheme,
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: size.height * 0.04),
                isLoading
                    ? const CircularProgressIndicator(color: Colors.orange)
                    : ElevatedButton(
                  onPressed: verifyOtp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    minimumSize: Size(size.width * 0.8, size.height * 0.06),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    "Verify",
                    style: TextStyle(
                      fontSize: size.height * 0.025,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
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
}
