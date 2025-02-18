import 'package:flutter/material.dart';

class LinesPage extends StatefulWidget {
  @override
  _LinesPageState createState() => _LinesPageState();
}

class _LinesPageState extends State<LinesPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TransformationController _transformationController = TransformationController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _transformationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Metro Lines",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,color: Colors.white
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
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          tabs: const [
            Tab(text: "Map View"),
            Tab(text: "Line Details"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildMapView(),
          _buildLineDetails(),
        ],
      ),
      floatingActionButton: _tabController.index == 0
          ? FloatingActionButton(
              onPressed: () {
                _transformationController.value = Matrix4.identity();
              },
              child: const Icon(Icons.center_focus_strong),
              tooltip: 'Reset Zoom',
            )
          : null,
    );
  }

  Widget _buildMapView() {
    return Container(
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
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/Cairo_metro_logo.png',
                    height: 40,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    "Cairo Metro Map",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: InteractiveViewer(
              transformationController: _transformationController,
              panEnabled: true,
              boundaryMargin: const EdgeInsets.all(20),
              minScale: 0.5,
              maxScale: 4.0,
              child: Container(
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 2,
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset(
                    'assets/Cairo_Metro_Map.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLineDetails() {
    return Container(
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
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildLineCard(
            "Line 1",
            "Helwan - El Marg",
            Colors.red,
            "35 stations",
            "44.3 km",
            const ["Helwan", "Maadi", "Sadat", "Ghamra", "El Marg"],
          ),
          _buildLineCard(
            "Line 2",
            "Shobra El Kheima - El Mounib",
            Colors.blue,
            "20 stations",
            "21.6 km",
            const ["Shobra", "Rod El Farag", "Attaba", "Giza", "El Mounib"],
          ),
          _buildLineCard(
            "Line 3",
            "Airport - Kit Kat",
            Colors.green,
            "19 stations",
            "17.7 km",
            const ["Airport", "Heliopolis", "Attaba", "Kit Kat"],
          ),
        ],
      ),
    );
  }

  Widget _buildLineCard(String lineName, String route, Color color,
      String stations, String length, List<String> majorStops) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: ExpansionTile(
        title: Row(
          children: [
            Container(
              width: 4,
              height: 40,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  lineName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  route,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow(Icons.train, stations),
                _buildInfoRow(Icons.straighten, length),
                const SizedBox(height: 8),
                const Text(
                  "Major Stations:",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: majorStops
                      .map((stop) => Chip(
                            label: Text(stop),
                            backgroundColor: color.withOpacity(0.1),
                            side: BorderSide(color: color),
                          ))
                      .toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.blue),
          const SizedBox(width: 8),
          Text(text),
        ],
      ),
    );
  }
}