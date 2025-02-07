import 'package:flutter/material.dart';

class WalletPage extends StatefulWidget {
  @override
  _WalletPageState createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  int balance = 0;
  String selectedPaymentMethod = "Visa";
  TextEditingController phoneController = TextEditingController(text: "0");
  TextEditingController amountController = TextEditingController(text: "0");

  TextEditingController cardNumberController = TextEditingController();
  TextEditingController cardNameController = TextEditingController();
  TextEditingController expiryDateController = TextEditingController();
  TextEditingController cvvController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true, // ✅ يسمح بإعادة ضبط الواجهة عند ظهور الكيبورد
      appBar: AppBar(
        title: const Text("Wallet"),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView( // ✅ يتيح التمرير عند ظهور الكيبورد
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min, // ✅ يمنع التمدد غير الضروري
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset('assets/wallet.png', height: 60),
              const SizedBox(height: 10),
              Text(
                "Your balance: $balance EGP",
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              const Text(
                "Deposit money in your wallet",
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),

              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    ListTile(
                      leading: Radio<String>(
                        value: "Visa",
                        groupValue: selectedPaymentMethod,
                        onChanged: (value) {
                          setState(() {
                            selectedPaymentMethod = value!;
                          });
                        },
                      ),
                      title: Image.asset('assets/visa.png', height: 40),
                    ),
                    ListTile(
                      leading: Radio<String>(
                        value: "Wallet",
                        groupValue: selectedPaymentMethod,
                        onChanged: (value) {
                          setState(() {
                            selectedPaymentMethod = value!;
                          });
                        },
                      ),
                      title: Image.asset('assets/vodafone.png', height: 40),
                    ),
                    const SizedBox(height: 10),

                    if (selectedPaymentMethod == "Visa")
                      Column(
                        children: [
                          TextField(
                            controller: cardNumberController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: "Card Number",
                              prefixIcon: Icon(Icons.credit_card),
                            ),
                          ),
                          const SizedBox(height: 10),
                          TextField(
                            controller: cardNameController,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: "Cardholder Name",
                              prefixIcon: Icon(Icons.person),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: expiryDateController,
                                  keyboardType: TextInputType.datetime,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(),
                                    labelText: "MM/YY",
                                    prefixIcon: Icon(Icons.date_range),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: TextField(
                                  controller: cvvController,
                                  keyboardType: TextInputType.number,
                                  obscureText: true,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(),
                                    labelText: "CVV",
                                    prefixIcon: Icon(Icons.lock),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                    if (selectedPaymentMethod == "Wallet")
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: TextField(
                          controller: phoneController,
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: "Phone Number",
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "Type the amount of money you want to deposit",
                ),
              ),

              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: () {
                  int depositAmount = int.tryParse(amountController.text) ?? 0;
                  if (depositAmount > 0) {
                    setState(() {
                      balance += depositAmount;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Deposited $depositAmount EGP successfully!")),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 12),
                ),
                child: const Text(
                  "Deposit",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
