import 'package:flutter/material.dart';

class BuyTicketPage extends StatefulWidget {
  @override
  _BuyTicketPageState createState() => _BuyTicketPageState();
}

class _BuyTicketPageState extends State<BuyTicketPage> {
  int _ticketCountFirst = 1;
  int _ticketCountSecond = 1;
  int _ticketCountThird = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Buy your tickets now !",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(height: 50),
            // Container الأول (الخلفية الصفراء)
            _buildTicketContainer(
              color: Colors.yellow,
              ticketCount: _ticketCountFirst,
              onIncrease: () {
                setState(() {
                  _ticketCountFirst++;
                });
              },
              onDecrease: () {
                setState(() {
                  if (_ticketCountFirst > 1) _ticketCountFirst--;
                });
              },
              priceText: "Price: 8 EGP",
              noStations: "Up to 9 stations",
              priceTextColor: Colors.black,
              noStationsColor: Colors.black,
              logoPath: 'assets/Cairo_metro_logo.png',
            ),
            const SizedBox(height: 20),
            // Container الثاني (الخلفية الخضراء)
            _buildTicketContainer(
              color: Colors.green,
              ticketCount: _ticketCountSecond,
              onIncrease: () {
                setState(() {
                  _ticketCountSecond++;
                });
              },
              onDecrease: () {
                setState(() {
                  if (_ticketCountSecond > 1) _ticketCountSecond--;
                });
              },
              priceText: "Price: 10 EGP",
              noStations: "Up to 16 stations",
              priceTextColor: Colors.black,
              noStationsColor: Colors.black,
              logoPath: 'assets/Cairo_metro_logo.png',
            ),
            const SizedBox(height: 20),
            // Container الثالث (الخلفية الوردية)
            _buildTicketContainer(
              color: Colors.pink,
              ticketCount: _ticketCountThird,
              onIncrease: () {
                setState(() {
                  _ticketCountThird++;
                });
              },
              onDecrease: () {
                setState(() {
                  if (_ticketCountThird > 1) _ticketCountThird--;
                });
              },
              priceText: "Price: 15 EGP",
              noStations: "Up to 23 stations",
              priceTextColor: Colors.black,
              noStationsColor: Colors.black,
              logoPath: 'assets/Cairo_metro_logo.png',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTicketContainer({
    required Color color,
    required int ticketCount,
    required VoidCallback onIncrease,
    required VoidCallback onDecrease,
    required String priceText,
    required String noStations,
    required Color priceTextColor,
    required Color noStationsColor,
    required String logoPath, // مسار الصورة
  }) {
    return Center(
      child: Container(
        width: 250,
        height: 240, // زيادة الطول لاستيعاب الصورة
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
            // نص السعر
            Text(
              priceText,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: priceTextColor,
              ),
            ),
            const SizedBox(height: 8),
            // نص عدد المحطات
            Text(
              noStations,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: noStationsColor,
              ),
            ),
            const SizedBox(height: 16),
            // العداد وزر الشراء
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // عداد التذاكر
                Row(
                  children: [
                    IconButton(
                      onPressed: onDecrease,
                      icon: const Icon(Icons.remove, color: Colors.black),
                    ),
                    Text(
                      '$ticketCount',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      onPressed: onIncrease,
                      icon: const Icon(Icons.add, color: Colors.black),
                    ),
                  ],
                ),
                // زر الشراء
                ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("You purchased $ticketCount tickets!"),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 20),
                  ),
                  child: const Text(
                    "Buy",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
