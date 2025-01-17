import 'package:flutter/material.dart';

class SubscriptionPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Subscription Plans",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            // Container الأول - اللون الأحمر
            _buildColoredContainer(
              color: Colors.red,
              text: "Plan 1 : One Region",
              price: "Price: 310/month",
              logoPath: 'assets/Cairo_metro_logo.png',
            ),
            const SizedBox(height: 20),
            // Container الثاني - اللون الرمادي
            _buildColoredContainer(
              color: Colors.grey,
              text: "Plan 2 : Two Regions",
              price: "Price: 365/month",
              logoPath: 'assets/Cairo_metro_logo.png',
            ),
            const SizedBox(height: 20),
            // Container الثالث - اللون البرتقالي
            _buildColoredContainer(
              color: Colors.orange,
              text: "Plan 3 : 3 or 4 Regions",
              price: "Price: 425/month",
              logoPath: 'assets/Cairo_metro_logo.png',
            ),
            const SizedBox(height: 20),
            // Container الرابع - اللون الأزرق
            _buildColoredContainer(
              color: Colors.purple,
              text: "Plan 4 : 5 or 6 Regions",
              price: "Price: 600/month",
              logoPath: 'assets/Cairo_metro_logo.png',
            ),
          ],
        ),
      ),
    );
  }

  // دالة لإنشاء Container مخصص مع شعار ونصوص وزر
  Widget _buildColoredContainer({
    required Color color,
    required String text,
    required String price,
    required String logoPath,
  }) {
    return Center(
      child: Container(
        width: 250,
        height: 250, // زودنا الطول لاستيعاب الزر
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20), // زوايا مستديرة
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 8,
              offset: Offset(0, 4), // تأثير الظل
            ),
          ],
        ),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // الشعار
            Image.asset(
              logoPath,
              height: 50,
              width: 50,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 10), // مسافة بين الشعار والنص
            // النص الرئيسي
            Text(
              text,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 5),
            // نص السعر
            Text(
              price,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.normal,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            // زر الاشتراك
            ElevatedButton(
              onPressed: () {
                
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue, // خلفية زرقاء
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 20,
                ),
              ),
              child: const Text(
                "Subscribe Now!",
                style: TextStyle(fontSize: 14, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
