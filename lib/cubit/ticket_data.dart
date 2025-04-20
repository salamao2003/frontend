import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class TicketData {
  static int yellowTickets = 0;
  static int greenTickets = 0;
  static int redTickets = 0;
  static int blueTickets = 0;

  static Map<String, List<String>> ticketQRCodes = {
    'BASIC': [],    // Yellow tickets
    'STANDARD': [], // Green tickets
    'PREMIUM': [],  // Red tickets
    'VIP': [],     // Blue tickets
  };

  // Save ticket data
  static Future<void> saveTicketData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('yellow_tickets', yellowTickets);
    await prefs.setInt('green_tickets', greenTickets);
    await prefs.setInt('red_tickets', redTickets);
    await prefs.setInt('blue_tickets', blueTickets);

    // Save QR codes
    await prefs.setString('qr_codes', json.encode(ticketQRCodes));
  }

  // Load ticket data
  static Future<void> loadTicketData() async {
    final prefs = await SharedPreferences.getInstance();
    yellowTickets = prefs.getInt('yellow_tickets') ?? 0;
    greenTickets = prefs.getInt('green_tickets') ?? 0;
    redTickets = prefs.getInt('red_tickets') ?? 0;
    blueTickets = prefs.getInt('blue_tickets') ?? 0;

    // Load QR codes
    String? qrCodesString = prefs.getString('qr_codes');
    if (qrCodesString != null) {
      Map<String, dynamic> decodedMap = json.decode(qrCodesString);
      ticketQRCodes = {
        'BASIC': List<String>.from(decodedMap['BASIC'] ?? []),
        'STANDARD': List<String>.from(decodedMap['STANDARD'] ?? []),
        'PREMIUM': List<String>.from(decodedMap['PREMIUM'] ?? []),
        'VIP': List<String>.from(decodedMap['VIP'] ?? []),
      };
    }
  }

  // Add QR code and save
  static Future<void> addQRCode(String ticketType, String qrCodeUrl) async {
    ticketQRCodes[ticketType]?.add(qrCodeUrl);
    await saveTicketData();
  }

  // Get QR code
  static String? getQRCode(String ticketType, int index) {
    final list = ticketQRCodes[ticketType];
    if (list != null && index < list.length) {
      return list[index];
    }
    return null;
  }
}