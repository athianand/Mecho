import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'shop.dart';

class Logo extends StatefulWidget {
  final String bookingId; // Booking document ID
  const Logo({super.key, required this.bookingId});

  @override
  _LogoState createState() => _LogoState();
}

class _LogoState extends State<Logo> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _subscription;
  bool _navigated = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat();

    // Listen to the booking document and navigate when status == 'accepted'
    _subscription = FirebaseFirestore.instance
        .collection('Requests')
        .doc(widget.bookingId)
        .snapshots()
        .listen((snapshot) {
      if (_navigated) return; // avoid multiple navigations
      if (!snapshot.exists) return;
      final data = snapshot.data();
      if (data == null) return;
      final status = data['status'] as String?;

      // Navigate only if the booking is accepted
      if (status == 'accepted') {
        _navigated = true;
        if (mounted) {
          _controller.stop();
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => ShopPage(
                bookingId: widget.bookingId, // pass bookingId to ShopPage
              ),
            ),
          );
        }
      }
    }, onError: (err) {
      print('Logo stream error: $err');
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: LayoutBuilder(
          builder: (context, constraints) {
            double baseSize = math.min(constraints.maxWidth, constraints.maxHeight);

            double ringSize;
            double logoSize;

            if (baseSize < 500) {
              ringSize = baseSize * 0.6;
              logoSize = baseSize * 0.45;
            } else if (baseSize < 900) {
              ringSize = baseSize * 0.4;
              logoSize = baseSize * 0.3;
            } else {
              ringSize = baseSize * 0.25;
              logoSize = baseSize * 0.18;
            }

            return SizedBox(
              width: ringSize,
              height: ringSize,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  RotationTransition(
                    turns: Tween(begin: 0.0, end: 1.0).animate(_controller),
                    child: ClipOval(
                      child: Container(
                        color: Colors.white,
                        child: Image.asset(
                          'assets/circle.png',
                          width: ringSize,
                          height: ringSize,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(ringSize * 0.07),
                    child: ClipOval(
                      child: Container(
                        color: Colors.white,
                        child: Image.asset(
                          'assets/logoc.png',
                          width: logoSize,
                          height: logoSize,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
