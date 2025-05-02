import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'Blue_Tickets_page.dart';
import 'Red_Tickets_page.dart';
import 'buy_ticket_page.dart';
import 'animated_page_transition.dart';
import 'Yellow_Tickets_page.dart';
import 'Green_Tickets_page.dart';
import '../services/ticket_service.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
class MyTicketsPage extends StatefulWidget {
  @override
  _MyTicketsPageState createState() => _MyTicketsPageState();
}

class _MyTicketsPageState extends State<MyTicketsPage> {
  Timer? _timer;
  bool isLoading = true;
  Map<String, int> ticketCounts = {
    'total': 0,
    'active': 0,
    'used': 0,
    'basic': 0,
    'standard': 0,
    'premium': 0,
    'vip': 0,
  };

  @override
  void initState() {
    super.initState();
    _loadTickets();
     _checkForPendingUpgrades();
     Timer.periodic(Duration(seconds: 30), (_) {
  if (mounted) {
    _checkForPendingUpgrades();
  }
});
  }

@override
void dispose() {
  _timer?.cancel();
  super.dispose();
}

Future<void> _checkForPendingUpgrades() async {
  try {
    final token = await SharedPreferences.getInstance()
        .then((prefs) => prefs.getString('access_token'));
        
    if (token == null) return;

    final response = await http.get(
      Uri.parse('https://backend-54v5.onrender.com/api/tickets/pending-upgrades/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      
      if (data['has_pending_upgrades'] == true && data['ticket'] != null && data['upgrade_details'] != null) {
        final ticketId = data['ticket']['id'].toString();
        final upgradeDetails = data['upgrade_details'];
        
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _showUpgradeDialog({
            'ticket_id': ticketId, // اضافة ticket id
            'ticket_number': upgradeDetails['ticket_number'],
            'new_ticket_type': upgradeDetails['new_ticket_type'],
            'upgrade_price': upgradeDetails['upgrade_price'],
            'stations_count': upgradeDetails['stations_count'],
          });
        });
      }
    }
  } catch (e) {
    print('Error checking for pending upgrades: $e');
  }
}

void _showUpgradeDialog(Map<String, dynamic> upgradeDetails) {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('Ticket Upgrade Required'),
      content: Text(
        'You need to upgrade ticket #${upgradeDetails['ticket_number']} to ${upgradeDetails['new_ticket_type']}.\nPrice: ${upgradeDetails['upgrade_price']} EGP',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () async {
            Navigator.pop(context);
            
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (BuildContext context) {
                return const Center(child: CircularProgressIndicator());
              },
            );

            try {
              final result = await TicketService.upgradeTicketWithWallet(
                upgradeDetails['ticket_id'],
                upgradeDetails['new_ticket_type'],
              );

              Navigator.pop(context);

              if (result['success'] == true) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(result['message'] ?? 'Ticket upgraded successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
                await _loadTickets();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(result['message'] ?? 'Failed to upgrade ticket'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            } catch (e) {
              Navigator.pop(context);
              
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error: $e'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          child: const Text('Upgrade Now'),
        ),
      ],
    ),
  );
}
  Future<void> _loadTickets() async {
    setState(() => isLoading = true);
    try {
      final response = await TicketService.getTickets();
      if (response['results'] != null) {
        final tickets = response['results'] as List;
        
        // Reset counts
        int totalCount = tickets.length;
        int activeCount = 0;
        int usedCount = 0;
        int basicCount = 0;
        int standardCount = 0;
        int premiumCount = 0;
        int vipCount = 0;

        // Count tickets by type and status
        for (var ticket in tickets) {
          if (ticket['status'] == 'ACTIVE') {
            activeCount++;
            switch (ticket['ticket_type']) {
              case 'BASIC':
                basicCount++;
                break;
              case 'STANDARD':
                standardCount++;
                break;
              case 'PREMIUM':
                premiumCount++;
                break;
              case 'VIP':
                vipCount++;
                break;
            }
          } else if (ticket['status'] == 'USED') {
            usedCount++;
          }
        }

        setState(() {
          ticketCounts = {
            'total': totalCount,
            'active': activeCount,
            'used': usedCount,
            'basic': basicCount,
            'standard': standardCount,
            'premium': premiumCount,
            'vip': vipCount,
          };
        });
      }
    } catch (e) {
      print('Error loading tickets: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _loadTickets,
        child: Container(
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
            child: Stack(
              children: [
                Column(
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
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.refresh),
                            onPressed: _loadTickets,
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
                          _buildTicketCounter("Total\nTickets", "${ticketCounts['total']}"),
                          const VerticalDivider(thickness: 1),
                          _buildTicketCounter("Active\nTickets", "${ticketCounts['active']}"),
                          const VerticalDivider(thickness: 1),
                          _buildTicketCounter("Used\nTickets", "${ticketCounts['used']}"),
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
                            ticketCounts['basic'] ?? 0,
                            Colors.yellow.shade600,
                            () => navigateWithAnimation(context, YellowTicketsPage()),
                            Icons.confirmation_number_outlined,
                          ),
                          _buildTicketCard(
                            context,
                            "Standard",
                            "Green Tickets",
                            ticketCounts['standard'] ?? 0,
                            Colors.green,
                            () => navigateWithAnimation(context, GreenTicketsPage()),
                            Icons.confirmation_num_outlined,
                          ),
                          _buildTicketCard(
                            context,
                            "Premium",
                            "Red Tickets",
                            ticketCounts['premium'] ?? 0,
                            Colors.red,
                            () => navigateWithAnimation(context, RedTicketsPage()),
                            Icons.confirmation_num_outlined,
                          ),
                          _buildTicketCard(
                            context,
                            "VIP",
                            "Blue Tickets",
                            ticketCounts['vip'] ?? 0,
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
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                if (isLoading)
                  Container(
                    color: Colors.black.withOpacity(0.1),
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
              ],
            ),
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