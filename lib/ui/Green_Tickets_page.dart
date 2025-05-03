import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:typed_data';
import '../services/ticket_service.dart';

class GreenTicketsPage extends StatefulWidget {
  @override
  _GreenTicketsPageState createState() => _GreenTicketsPageState();
}

class _GreenTicketsPageState extends State<GreenTicketsPage> {
  List<dynamic> activeTickets = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTickets();
  }

  Future<void> _loadTickets() async {
    setState(() => isLoading = true);
    try {
      final response = await TicketService.getTickets();
      print('Tickets response: $response');

      if (response['results'] != null) {
        final allTickets = response['results'] as List;
        setState(() {
          activeTickets = allTickets.where((ticket) => 
            ticket['ticket_type'] == 'STANDARD' && 
            (ticket['status'] == 'ACTIVE' || ticket['status'] == 'IN_USE')
          ).toList();
        });
        print('Found ${activeTickets.length} active/in-use green tickets');
      }
    } catch (e) {
      print('Error loading tickets: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Widget _buildQRImage(String base64String) {
    try {
      final String cleanBase64 = base64String.replaceAll(RegExp(r'data:image/\w+;base64,'), '');
      final Uint8List bytes = base64Decode(cleanBase64);
      
      return Image.memory(
        bytes,
        width: 200,
        height: 200,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          print('Error loading QR code: $error');
          return const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error, color: Colors.red, size: 40),
              SizedBox(height: 10),
              Text(
                'Failed to load QR Code',
                style: TextStyle(color: Colors.red),
              ),
            ],
          );
        },
      );
    } catch (e) {
      print('Error decoding QR code: $e');
      return const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error, color: Colors.red, size: 40),
          SizedBox(height: 10),
          Text(
            'Invalid QR Code format',
            style: TextStyle(color: Colors.red),
          ),
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Green Tickets",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.green,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadTickets,
          ),
        ],
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(15),
            bottomRight: Radius.circular(15),
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _loadTickets,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.green),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Active Tickets: ",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "${activeTickets.length}",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: isLoading
                ? const Center(child: CircularProgressIndicator(color: Colors.green))
                : activeTickets.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.confirmation_number_outlined,
                            size: 70,
                            color: Colors.grey.withOpacity(0.5),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'No active tickets',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: activeTickets.length,
                      itemBuilder: (context, index) {
                        final ticket = activeTickets[index];
                        return Card(
                          elevation: 4,
                          margin: const EdgeInsets.only(bottom: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Standard Ticket #${ticket['ticket_number']}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      const Text(
                                        'Up to 16 stations',
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Valid until: ${ticket['valid_until']?.split('T')[0] ?? 'N/A'}',
                                        style: const TextStyle(
                                          color: Colors.grey,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                ElevatedButton.icon(
                                  onPressed: ticket['qr_code_url'] != null
                                    ? () {
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return Dialog(
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(20),
                                              ),
                                              child: Container(
                                                padding: const EdgeInsets.all(20),
                                                child: Column(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                      children: [
                                                        const Text(
                                                          'QR Code',
                                                          style: TextStyle(
                                                            fontSize: 20,
                                                            fontWeight: FontWeight.bold,
                                                          ),
                                                        ),
                                                        IconButton(
                                                          onPressed: () => Navigator.pop(context),
                                                          icon: const Icon(Icons.close),
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 20),
                                                    Container(
                                                      padding: const EdgeInsets.all(10),
                                                      decoration: BoxDecoration(
                                                        color: Colors.white,
                                                        borderRadius: BorderRadius.circular(10),
                                                        boxShadow: [
                                                          BoxShadow(
                                                            color: Colors.grey.withOpacity(0.2),
                                                            spreadRadius: 2,
                                                            blurRadius: 5,
                                                            offset: const Offset(0, 2),
                                                          ),
                                                        ],
                                                      ),
                                                      child: _buildQRImage(ticket['qr_code_url']),
                                                    ),
                                                    const SizedBox(height: 20),
                                                    Text(
                                                      'Ticket #${ticket['ticket_number']}',
                                                      style: const TextStyle(
                                                        fontSize: 16,
                                                        color: Colors.grey,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          },
                                        );
                                      }
                                    : null,
                                  icon: const Icon(Icons.qr_code, color: Colors.white),
                                  label: const Text(
                                    'View QR Code',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    elevation: 2,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}