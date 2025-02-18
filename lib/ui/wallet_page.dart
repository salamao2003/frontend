import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class WalletPage extends StatefulWidget {
  @override
  _WalletPageState createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  int balance = 0;
  String selectedPaymentMethod = "Visa";
  final TextEditingController phoneController = TextEditingController(text: "0");
  final TextEditingController amountController = TextEditingController(text: "0");
  final TextEditingController cardNumberController = TextEditingController();
  final TextEditingController cardNameController = TextEditingController();
  final TextEditingController expiryDateController = TextEditingController();
  final TextEditingController cvvController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Wallet",
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
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildBalanceCard(),
                const SizedBox(height: 24),
                _buildPaymentMethodsSection(),
                const SizedBox(height: 24),
                _buildAmountInput(),
                const SizedBox(height: 24),
                _buildDepositButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBalanceCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade400, Colors.blue.shade700],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Current Balance",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
              Image.asset('assets/wallet.png', height: 30),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "EGP ",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                ),
              ),
              Text(
                balance.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
    Widget _buildPaymentMethodsSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: const [
                Icon(Icons.payment, color: Colors.blue),
                SizedBox(width: 10),
                Text(
                  "Payment Method",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          _buildPaymentOption(
            "Visa",
            'assets/visa.png',
            selectedPaymentMethod == "Visa",
          ),
          _buildPaymentOption(
            "Wallet",
            'assets/vodafone.png',
            selectedPaymentMethod == "Wallet",
          ),
          AnimatedCrossFade(
            firstChild: _buildVisaForm(),
            secondChild: _buildWalletForm(),
            crossFadeState: selectedPaymentMethod == "Visa"
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            duration: const Duration(milliseconds: 300),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentOption(String value, String imagePath, bool isSelected) {
    return InkWell(
      onTap: () => setState(() => selectedPaymentMethod = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.shade50 : Colors.white,
          border: Border(
            left: BorderSide(
              color: isSelected ? Colors.blue : Colors.transparent,
              width: 4,
            ),
          ),
        ),
        child: Row(
          children: [
            Radio<String>(
              value: value,
              groupValue: selectedPaymentMethod,
              onChanged: (value) => setState(() => selectedPaymentMethod = value!),
              activeColor: Colors.blue,
            ),
            const SizedBox(width: 10),
            Image.asset(imagePath, height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildVisaForm() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildTextField(
            controller: cardNumberController,
            label: "Card Number",
            icon: Icons.credit_card,
            keyboardType: TextInputType.number,
            formatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(16),
            ],
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: cardNameController,
            label: "Cardholder Name",
            icon: Icons.person,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: expiryDateController,
                  label: "MM/YY",
                  icon: Icons.date_range,
                  formatters: [
                    LengthLimitingTextInputFormatter(5),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTextField(
                  controller: cvvController,
                  label: "CVV",
                  icon: Icons.lock,
                  obscureText: true,
                  formatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(3),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWalletForm() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: _buildTextField(
        controller: phoneController,
        label: "Phone Number",
        icon: Icons.phone,
        keyboardType: TextInputType.phone,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    TextInputType? keyboardType,
    List<TextInputFormatter>? formatters,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        inputFormatters: formatters,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.blue),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildAmountInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            "Amount to Deposit",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: amountController,
            label: "Amount in EGP",
            icon: Icons.attach_money,
            keyboardType: TextInputType.number,
          ),
        ],
      ),
    );
  }

  Widget _buildDepositButton() {
    return ElevatedButton(
      onPressed: () {
        int depositAmount = int.tryParse(amountController.text) ?? 0;
        if (depositAmount > 0) {
          setState(() => balance += depositAmount);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Successfully deposited $depositAmount EGP"),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.add_circle_outline),
          SizedBox(width: 8),
          Text(
            "Deposit Now",
            style: TextStyle(fontSize: 18),
          ),
        ],
      ),
    );
  }
}