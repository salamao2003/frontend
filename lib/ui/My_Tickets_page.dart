import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart'; 
import 'Blue_Tickets_page.dart';
import 'Red_Tickets_page.dart';
import 'buy_ticket_page.dart'; 
import 'animated_page_transition.dart';
import 'Yellow_Tickets_page.dart';
import 'Green_Tickets_page.dart';
import '../cubit/ticket_data.dart';
class MyTicketsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue.shade100,
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Custom App Bar
              Container(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            spreadRadius: 1,
                            blurRadius: 5,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    const SizedBox(width: 20),
                    const Text(
                      "My Tickets",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              // Tickets Summary
              Container(
                margin: const EdgeInsets.all(20),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 5,
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildTicketCounter("Total\nTickets", 
                        "${TicketData.yellowTickets + TicketData.greenTickets + TicketData.redTickets + TicketData.blueTickets}"),
                    const VerticalDivider(thickness: 1),
                    _buildTicketCounter("Active\nTickets", "0"),
                    const VerticalDivider(thickness: 1),
                    _buildTicketCounter("Used\nTickets", "0"),
                  ],
                ),
              ),

              // Tickets Grid
              Expanded(
                child: GridView.count(
                  padding: const EdgeInsets.all(20),
                  crossAxisCount: 2,
                  childAspectRatio: 0.85,
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
                  children: [
                    _buildTicketCard(
                      context,
                      "Basic",
                      "Yellow Tickets",
                      TicketData.yellowTickets,
                      Colors.yellow.shade600,
                      () => navigateWithAnimation(context, YellowTicketsPage()),
                      Icons.confirmation_number_outlined,
                    ),
                    _buildTicketCard(
                      context,
                      "Standard",
                      "Green Tickets",
                      TicketData.greenTickets,
                      Colors.green,
                      () => navigateWithAnimation(context, GreenTicketsPage()),
                      Icons.confirmation_num_outlined,
                    ),
                    _buildTicketCard(
                      context,
                      "Premium",
                      "Red Tickets",
                      TicketData.redTickets,
                      Colors.red,
                      () => navigateWithAnimation(context, RedTicketsPage()),
                      Icons.confirmation_num_outlined,
                    ),
                    _buildTicketCard(
                      context,
                      "VIP",
                      "Blue Tickets",
                      TicketData.blueTickets,
                      Colors.blue,
                      () => navigateWithAnimation(context, BlueTicketsPage()),
                      Icons.confirmation_num_outlined,
                    ),
                  ],
                ),
              ),

              // Buy Tickets Button
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                child: ElevatedButton(
                  onPressed: () => navigateWithAnimation(context, BuyTicketPage()),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 5,
                  ),
                  child: const Text(
                    "Buy New Tickets",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,color: Colors.white
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTicketCounter(String title, String count) {
    return Column(
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          count,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildTicketCard(
    BuildContext context,
    String type,
    String title,
    int count,
    Color color,
    VoidCallback onTap,
    IconData icon,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 30,
                color: color,
              ),
            ),
            const SizedBox(height: 15),
            Text(
              type,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 15,
                vertical: 5,
              ),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Text(
                "$count tickets",
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}