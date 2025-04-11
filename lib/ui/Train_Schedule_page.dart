import 'package:flutter/material.dart';
import 'package:egy_metro/cubit/Train_Schedule_logic.dart';
import 'dart:async';

class TrainSchedulesPage extends StatefulWidget {
  @override
  _TrainSchedulesPageState createState() => _TrainSchedulesPageState();
}

class _TrainSchedulesPageState extends State<TrainSchedulesPage> {
  final TrainSchedulesLogic _logic = TrainSchedulesLogic();
  
  List<Map<String, dynamic>> _stations = [];
  String? _selectedStartStation;
  String? _selectedEndStation;
  List<dynamic> _trainSchedules = [];
  Timer? _crowdLevelTimer;
  Map<String, dynamic> _currentCrowdLevel = {
    'success': false,
    'crowd_level': 'UNKNOWN',
    'passenger_count': 0,
    'train_number': '',
    'car_number': 7,
    'timestamp': '',
  };

  @override
  void initState() {
    super.initState();
    _loadStations();
    _startCrowdLevelUpdates();
  }

  @override
  void dispose() {
    _crowdLevelTimer?.cancel();
    super.dispose();
  }

  void _startCrowdLevelUpdates() {
    _updateCrowdLevel();
    _crowdLevelTimer = Timer.periodic(Duration(seconds: 30), (timer) {
      _updateCrowdLevel();
    });
  }

  Future<void> _updateCrowdLevel() async {
    try {
      final crowdData = await _logic.getCrowdLevel(trainId: 3, carNumber: 7);
      setState(() {
        _currentCrowdLevel = crowdData;
      });
      print('Updated crowd level: $_currentCrowdLevel');
    } catch (e) {
      print('Error updating crowd level: $e');
    }
  }

  void _loadStations() async {
    try {
      final stations = await _logic.fetchStations();
      setState(() {
        _stations = stations;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load stations: $e')),
      );
    }
  }

  void _fetchTrainSchedules() async {
    if (_selectedStartStation == null || _selectedEndStation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select start and end stations')),
      );
      return;
    }

    try {
      final startStation = _stations.firstWhere((s) => s['name'] == _selectedStartStation);
      final endStation = _stations.firstWhere((s) => s['name'] == _selectedEndStation);
      
      print('Start Station ID: ${startStation['id']}, End Station ID: ${endStation['id']}');

      final schedules = await _logic.getTrainSchedules(
        startStation['id'].toString(),
        endStation['id'].toString()
      );
      
      print('Received schedules: $schedules');

      setState(() {
        _trainSchedules = schedules;
      });
      
      if (_trainSchedules.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No schedules found for the selected stations')),
        );
      }
    } catch (e) {
      print('Error in _fetchTrainSchedules: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching schedules: $e')),
      );
    }
  }

  Widget _buildCrowdLevelCell() {
    Color crowdLevelColor;
    IconData crowdIcon;
    
    switch (_currentCrowdLevel['crowd_level'].toString().toUpperCase()) {
      case 'LOW':
        crowdLevelColor = Colors.green;
        crowdIcon = Icons.people_outline;
        break;
      case 'MEDIUM':
        crowdLevelColor = Colors.orange;
        crowdIcon = Icons.people;
        break;
      case 'HIGH':
        crowdLevelColor = Colors.red;
        crowdIcon = Icons.people_alt;
        break;
      default:
        crowdLevelColor = Colors.grey;
        crowdIcon = Icons.people_outline;
    }

    return Container(
      padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      decoration: BoxDecoration(
        color: crowdLevelColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: crowdLevelColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            crowdIcon,
            color: crowdLevelColor,
            size: 20,
          ),
          SizedBox(width: 4),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _currentCrowdLevel['crowd_level'].toString(),
                style: TextStyle(
                  color: crowdLevelColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
              Text(
                '${_currentCrowdLevel['passenger_count']} passengers',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        title: Text(
          'Train Schedules', 
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
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
                onPressed: _fetchTrainSchedules,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[700],
                  padding: EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 4,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.schedule, color: Colors.white),
                    SizedBox(width: 8),
                    Text(
                      'Show Train Schedules',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 8),
              Text(
                'If you want to see update on schedule press on button again!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
              ),
              SizedBox(height: 20),
              Expanded(
                child: _trainSchedules.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.train, size: 64, color: Colors.grey),
                            SizedBox(height: 16),
                            Text(
                              'No schedules found',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      )
                    : Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            headingRowColor: MaterialStateProperty.all(Colors.blue[50]),
                            columnSpacing: 30,
                            horizontalMargin: 20,
                            columns: [
                              DataColumn(
                                label: Text(
                                  'Train Number',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue[700],
                                  ),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  'Direction',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue[700],
                                  ),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  'Arrival Time',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue[700],
                                  ),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  'AC',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue[700],
                                  ),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  'Crowd Level',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue[700],
                                  ),
                                ),
                              ),
                            ],
                            rows: _trainSchedules.map<DataRow>((schedule) {
                              return DataRow(
                                cells: [
                                  DataCell(Text(
                                    schedule['train_number'],
                                    style: TextStyle(fontWeight: FontWeight.w500),
                                  )),
                                  DataCell(Text(
                                    schedule['direction'],
                                    style: TextStyle(fontWeight: FontWeight.w500),
                                  )),
                                  DataCell(Text(
                                    schedule['waiting_time']['formatted'],
                                    style: TextStyle(fontWeight: FontWeight.w500),
                                  )),
                                  DataCell(
                                    schedule['has_ac']
                                      ? Icon(Icons.ac_unit, color: Colors.blue[700])
                                      : Icon(Icons.ac_unit_outlined, color: Colors.grey),
                                  ),
                                  DataCell(_buildCrowdLevelCell()),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}