import 'package:flutter/material.dart';
import 'package:egy_metro/ui/login_page.dart';
import 'package:egy_metro/ui/animated_page_transition.dart';
import 'package:egy_metro/ui/Lines_page.dart'; // استيراد الصفحة الجديدة

class HomePage extends StatelessWidget {
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
              icon: const Icon(Icons.menu), // أيقونة القائمة (Hamburger Icon)
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
                Navigator.pop(context); // يغلق القائمة
              },
            ),
            ListTile(
              leading: const Icon(Icons.confirmation_number),
              title: const Text('My Tickets'),
              onTap: () {
                Navigator.pop(context); // يمكنك وضع التنقل إلى صفحة أخرى هنا
              },
            ),
            ListTile(
              leading: const Icon(Icons.account_balance_wallet),
              title: const Text('Wallet'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.feedback),
              title: const Text('Fault Reporting'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            const Divider(), // خط فاصل
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
                    _buildTextField(
                      context,
                      icon: Icons.directions_walk,
                      hint: "Start Station",
                    ),
                    _buildTextField(
                      context,
                      icon: Icons.directions_walk,
                      hint: "End Station",
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () {
                            // Logic for Start Plan
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
                    Title(
                      color: Colors.black,
                      child: Text(
                        "Show Nearest Station:",
                        style: TextStyle(fontSize: 20),
                      ),
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
          if (index == 2) {
            // Navigate to LinesPage
            navigateWithAnimation(context, LinesPage());
          }
        },
      ),
    );
  }

  // Helper Method to Build TextFields
  Widget _buildTextField(BuildContext context,
      {required IconData icon, required String hint, bool isEnabled = true}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        enabled: isEnabled,
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
      ),
    );
  }
}
