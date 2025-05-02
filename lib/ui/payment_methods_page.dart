import 'package:flutter/material.dart';
import 'package:egy_metro/cubit/wallet_logic.dart';

class PaymentMethodsPage extends StatefulWidget {
  @override
  _PaymentMethodsPageState createState() => _PaymentMethodsPageState();
}

class _PaymentMethodsPageState extends State<PaymentMethodsPage> {
  bool isLoading = true;
  List<dynamic> paymentMethods = [];

  @override
  void initState() {
    super.initState();
    _loadPaymentMethods();
  }

  Future<void> _loadPaymentMethods() async {
    setState(() => isLoading = true);
    final result = await WalletLogic.getPaymentMethods();
    
    if (result['success']) {
      setState(() {
        // Updated to handle new data structure
        paymentMethods = result['data']['results'] ?? [];
        isLoading = false;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load payment methods')),
      );
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Payment Methods'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: paymentMethods.length + 1,
              itemBuilder: (context, index) {
                if (index == paymentMethods.length) {
                  return _buildAddPaymentMethodButton();
                }
                return _buildPaymentMethodItem(paymentMethods[index]);
              },
            ),
    );
  }

  Widget _buildPaymentMethodItem(Map<String, dynamic> method) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.all(16),
        leading: Icon(
          _getPaymentMethodIcon(method['payment_type']), // Updated field name
          color: Colors.blue,
          size: 32,
        ),
        title: Text(
          method['name'] ?? 'Payment Method',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${method['card_brand']} **** ${method['card_last4']}',
              style: TextStyle(color: Colors.grey),
            ),
            
            if (method['is_default'] == true)
              Container(
                margin: EdgeInsets.only(top: 4),
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Default',
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        ),
        trailing: IconButton(
          icon: Icon(Icons.delete, color: Colors.red),
          onPressed: () => _showDeleteConfirmation(method),
        ),
      ),
    );
  }

  Widget _buildAddPaymentMethodButton() {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: InkWell(
        onTap: () => _showAddPaymentMethodDialog(),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_circle_outline, color: Colors.blue),
              SizedBox(width: 8),
              Text(
                'Add New Payment Method',
                style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getPaymentMethodIcon(String type) {
    switch (type.toUpperCase()) {
      case 'CREDIT_CARD':
        return Icons.credit_card;
      case 'DEBIT_CARD':
        return Icons.credit_card;
      case 'FAWRY':
        return Icons.account_balance;
      default:
        return Icons.payment;
    }
  }

  void _showDeleteConfirmation(Map<String, dynamic> method) {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Payment Method'),
        content: Text('Are you sure you want to delete this payment method?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context); // Close dialog
              setState(() => isLoading = true);

              final paymentMethodId = method['id'];
              if (paymentMethodId != null) {
                final result = await WalletLogic.deletePaymentMethod(paymentMethodId);
                
                if (!mounted) return;

                scaffoldMessenger.showSnackBar(
                  SnackBar(
                    content: Text(result['message'] ?? 'Operation completed'),
                    backgroundColor: result['success'] ? Colors.green : Colors.red,
                  ),
                );

                if (result['success']) {
                  _loadPaymentMethods(); // Reload the list
                } else {
                  setState(() => isLoading = false);
                }
              } else {
                setState(() => isLoading = false);
                scaffoldMessenger.showSnackBar(
                  SnackBar(
                    content: Text('Payment method ID not found'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddPaymentMethodDialog() {
    final _formKey = GlobalKey<FormState>();
    String? paymentType;
    String? name;
    String? cardLast4;
    String? cardBrand;
    String? expiryMonth;
    String? expiryYear;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          padding: EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Add Payment Method',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 20),
                  
                  // Payment Type Dropdown
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Payment Type',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: Icon(Icons.payment),
                    ),
                    items: [
                      'CREDIT_CARD',
                      'DEBIT_CARD', 
                      'FAWRY',
                    ].map((type) {
                      return DropdownMenuItem(
                        value: type,
                        child: Text(type.replaceAll('_', ' ')),
                      );
                    }).toList(),
                    onChanged: (value) {
                      paymentType = value;
                    },
                    validator: (value) {
                      if (value == null) return 'Please select payment type';
                      return null;
                    },
                  ),
                  SizedBox(height: 16),

                  // Name Field
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Card Holder Name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: Icon(Icons.person),
                    ),
                    onChanged: (value) => name = value,
                    validator: (value) {
                      if (value?.isEmpty ?? true) return 'Please enter name';
                      return null;
                    },
                  ),
                  SizedBox(height: 16),

                  // Card Last 4 Digits
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Last 4 Digits',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: Icon(Icons.credit_card),
                    ),
                    maxLength: 4,
                    keyboardType: TextInputType.number,
                    onChanged: (value) => cardLast4 = value,
                    validator: (value) {
                      if (value?.length != 4) return 'Please enter 4 digits';
                      return null;
                    },
                  ),
                  SizedBox(height: 16),

                  // Card Brand
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Card Brand',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: Icon(Icons.credit_card),
                    ),
                    items: [
                      'VISA',
                      'MASTERCARD',
                      'AMERICAN_EXPRESS',
                    ].map((brand) {
                      return DropdownMenuItem(
                        value: brand,
                        child: Text(brand.replaceAll('_', ' ')),
                      );
                    }).toList(),
                    onChanged: (value) {
                      cardBrand = value;
                    },
                    validator: (value) {
                      if (value == null) return 'Please select card brand';
                      return null;
                    },
                  ),
                  SizedBox(height: 16),

                  // Expiry Date Row
                  Row(
                    children: [
                      // Month
                      Expanded(
                        child: TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Month (MM)',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            prefixIcon: Icon(Icons.calendar_today),
                          ),
                          maxLength: 2,
                          keyboardType: TextInputType.number,
                          onChanged: (value) => expiryMonth = value,
                          validator: (value) {
                            if (value?.isEmpty ?? true) return 'Required';
                            int? month = int.tryParse(value!);
                            if (month == null || month < 1 || month > 12) {
                              return 'Invalid';
                            }
                            return null;
                          },
                        ),
                      ),
                      SizedBox(width: 16),
                      // Year
                      Expanded(
                        child: TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Year (YY)',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            prefixIcon: Icon(Icons.calendar_today),
                          ),
                          maxLength: 4,
                          keyboardType: TextInputType.number,
                          onChanged: (value) => expiryYear = value,
                          validator: (value) {
                            if (value?.isEmpty ?? true) return 'Required';
                            int? year = int.tryParse(value!);
                            if (year == null || year < 0) {
                              return 'Invalid';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24),

                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () async {
  if (_formKey.currentState!.validate()) {
    try {
      // Show loading
      setState(() => isLoading = true);
      
      // Convert month and year to integers
      final month = int.parse(expiryMonth!);
      final year = int.parse(expiryYear!);
      
      // Call API
      final result = await WalletLogic.addPaymentMethod(
        paymentType: paymentType!,
        name: name!,
        cardLast4: cardLast4!,
        cardBrand: cardBrand!,
        cardExpiryMonth: month,
        cardExpiryYear: year,
        isDefault: true,
      );

      if (!mounted) return;

      // Close dialog
      Navigator.pop(context);

      // Show result message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result['success'] 
                ? 'Payment method added successfully'
                : result['message'] ?? 'Failed to add payment method'
          ),
          backgroundColor: result['success'] ? Colors.green : Colors.red,
        ),
      );

      // Reload payment methods if successful
      if (result['success']) {
        _loadPaymentMethods();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }
},
child: isLoading
    ? CircularProgressIndicator(color: Colors.white)
    : Text(
        'Add Payment Method',
        style: TextStyle(fontSize: 16),
      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}