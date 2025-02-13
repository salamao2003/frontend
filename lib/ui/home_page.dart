import 'package:egy_metro/ui/ChatBot_page.dart';
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
  int _currentIndex = 0;

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
    appBar: _buildAppBar(),
    drawer: _buildDrawer(),
    body: Container(
      decoration: BoxDecoration(
         gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.blue.shade50,    // لون فاتح من الأزرق في الأعلى
            Colors.blue.shade100,   // لون أغمق قليلاً في الأسفل
          ],
          stops: const [0.7, 1.0],  // التحكم في توزيع التدرج
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          children: [
            _buildPlannerCard(),
            _buildNearbyStationCard(),
            // مساحة إضافية في الأسفل
            const SizedBox(height: 180),
          ],
        ),
      ),
    ),
    bottomNavigationBar: _buildBottomNavigationBar(),
  );
}

  AppBar _buildAppBar() {
    return AppBar(
      title: const Text(
        "Egy Metro",
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          letterSpacing: 1,
          color: Colors.white
        ),
      ),
      backgroundColor: Colors.blue,
      elevation: 0,
      
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Colors.blue,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.asset(
                  'assets/Cairo_metro_logo.png',
                  height: 80,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Welcome to Egy Metro',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          _buildDrawerItem(
            icon: Icons.account_circle,
            title: 'My Account',
            onTap: () => Navigator.pop(context),
          ),
          _buildDrawerItem(
            icon: Icons.confirmation_number,
            title: 'My Tickets',
            onTap: () => navigateWithAnimation(context, MyTicketsPage()),
          ),
          _buildDrawerItem(
            icon: Icons.account_balance_wallet,
            title: 'Wallet',
            onTap: () => navigateWithAnimation(context, WalletPage()),
          ),
          _buildDrawerItem(
            icon: Icons.headset_mic,
            title: 'Chat Bot',
            onTap: () => navigateWithAnimation(context, ChatBotPage()),
          ),
          const Divider(),
          _buildDrawerItem(
            icon: Icons.logout,
            title: 'Logout',
            onTap: () => navigateWithAnimation(context, LoginPage()),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue),
      title: Text(
        title,
        style: const TextStyle(fontSize: 16),
      ),
      onTap: onTap,
    );
  }

  Widget _buildPlannerCard() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          // Main Card
          Container(
            margin: const EdgeInsets.only(top: 40), // Space for the logo
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
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.only(
                    left: 16,
                    right: 16,
                    top: 56, // Extra padding for logo overlap
                    bottom: 16,
                  ),
                  decoration: const BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.route, color: Colors.white),
                      SizedBox(width: 8),
                      Text(
                        "Plan Your Journey",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildStationSelector(
                        icon: Icons.location_on,
                        hint: "Start Station",
                        value: _selectedStartStationId,
                        onChanged: (newValue) {
                          setState(() {
                            _selectedStartStationId = newValue;
                          });
                          _homeLogic.setStartStation(newValue!);
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildStationSelector(
                        icon: Icons.location_on_outlined,
                        hint: "End Station",
                        value: _selectedEndStationId,
                        onChanged: (newValue) {
                          setState(() {
                            _selectedEndStationId = newValue;
                          });
                          _homeLogic.setEndStation(newValue!);
                        },
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            await _homeLogic.startPlan(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.search, color: Colors.white),
                              SizedBox(width: 8),
                              Text(
                                "Start Plan",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Logo on top
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: CircleAvatar(
              radius: 40,
              backgroundColor: Colors.white,
              child: Image.asset(
                'assets/Cairo_metro_logo.png',
                height: 60,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStationSelector({
    required IconData icon,
    required String hint,
    required int? value,
    required Function(int?)? onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue),
          const SizedBox(width: 8),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _stations.isEmpty
                    ? const Text("Failed to load stations")
                    : DropdownButton<int>(
                        hint: Text(hint),
                        value: value,
                        onChanged: onChanged,
                        isExpanded: true,
                        underline: Container(),
                        items: _stations
                            .map((station) => DropdownMenuItem<int>(
                                  value: station['id'] as int,
                                  child: Text(station['name'].toString()),
                                ))
                            .toList(),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildNearbyStationCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
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
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade700,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: const Row(
                children: [
                  Icon(Icons.near_me, color: Colors.white),
                  SizedBox(width: 8),
                  Text(
                    "Find Nearest Station",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton.icon(
                onPressed: () {
                  _homeLogic.findNearestStation(context);
                },
                icon: const Icon(Icons.location_on,color: Colors.white,),
                label: const Text(
                  "Nearby Station",
                  style: TextStyle(color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Colors.blue,
      unselectedItemColor: Colors.grey,
      showUnselectedLabels: true,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: "Home",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.confirmation_number),
          label: "Buy Ticket",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.map),
          label: "Lines",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.paid),
          label: "Subscription",
        ),
      ],
      onTap: (index) {
        setState(() {
          _currentIndex = index;
        });
        if (index == 1) {
          navigateWithAnimation(context, BuyTicketPage());
        } else if (index == 2) {
          navigateWithAnimation(context, LinesPage());
        } else if (index == 3) {
          navigateWithAnimation(context, SubscriptionPage());
        }
      },
    );
  }
}