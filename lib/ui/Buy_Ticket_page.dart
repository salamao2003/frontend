import 'package:flutter/material.dart';
import 'package:egy_metro/cubit/ticket_data.dart';
import 'package:egy_metro/cubit/buy_ticket_logic.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BuyTicketPage extends StatefulWidget {
  @override
  _BuyTicketPageState createState() => _BuyTicketPageState();
}

class _BuyTicketPageState extends State<BuyTicketPage> {
  int _ticketCountFirst = 1;
  int _ticketCountSecond = 1;
  int _ticketCountThird = 1;
  int _ticketCountFourth = 1;

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('access_token');
    if (accessToken == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please login to purchase tickets'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.orange,
          ),
        );
      });
    }
  }

  Future<void> _purchaseTicket(String title, Color color, int ticketCount) async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('access_token');
    
    if (accessToken == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please login to purchase tickets'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    String ticketType = "";
    switch (title) {
      case "Basic Ticket":
        ticketType = "BASIC";
        break;
      case "Standard Ticket":
        ticketType = "STANDARD";
        break;
      case "Premium Ticket":
        ticketType = "PREMIUM";
        break;
      case "VIP Ticket":
        ticketType = "VIP";
        break;
    }

    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 20),
                Text(
                  'Purchasing $ticketCount ${title.toLowerCase()}(s)...',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );

    try {
      final result = await BuyTicketLogic.buyTicket(ticketType, ticketCount);
      
      // Hide loading indicator
      Navigator.pop(context);

      if (result['success']) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.green,
          ),
        );

        // Navigate back
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      // Hide loading indicator
      Navigator.pop(context);
      
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: ${e.toString()}"),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Buy Tickets",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white
          ),
        ),
        backgroundColor: Colors.blue,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(15),
            bottomRight: Radius.circular(15),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue.shade50,
              Colors.white,
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  "Select Your Ticket",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _buildTicketCard(
                title: "Basic Ticket",
                subtitle: "Up to 9 stations",
                price: "8",
                color: Colors.yellow.shade600,
                ticketCount: _ticketCountFirst,
                onIncrease: () => setState(() => _ticketCountFirst++),
                onDecrease: () => setState(() {
                  if (_ticketCountFirst > 1) _ticketCountFirst--;
                }),
                isPopular: false,
              ),
              _buildTicketCard(
                title: "Standard Ticket",
                subtitle: "Up to 16 stations",
                price: "10",
                color: Colors.green,
                ticketCount: _ticketCountSecond,
                onIncrease: () => setState(() => _ticketCountSecond++),
                onDecrease: () => setState(() {
                  if (_ticketCountSecond > 1) _ticketCountSecond--;
                }),
                isPopular: true,
              ),
              _buildTicketCard(
                title: "Premium Ticket",
                subtitle: "Up to 23 stations",
                price: "15",
                color: Colors.red,
                ticketCount: _ticketCountThird,
                onIncrease: () => setState(() => _ticketCountThird++),
                onDecrease: () => setState(() {
                  if (_ticketCountThird > 1) _ticketCountThird--;
                }),
                isPopular: false,
              ),
              _buildTicketCard(
                title: "VIP Ticket",
                subtitle: "Up to 39 stations",
                price: "20",
                color: Colors.lightBlue,
                ticketCount: _ticketCountFourth,
                onIncrease: () => setState(() => _ticketCountFourth++),
                onDecrease: () => setState(() {
                  if (_ticketCountFourth > 1) _ticketCountFourth--;
                }),
                isPopular: false,
              ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTicketCard({
    required String title,
    required String subtitle,
    required String price,
    required Color color,
    required int ticketCount,
    required VoidCallback onIncrease,
    required VoidCallback onDecrease,
    required bool isPopular,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.2),
                  spreadRadius: 2,
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.9),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            Text(
                              subtitle,
                              style: const TextStyle(
                                color: Colors.black87,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Row(
                            children: [
                              Text(
                                price,
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              const Text(
                                " EGP",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                          const Text(
                            "per ticket",
                            style: TextStyle(
                              color: Colors.black87,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Counter and Buy Button
                Container(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              onPressed: onDecrease,
                              icon: const Icon(Icons.remove),
                              color: Colors.blue,
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              child: Text(
                                '$ticketCount',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: onIncrease,
                              icon: const Icon(Icons.add),
                              color: Colors.blue,
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () => _purchaseTicket(title, color, ticketCount),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: color,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.shopping_cart_outlined, color: Colors.white),
                            const SizedBox(width: 8),
                            Text(
                              "Buy Now",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: color == Colors.yellow.shade100
                                    ? Colors.black87
                                    : Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (isPopular)
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.star,
                      color: Colors.white,
                      size: 16,
                    ),
                    SizedBox(width: 4),
                    Text(
                      "POPULAR",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}