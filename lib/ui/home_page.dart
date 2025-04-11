import 'package:egy_metro/ui/ChatBot_page.dart';
import 'package:egy_metro/ui/Train_Schedule_page.dart';
import 'package:flutter/material.dart';
import 'package:egy_metro/ui/Buy_Ticket_page.dart';
import 'package:egy_metro/ui/subscribtion_page.dart';
import 'package:egy_metro/ui/wallet_page.dart';
import 'package:egy_metro/ui/login_page.dart';
import 'package:egy_metro/ui/animated_page_transition.dart';
import 'package:egy_metro/ui/Lines_page.dart';
import 'package:egy_metro/ui/My_Tickets_page.dart';
import 'package:egy_metro/ui/My_Account_page.dart';
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
              Colors.blue.shade50,
              Colors.blue.shade100,
            ],
            stops: const [0.7, 1.0],
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildPlannerCard(),
              _buildNearbyStationCard(),
              const SizedBox(height: 190),
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
          color: Colors.white,
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
            onTap: () => navigateWithAnimation(context, MyAccountPage()),
          ),
          _buildDrawerItem(
            icon: Icons.confirmation_number,
            title: 'My Tickets',
            onTap: () => navigateWithAnimation(context, MyTicketsPage()),
          ),
          _buildDrawerItem(
            icon: Icons.calendar_month,
            title: 'Train Schedule',
            onTap: () => navigateWithAnimation(context, TrainSchedulesPage()),
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
      title: Row(
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16),
          ),
          if (title == 'Chat Bot') ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.purple.shade100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.purple.shade300,
                  width: 1,
                ),
              ),
              child: const Text(
                'New',
                style: TextStyle(
                  color: Colors.purple,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
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
          Container(
            margin: const EdgeInsets.only(top: 40),
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
                    top: 56,
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
                    : SearchableDropdown(
                        items: _stations,
                        value: value,
                        hint: hint,
                        onChanged: onChanged,
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
                icon: const Icon(Icons.location_on, color: Colors.white),
                label: const Text(
                  "Nearby Station",
                  style: TextStyle(
                    color: Colors.white,
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

class SearchableDropdown extends StatefulWidget {
  final List<Map<String, dynamic>> items;
  final int? value;
  final String hint;
  final Function(int?)? onChanged;

  const SearchableDropdown({
    Key? key,
    required this.items,
    required this.value,
    required this.hint,
    required this.onChanged,
  }) : super(key: key);

  @override
  State<SearchableDropdown> createState() => _SearchableDropdownState();
}

class _SearchableDropdownState extends State<SearchableDropdown> {
  bool _isExpanded = false;
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _filteredItems = [];
  final FocusNode _focusNode = FocusNode();
  OverlayEntry? _overlayEntry;
  final LayerLink _layerLink = LayerLink();

  @override
  void initState() {
    super.initState();
    _filteredItems = widget.items;
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    _removeOverlay();
    super.dispose();
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _showOverlay() {
    _removeOverlay();

    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        width: size.width,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: const Offset(0, 50),
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.4,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      controller: _searchController,
                      focusNode: _focusNode,
                      decoration: InputDecoration(
                        hintText: 'Search station...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _filteredItems = widget.items
                              .where((item) => item['name']
                                  .toString()
                                  .toLowerCase()
                                  .contains(value.toLowerCase()))
                              .toList();
                        });
                      },
                    ),
                  ),
                  Flexible(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: _filteredItems.length,
                      itemBuilder: (context, index) {
                        final item = _filteredItems[index];
                        final bool isSelected = widget.value == item['id'];
                        return ListTile(
                          title: Text(
                            item['name'].toString(),
                            style: TextStyle(
                              color: isSelected ? Colors.blue : Colors.black,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                          tileColor: isSelected ? Colors.blue.withOpacity(0.1) : null,
                          onTap: () {
                            widget.onChanged?.call(item['id'] as int);
                            _searchController.clear();
                            _removeOverlay();
                            setState(() {
                              _isExpanded = false;
                              _filteredItems = widget.items;
                            });
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: GestureDetector(
        onTap: () {
          setState(() {
            _isExpanded = !_isExpanded;
            if (_isExpanded) {
              _showOverlay();
              _focusNode.requestFocus();
            } else {
              _removeOverlay();
            }
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  widget.value != null
                      ? widget.items
                          .firstWhere(
                            (item) => item['id'] == widget.value,
                            orElse: () => {'name': widget.hint},
                          )['name']
                          .toString()
                      : widget.hint,
                  style: TextStyle(
                    color: widget.value != null ? Colors.black : Colors.grey[600],
                  ),
                ),
              ),
              Icon(
                _isExpanded ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                color: Colors.grey[600],
              ),
            ],
          ),
        ),
      ),
    );
  }
}