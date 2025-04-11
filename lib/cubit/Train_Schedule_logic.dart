import 'package:http/http.dart' as http;
import 'dart:convert';

class TrainSchedulesLogic {
  // الفنكشن الأصلي للحصول على جداول القطارات
    Future<List<dynamic>> getTrainSchedules(String startStationId, String endStationId) async {
    try {
      final response = await http.post(
        Uri.parse('https://backend-54v5.onrender.com/api/trains/get-schedules/'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'start_station': int.parse(startStationId),
          'end_station': int.parse(endStationId),
        }),
      );

      print('Schedules API Response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final schedules = data['schedules'] as List<dynamic>;
        
        // جلب بيانات الازدحام وإضافتها للجداول
        final crowdData = await getCrowdLevel();
        
        // تحديث بيانات الازدحام في كل جدول
        return schedules.map((schedule) {
          schedule['crowd_info'] = {
            'level': crowdData['crowd_level'],
            'passenger_count': crowdData['passenger_count'],
          };
          return schedule;
        }).toList();
      } else {
        print('Error: ${response.statusCode} - ${response.body}');
        return [];
      }
    } catch (e) {
      print('Error fetching train schedules: $e');
      return [];
    }
  }
  // الفنكشن الجديد لجلب قائمة المحطات
  Future<List<Map<String, dynamic>>> fetchStations() async {
    List<Map<String, dynamic>> allStations = [];

    for (int page = 1; page <= 9; page++) {
      try {
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
          print('Failed to load stations in page $page');
        }
      } catch (e) {
        print('Error fetching stations in page $page: $e');
      }
    }

    return allStations;
  }
 
Future<Map<String, dynamic>> getCrowdLevel({int trainId = 3, int? carNumber}) async {
  try {
    // Construct the endpoint with optional car_number query param
    String url = 'https://backend-54v5.onrender.com/api/trains/$trainId/crowd-status/';
    if (carNumber != null) {
      url += '?car_number=$carNumber';
    }

    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Accept': 'application/json',
      },
    );

    print('Crowd Level API Response: ${response.statusCode} - ${response.body}');

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return {
        'success': true,
        'train_number': data['train_number'],
        'car_number': data['car_number'],
        'crowd_level': data['crowd_level'] ?? 'UNKNOWN',
        'passenger_count': data['current_passengers'] ?? 0,
        'timestamp': data['timestamp'],
      };
    } else {
      final data = json.decode(response.body);
      return {
        'success': false,
        'crowd_level': data['crowd_level'] ?? 'UNKNOWN',
        'passenger_count': data['current_passengers'] ?? 0,
        'message': data['message'] ?? 'Failed to retrieve data'
      };
    }
  } catch (e) {
    print('Error getting crowd level: $e');
    return {
      'success': false,
      'crowd_level': 'UNKNOWN',
      'passenger_count': 0,
      'message': 'Exception: $e'
    };
  }
}
}