import 'package:egy_metro/ui/plan_page.dart';
import 'package:flutter/material.dart';
import 'package:egy_metro/ui/Buy_Ticket_page.dart';
import 'package:egy_metro/ui/subscribtion_page.dart';
import 'package:egy_metro/ui/wallet_page.dart';
import 'package:egy_metro/ui/login_page.dart';
import 'package:egy_metro/ui/animated_page_transition.dart';
import 'package:egy_metro/ui/Lines_page.dart';
import 'package:egy_metro/ui/My_Tickets_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // قائمة بالمحطات
  final List<String> stations = [
    'El-Marg El-Gedida',
    'El-Marg',
    'Ezbet El-Nakhl',
    'Ain Shams',
    'El-Matareyya',
    'Helmeyet El-Zaitoun',
    'Hadayeq El-Zaitoun',
    'Saray El-Qobba',
    'Hammamat El-Qobba',
    'Kobri El-Qobba',
    'Manshiet El-Sadr',
    'El-Demerdash',
    'Ghamra',
    'Al-Shohadaa',
    'Ahmed Orabi',
    'Nasser',
    'Sadat',
    'Saad Zaghloul',
    'Sayeda Zeinab',
    'El-Malek El-Saleh',
    'Mar Girgis',
    'El-Zahraa',
    'Dar El-Salam',
    'Hadayeq El-Maadi',
    'El-Maadi',
    'Thakanat El-Maadi',
    'Tora El-Balad',
    'Kozzika',
    'Tora El-Asmant',
    'El-Maasara',
    'Hadayeq Helwan',
    'Wadi Hof',
    'Helwan University',
    'Ain Helwan',
    'Helwan',
];

  // متغيرات لتخزين القيم المختارة
  String? selectedStartStation;
  String? selectedEndStation;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Egy Metro",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blue,
        elevation: 0,
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Colors.blue,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/Cairo_metro_logo.png',
                    height: 100,
                    fit: BoxFit.contain,
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.account_circle),
              title: const Text('My Account'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.confirmation_number),
              title: const Text('My Tickets'),
              onTap: () {
                navigateWithAnimation(context, MyTicketsPage());
              },
            ),
            ListTile(
              leading: const Icon(Icons.account_balance_wallet),
              title: const Text('Wallet'),
              onTap: () {
                navigateWithAnimation(context, WalletPage());
              },
            ),
            ListTile(
              leading: const Icon(Icons.headset_mic),
              title: const Text('Chat Bot'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () {
                navigateWithAnimation(context, LoginPage());
              },
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // First Section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      spreadRadius: 2,
                      blurRadius: 5,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    Image.asset(
                      'assets/Cairo_metro_logo.png',
                      height: 80,
                    ),
                    const SizedBox(height: 16),
                    _buildDropdown(
                      context,
                      icon: Icons.directions_walk,
                      hint: "Start Station",
                      value: selectedStartStation,
                      onChanged: (newValue) {
                        setState(() {
                          selectedStartStation = newValue;
                        });
                      },
                    ),
                    _buildDropdown(
                      context,
                      icon: Icons.directions_walk,
                      hint: "End Station",
                      value: selectedEndStation,
                      onChanged: (newValue) {
                        setState(() {
                          selectedEndStation = newValue;
                        });
                      },
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () {
                            navigateWithAnimation(context, PlanPage());
                            print('Start Station: $selectedStartStation');
                            print('End Station: $selectedEndStation');
                          },
                          icon: const Icon(
                            Icons.search,
                            color: Colors.white,
                          ),
                          label: const Text(
                            "Start Plan",
                            style: TextStyle(color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
            // Second Section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                width: 300,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      spreadRadius: 2,
                      blurRadius: 5,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    const Text(
                      "Show Nearest Station:",
                      style: TextStyle(fontSize: 20),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        // Logic for Nearby Station
                      },
                      icon: const Icon(
                        Icons.location_on,
                        color: Colors.white,
                      ),
                      label: const Text(
                        "Nearby Station",
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "Enable location services",
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.confirmation_number),
            label: "Buy Ticket",
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: "Lines",
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.paid),
            label: "Subscribtion",
          ),
        ],
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        onTap: (index) {
          if (index == 1) {
            navigateWithAnimation(context, BuyTicketPage());
          } else if (index == 2) {
            navigateWithAnimation(context, LinesPage());
          } else if (index == 3) {
            navigateWithAnimation(context, SubscriptionPage());
          }
        },
      ),
    );
  }

  // Helper Method to Build Dropdown
  Widget _buildDropdown(
    BuildContext context, {
    required IconData icon,
    required String hint,
    required String? value,
    required Function(String?) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: DropdownButtonFormField<String>(
        value: value,
        onChanged: onChanged,
        decoration: InputDecoration(
          prefixIcon: Icon(icon),
          hintText: hint,
          filled: true,
          fillColor: Colors.grey[200],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
        ),
        items: stations.map((String station) {
          return DropdownMenuItem<String>(
            value: station,
            child: Text(station),
          );
        }).toList(),
      ),
    );
  }
}