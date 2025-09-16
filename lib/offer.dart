import 'package:flutter/material.dart';

class OffersPage extends StatelessWidget {
  const OffersPage({super.key});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Back button & title
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.02, // minimal padding for alignment
                vertical: screenHeight * 0.015,
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  SizedBox(width: screenWidth * 0.02),
                  Text(
                    "Offers & Discounts",
                    style: TextStyle(
                      fontSize: screenWidth * 0.07,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),

            // Scrollable content
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                child: ListView(
                  children: [
                    _buildOfferCard(
                      icon: Icons.percent_rounded,
                      iconBgColor: Colors.orange,
                      title: "₹100 OFF",
                      subtitle: "spend ₹500 or more",
                      screenWidth: screenWidth,
                    ),
                    SizedBox(height: screenHeight * 0.015),

                    _buildOfferCard(
                      icon: Icons.percent,
                      iconBgColor: Colors.orange,
                      title: "20% OFF",
                      subtitle: "On any service",
                      screenWidth: screenWidth,
                    ),
                    SizedBox(height: screenHeight * 0.015),

                    _buildOfferCard(
                      icon: Icons.local_offer,
                      iconBgColor: Colors.orange,
                      title: "15% OFF",
                      subtitle: "On parts",
                      screenWidth: screenWidth,
                    ),
                    SizedBox(height: screenHeight * 0.015),

                    _buildOfferCard(
                      icon: Icons.shopping_bag,
                      iconBgColor: Colors.orange,
                      title: "10% OFF",
                      subtitle: "On first order",
                      screenWidth: screenWidth,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOfferCard({
    required IconData icon,
    required Color iconBgColor,
    required String title,
    required String subtitle,
    required double screenWidth,
  }) {
    return Container(
      padding: EdgeInsets.all(screenWidth * 0.04),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFEBEBEB), width: 2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(screenWidth * 0.03),
            decoration: BoxDecoration(
              color: iconBgColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconBgColor, size: screenWidth * 0.08),
          ),
          SizedBox(width: screenWidth * 0.04),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: screenWidth * 0.05,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: screenWidth * 0.04,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}