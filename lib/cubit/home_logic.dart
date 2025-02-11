import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:egy_metro/ui/animated_page_transition.dart';
import 'package:egy_metro/ui/plan_page.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class HomeLogic {
  int? startStationId;
  int? endStationId;

  // Fetch stations method
  Future<List<Map<String, dynamic>>> fetchStations() async {
    List<Map<String, dynamic>> allStations = [];

    for (int page = 1; page <= 9; page++) {
      final response = await http.get(
        Uri.parse('https://backend-54v5.onrender.com/api/stations/list/?page=$page'),
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> jsonData = json.decode(response.body);
        List<dynamic> results = jsonData['results'];

        allStations.addAll(results.map((station) => {
              "id": station['id'],
              "name": station['name'],
            }));
      } else {
        throw Exception('Failed to load stations in page $page');
      }
    }

    return allStations;
  }

  // Set start station method
  void setStartStation(int id) {
    startStationId = id;
  }

  // Set end station method
  void setEndStation(int id) {
    endStationId = id;
  }

  // Show loading dialog method
  void _showLoadingDialog(BuildContext context, {String message = 'Loading...'}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 15),
                Text(message),
              ],
            ),
          ),
        );
      },
    );
  }

  // Handle location permission method
  Future<bool> _handleLocationPermission(BuildContext context) async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Location services are disabled. Please enable them')));
      return false;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permissions are denied')));
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Location permissions are permanently denied')));
      return false;
    }

    return true;
  }

  // Get nearest station method
  Future<void> getNearestStation(double lat, double lng, BuildContext context) async {
    try {
      print('Sending request with lat: $lat, lng: $lng');

      final uri = Uri.parse('https://backend-54v5.onrender.com/api/stations/nearest/');

      final body = jsonEncode({
        "latitude": lat,
        "longitude": lng
      });

      print('Request body: $body');

      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: body,
      );

      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        String stationName = data['nearest_station'] ?? 'Unknown';
        double distance = double.parse(data['distance']?.toString() ?? '0');

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
              'Nearest station: $stationName\n'
              'Distance: ${distance.toStringAsFixed(2)} m',
            ),
            duration: const Duration(seconds: 5),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.blue,
          ));
        }
      } else {
        throw Exception('Failed to get nearest station');
      }
    } catch (e) {
      print('Error in getNearestStation: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Start plan method
  Future<void> startPlan(BuildContext context) async {
    if (startStationId == null || endStationId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select both stations")),
      );
      return;
    }

    _showLoadingDialog(context, message: 'Loading trip information...');

    try {
      final response = await http.get(
        Uri.parse('https://backend-54v5.onrender.com/api/stations/trip/$startStationId/$endStationId/'),
      );

      if (context.mounted) {
        Navigator.pop(context); // Hide loading dialog
      }

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        
        if (context.mounted) {
          navigateWithAnimation(
            context,
            PlanPage(
              time: data['estimated_travel_time'].toString(),
              stations: data['number_of_stations'].toString(),
              price: data['ticket_price'].toString(),
            ),
          );
        }
      } else {
        throw Exception('Failed to load trip data');
      }
    } catch (e) {
      if (context.mounted && Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${e.toString()}")),
        );
      }
    }
  }

  // Find nearest station method
  Future<void> findNearestStation(BuildContext context) async {
    print('Starting findNearestStation...');
    _showLoadingDialog(context, message: 'Searching for nearest station...');

    try {
      var status = await Permission.location.request();
      print('Location permission status: $status');

      if (status.isDenied) {
        if (context.mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please allow access to location')),
          );
        }
        return;
      }

      if (status.isPermanentlyDenied) {
        if (context.mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please enable location permission from app settings'),
            ),
          );
        }
        await openAppSettings();
        return;
      }

      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      print('Location service enabled: $serviceEnabled');

      if (!serviceEnabled) {
        if (context.mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please enable location services in device settings')),
          );
        }
        return;
      }

      print('Getting current position...');
      final Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      print('Position obtained - Latitude: ${position.latitude}, Longitude: ${position.longitude}');

      if (context.mounted) {
        await getNearestStation(position.latitude, position.longitude, context);
      }

      if (context.mounted) {
        Navigator.pop(context);
      }

    } catch (e) {
      print('Error in findNearestStation: $e');
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }
}