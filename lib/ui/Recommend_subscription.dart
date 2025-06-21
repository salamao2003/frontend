import 'package:flutter/material.dart';
import 'package:egy_metro/cubit/Train_Schedule_logic.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class RecommendSubscriptionPage extends StatefulWidget {
  @override
  _RecommendSubscriptionPageState createState() => _RecommendSubscriptionPageState();
}

class _RecommendSubscriptionPageState extends State<RecommendSubscriptionPage> {
  final TrainSchedulesLogic _logic = TrainSchedulesLogic();
  
  List<Map<String, dynamic>> _stations = [];
  String? _selectedStartStation;
  String? _selectedEndStation;
  bool _isLoading = false;
  List<Map<String, dynamic>> _recommendations = [];
  bool _isGettingRecommendations = false;

  @override
  void initState() {
    super.initState();
    _loadStations();
  }

  void _loadStations() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final stations = await _logic.fetchStations();
      setState(() {
        _stations = stations;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load stations: $e')),
      );
    }
  }

  // فنكشن جلب التوصيات من الـ API
  Future<void> _getRecommendationsFromAPI() async {
    if (_selectedStartStation == null || _selectedEndStation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select both start and end stations')),
      );
      return;
    }

    setState(() {
      _isGettingRecommendations = true;
      _recommendations = [];
    });

    try {
      // الحصول على access token
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');

      if (token == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please login first')),
        );
        setState(() {
          _isGettingRecommendations = false;
        });
        return;
      }

      // العثور على IDs المحطات
      final startStation = _stations.firstWhere((s) => s['name'] == _selectedStartStation);
      final endStation = _stations.firstWhere((s) => s['name'] == _selectedEndStation);

      // استدعاء الـ API
      final response = await http.get(
        Uri.parse('https://backend-54v5.onrender.com/api/tickets/subscriptions/recommend/?start_station_id=${startStation['id']}&end_station_id=${endStation['id']}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('Recommendations API Response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final recommendations = data['recommendations'] as List<dynamic>;
        
        // فلترة التوصيات للحصول على الـ Monthly فقط
        final monthlyRecommendations = recommendations.where((rec) => 
          rec['plan_type'].toString().toLowerCase() == 'monthly'
        ).toList();

        setState(() {
          _recommendations = monthlyRecommendations.cast<Map<String, dynamic>>();
          _isGettingRecommendations = false;
        });

        if (_recommendations.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('No monthly recommendations found for the selected route')),
          );
        }
      } else {
        final responseData = json.decode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(responseData['message'] ?? 'Failed to get recommendations'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          _isGettingRecommendations = false;
        });
      }
    } catch (e) {
      print('Error getting recommendations: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
      setState(() {
        _isGettingRecommendations = false;
      });
    }
  }

  void _getRecommendation() {
    _getRecommendationsFromAPI();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        title: Text(
          'Recommend Subscription', 
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: Colors.white
          )
        ),
        centerTitle: true,
        backgroundColor: Colors.blue[700],
      ),
      body: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Select Your Journey',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[700],
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8),
              Text(
                'Choose your start and end stations to get the best subscription recommendation',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 30),
              
              if (_isLoading)
                Center(child: CircularProgressIndicator())
              else
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            labelText: 'Start Station',
                            labelStyle: TextStyle(color: Colors.blue[700]),
                            prefixIcon: Icon(Icons.train_outlined, color: Colors.blue[700]),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Colors.blue[700]!),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Colors.blue[200]!),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Colors.blue[700]!, width: 2),
                            ),
                          ),
                          value: _selectedStartStation,
                          hint: Text('Select Start Station'),
                          items: _stations.map<DropdownMenuItem<String>>((station) {
                            return DropdownMenuItem<String>(
                              value: station['name'],
                              child: Text(station['name']),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedStartStation = value;
                            });
                          },
                        ),
                        SizedBox(height: 20),
                        DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            labelText: 'End Station',
                            labelStyle: TextStyle(color: Colors.blue[700]),
                            prefixIcon: Icon(Icons.train_outlined, color: Colors.blue[700]),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Colors.blue[700]!),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Colors.blue[200]!),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Colors.blue[700]!, width: 2),
                            ),
                          ),
                          value: _selectedEndStation,
                          hint: Text('Select End Station'),
                          items: _stations.map<DropdownMenuItem<String>>((station) {
                            return DropdownMenuItem<String>(
                              value: station['name'],
                              child: Text(station['name']),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedEndStation = value;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              
              SizedBox(height: 20),
              
              ElevatedButton(
                onPressed: _isGettingRecommendations ? null : _getRecommendation,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[700],
                  padding: EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 4,
                ),
                child: _isGettingRecommendations
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Getting Recommendations...',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.recommend, color: Colors.white),
                          SizedBox(width: 8),
                          Text(
                            'Get Recommendation',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ],
                      ),
              ),
              
              SizedBox(height: 30),
              
              if (_recommendations.isNotEmpty)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.lightbulb,
                            color: Colors.blue[700],
                            size: 24,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Monthly Recommendations',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue[700],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      Expanded(
                        child: ListView.builder(
                          itemCount: _recommendations.length,
                          itemBuilder: (context, index) {
                            final recommendation = _recommendations[index];
                            return Card(
                              elevation: 4,
                              margin: EdgeInsets.only(bottom: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Container(
                                padding: EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Colors.blue[50]!,
                                      Colors.blue[100]!,
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          '${recommendation['plan_type']} Plan',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.blue[700],
                                          ),
                                        ),
                                        Container(
                                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: Colors.blue[700],
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: Text(
                                            '${recommendation['zones']} Zones',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 12),
                                    Row(
                                      children: [
                                        Icon(Icons.monetization_on, color: Colors.green, size: 20),
                                        SizedBox(width: 8),
                                        Text(
                                          'Price: ${recommendation['price']} EGP',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.green[700],
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 8),
                                    
                                    
                                    Row(
                                      children: [
                                        Icon(Icons.calculate, color: Colors.orange[600], size: 20),
                                        SizedBox(width: 8),
                                        Text(
                                          'Price per trip: ${recommendation['price_per_trip']} EGP',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 12),
                                    Text(
                                      recommendation['description'],
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[700],
                                        height: 1.4,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue[700],
                            padding: EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            'Back to Subscription Plans',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}