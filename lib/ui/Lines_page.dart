import 'package:flutter/material.dart';

class LinesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Metro Lines",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // إضافة شعار المترو أعلى الصفحة
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Image.asset(
                'assets/Cairo_metro_logo.png', // صورة شعار المترو
                height: 80, // تعديل الارتفاع حسب الحاجة
                fit: BoxFit.contain,
              ),
            ),
            SizedBox(height: 20,),
            Center(
              child: Image.asset(
                'assets/Cairo_Metro_Map.png', // صورة خطوط المترو
                fit: BoxFit.contain,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
