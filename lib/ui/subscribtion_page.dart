import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SubscriptionPage extends StatelessWidget {
  // إضافة دالة للتعامل مع API الاشتراكات
  Future<void> createSubscription(BuildContext context, int zonesCount) async {
  try {
    // الحصول على access token
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login first')),
      );
      return;
    }

    // عرض مؤشر التحميل
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(child: CircularProgressIndicator());
      },
    );

    final response = await http.post(
      Uri.parse('https://backend-54v5.onrender.com/api/tickets/subscriptions/purchase-with-wallet/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'subscription_type': 'MONTHLY',
        'zones_count': zonesCount,
      }),
    );

    // إخفاء مؤشر التحميل
    Navigator.pop(context);

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(responseData['message'] ?? 'Subscription created successfully'),
          backgroundColor: Colors.green,
        ),
      );
      
      // إغلاق الصفحة بعد نجاح العملية
      Navigator.pop(context);
    } else {
      final responseData = json.decode(response.body);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(responseData['message'] ?? 'Failed to create subscription'),
          backgroundColor: Colors.red,
        ),
      );
    }
  } catch (e) {
    // إخفاء مؤشر التحميل في حالة حدوث خطأ
    Navigator.pop(context);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error: $e'),
        backgroundColor: Colors.red,
      ),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Subscription Plans",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white
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
      ),
      body: Container(
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  "Choose Your Plan",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // في دالة build، داخل Column نعدل الكروت كالتالي:

_buildSubscriptionCard(
  context: context,
  title: "Basic Plan",
  subtitle: "One Region",
  price: "310",
  features: ["Access to one region", "Monthly renewal"],
  color: Colors.blue,
  isPopular: false,
  zonesCount: 1,
),
_buildSubscriptionCard(
  context: context,
  title: "Standard Plan",
  subtitle: "Two Regions",
  price: "365",
  features: ["Access to two regions", "Monthly renewal"],
  color: Colors.purple,
  isPopular: true,
  zonesCount: 2,
),
_buildSubscriptionCard(
  context: context,
  title: "Premium Plan",
  subtitle: "Three Regions",
  price: "425",
  features: ["Access to three regions", "Monthly renewal"],
  color: Colors.orange,
  isPopular: false,
  zonesCount: 3,
),
_buildSubscriptionCard(
  context: context,
  title: "Premium Plan",
  subtitle: "Four Regions",
  price: "425",
  features: ["Access to four regions", "Monthly renewal"],
  color: Colors.orange.shade700,
  isPopular: false,
  zonesCount: 4,
),
_buildSubscriptionCard(
  context: context,
  title: "Ultimate Plan",
  subtitle: "Five Regions",
  price: "600",
  features: ["Access to five regions", "Monthly renewal"],
  color: Colors.green,
  isPopular: false,
  zonesCount: 5,
),
_buildSubscriptionCard(
  context: context,
  title: "Ultimate Plan",
  subtitle: "Six Regions",
  price: "600",
  features: ["Access to six regions", "Monthly renewal"],
  color: Colors.green.shade700,
  isPopular: false,
  zonesCount: 6,
),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubscriptionCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required String price,
    required List<String> features,
    required Color color,
    required bool isPopular,
    required int zonesCount,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.1),
                  spreadRadius: 2,
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: color,
                            ),
                          ),
                          Text(
                            subtitle,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            "$price EGP",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: color,
                            ),
                          ),
                          const Text(
                            "per month",
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      ...features.map((feature) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.check_circle,
                                  color: color,
                                  size: 20,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  feature,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          )),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => createSubscription(context, zonesCount),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: color,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            "Subscribe Now",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white
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
          if (isPopular)
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.purple,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.star,
                      color: Colors.white,
                      size: 16,
                    ),
                    SizedBox(width: 4),
                    Text(
                      "POPULAR",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}