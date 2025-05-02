/*import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:egy_metro/cubit/wallet_logic.dart';

class AddFundsBottomSheet extends StatefulWidget {
  @override
  _AddFundsBottomSheetState createState() => _AddFundsBottomSheetState();
}

class _AddFundsBottomSheetState extends State<AddFundsBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  String? _selectedPaymentMethod;
  bool _isLoading = false;
  List<String> _paymentMethods = ['Credit Card', 'Debit Card', 'Fawry'];

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _addFunds() async {
    if (!_formKey.currentState!.validate() || _selectedPaymentMethod == null) {
      return;
    }

    setState(() => _isLoading = true);

    final amount = double.parse(_amountController.text);
    final result = await WalletLogic.addFunds(
      amount: amount,
      paymentMethod: _selectedPaymentMethod!,
    );

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (result['success']) {
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Funds added successfully')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'] ?? 'Failed to add funds')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Add Funds',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            TextFormField(
              controller: _amountController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Amount (EGP)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: Icon(Icons.money),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter an amount';
                }
                final amount = double.tryParse(value);
                if (amount == null || amount <= 0) {
                  return 'Please enter a valid amount';
                }
                return null;
              },
            ),
            SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedPaymentMethod,
              decoration: InputDecoration(
                labelText: 'Payment Method',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: Icon(Icons.payment),
              ),
              items: _paymentMethods.map((method) {
                return DropdownMenuItem(
                  value: method,
                  child: Text(method),
                );
              }).toList(),
              onChanged: (value) {
                setState(() => _selectedPaymentMethod = value);
              },
              validator: (value) {
                if (value == null) {
                  return 'Please select a payment method';
                }
                return null;
              },
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _addFunds,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isLoading
                  ? CircularProgressIndicator(color: Colors.white)
                  : Text('Add Funds'),
            ),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}*/