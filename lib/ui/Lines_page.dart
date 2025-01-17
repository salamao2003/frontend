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
            // شعار المترو أعلى الصفحة
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Image.asset(
                'assets/Cairo_metro_logo.png', // صورة شعار المترو
                height: 80,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 20),
            // InteractiveViewer لتكبير وتصغير صورة خطوط المترو
            Center(
              child: InteractiveViewer(
                panEnabled: true, // السماح بتحريك الصورة
                minScale: 1.0, // الحد الأدنى للتكبير
                maxScale: 4.0, // الحد الأقصى للتكبير
                child: Image.asset(
                  'assets/Cairo_Metro_Map.png', // صورة خطوط المترو
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
