import 'package:flutter/material.dart';
import 'dart:async'; // لإدارة التأخير (Timer)
import 'login_page.dart'; // استبدل بـ الصفحة التي تريد الانتقال إليها

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // بدء Timer للانتقال بعد فترة زمنية محددة
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()), // الصفحة التالية
      );
    });

    return Scaffold(
      backgroundColor: Colors.blue, // اللون الخلفي للـ Splash Screen
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/Cairo_metro_logo.png', // المسار الخاص بصورة شعار المترو
              width: 150, // ضبط العرض
              height: 150, // ضبط الطول
            ),
            const SizedBox(height: 20),
            const Text(
              "Welcome to Metro App", // النص أسفل الصورة
              style: TextStyle(
                fontSize: 24,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
