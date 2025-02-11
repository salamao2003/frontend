import 'package:flutter/material.dart';
import 'package:egy_metro/ui/Buy_Ticket_page.dart';
import 'package:egy_metro/ui/subscribtion_page.dart';
import 'package:egy_metro/ui/wallet_page.dart';
import 'package:egy_metro/ui/login_page.dart';
import 'package:egy_metro/ui/animated_page_transition.dart';
import 'package:egy_metro/ui/Lines_page.dart';
import 'package:egy_metro/ui/My_Tickets_page.dart';
import 'package:egy_metro/cubit/home_logic.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final HomeLogic _homeLogic = HomeLogic();
  List<Map<String, dynamic>> _stations = [];
  bool _isLoading = true;
  int? _selectedStartStationId;
  int? _selectedEndStationId;

  @override
  void initState() {
    super.initState();
    _loadStations();
  }

  Future<void> _loadStations() async {
    try {
      List<Map<String, dynamic>> stations = await _homeLogic.fetchStations();
      if (mounted) {
        setState(() {
          _stations = stations;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('❌ Error loading stations: $e');
      if (mounted) {
        setState(() {
          _stations = [];
          _isLoading = false;
        });
      }
    }
  }

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
                Scaffold.of(context).openDrawer(); // فتح الـ Drawer
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
                    'assets/Cairo_metro_logo.png', // ضع مسار الصورة هنا
                    height: 100, // ارتفاع الشعار
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
                      'assets/Cairo_metro_logo.png', // ضع صورة شعار هنا
                      height: 80,
                    ),
                    const SizedBox(height: 16),
                    // Dropdown for Start Station
                    _buildDropdown(
                      hint: "Start Station",
                      value: _selectedStartStationId,
                      onChanged: (newValue) {
                        setState(() {
                          _selectedStartStationId = newValue;
                        });
                        _homeLogic.setStartStation(newValue!);
                      },
                    ),
                    // Dropdown for End Station
                    _buildDropdown(
                      hint: "End Station",
                      value: _selectedEndStationId,
                      onChanged: (newValue) {
                        setState(() {
                          _selectedEndStationId = newValue;
                        });
                        _homeLogic.setEndStation(newValue!);
                      },
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () async {
                            await _homeLogic.startPlan(context);
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
                            _homeLogic.findNearestStation(context);
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
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: "Lines",
            backgroundColor: Colors.blue,
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
  Widget _buildDropdown({
    required String hint,
    required int? value,
    required Function(int?)? onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _stations.isEmpty
              ? const Center(child: Text("Failed to load stations"))
              : DropdownButton<int>(
                  hint: Text(hint),
                  value: value,
                  onChanged: onChanged,
                  isExpanded: true,
                  items: _stations
                      .map((station) => DropdownMenuItem<int>(
                            value: station['id'] as int,
                            child: Text(station['name'].toString()),
                          ))
                      .toList(),
                ),
    );
  }
}