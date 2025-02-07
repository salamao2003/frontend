import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart'; // استيراد مكتبة gestures
import 'buy_ticket_page.dart'; // تأكد من استيراد صفحة BuyTicketPage
import 'animated_page_transition.dart';
class MyTicketsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "My Tickets",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(height: 50),
                  // Container الأول (الخلفية الصفراء)
                  _buildTicketContainer(
                    color: Colors.yellow,
                    ticketText: "Yellow Tickets",
                    logoPath: 'assets/Cairo_metro_logo.png',
                    onViewTickets: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Viewing Yellow Tickets")),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  // Container الثاني (الخلفية الخضراء)
                  _buildTicketContainer(
                    color: Colors.green,
                    ticketText: "Green Tickets",
                    logoPath: 'assets/Cairo_metro_logo.png',
                    onViewTickets: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Viewing Green Tickets")),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  // Container الثالث (الخلفية الوردية)
                  _buildTicketContainer(
                    color: Colors.pink,
                    ticketText: "Red Tickets",
                    logoPath: 'assets/Cairo_metro_logo.png',
                    onViewTickets: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Viewing Red Tickets")),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          // النص في أسفل الصفحة
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: RichText(
              text: TextSpan(
                text: "Don't have tickets? ",
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                ),
                children: [
                  TextSpan(
                    text: "Buy your ticket now !",
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        navigateWithAnimation(context, BuyTicketPage());
                      },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTicketContainer({
    required Color color,
    required String ticketText,
    required String logoPath,
    required VoidCallback onViewTickets,
  }) {
    return Center(
      child: Container(
        width: 250,
        height: 200,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // اللوجو
            Image.asset(
              logoPath,
              height: 50,
              width: 50,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 10),
            // النص الخاص بنوع التذاكر
            Text(
              ticketText,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 16),
            // زر View Tickets
            ElevatedButton(
              onPressed: onViewTickets,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 20,
                ),
              ),
              child: const Text(
                "View Tickets",
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
