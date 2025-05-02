import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:egy_metro/cubit/wallet_logic.dart';
import 'package:egy_metro/ui/add_funds_bottom_sheet.dart';
import 'package:egy_metro/ui/payment_methods_page.dart';
import 'package:egy_metro/ui/transaction_history_page.dart';
import 'dart:math';

class WalletPage extends StatefulWidget {
  @override
  _WalletPageState createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  bool isLoading = true;
  Map<String, dynamic>? walletData;
  List<dynamic> recentTransactions = [];

  @override
  void initState() {
    super.initState();
    _loadWalletData();
  }

  Future<void> _loadWalletData() async {
  setState(() => isLoading = true);
  
  try {
    final result = await WalletLogic.getWalletDetails();
    final transactionsResult = await WalletLogic.getRecentTransactions();
    
    if (mounted) {
      setState(() {
        walletData = result['success'] ? result['data'] : null;
        
        // تصحيح كيفية الوصول إلى المعاملات
        if (transactionsResult['success'] && transactionsResult['data'] != null) {
          recentTransactions = List<Map<String, dynamic>>.from(
            transactionsResult['data'] as List
          );
        } else {
          recentTransactions = [];
        }
        
        isLoading = false;
      });
    }
  } catch (e) {
    print('Error loading wallet data: $e');
    if (mounted) {
      setState(() {
        walletData = null;
        recentTransactions = [];
        isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load wallet data'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F6FA),
      appBar: AppBar(
        title: Text('My Wallet'),
        elevation: 0,
        actions: [
          
          IconButton(
            icon: Icon(Icons.payment),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => PaymentMethodsPage()),
            ),
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadWalletData,
              child: SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildBalanceCard(),
                      SizedBox(height: 20),
                      _buildActionButtons(),
                      SizedBox(height: 20),
                      _buildRecentTransactions(),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildBalanceCard() {
  return Container(
    width: double.infinity,
    padding: EdgeInsets.all(20),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [Colors.blue, Colors.blue.shade800],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: Colors.blue.withOpacity(0.2),
          blurRadius: 10,
          offset: Offset(0, 5),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Current Balance',
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 16,
          ),
        ),
        SizedBox(height: 8),
        Text(
          'EGP ${walletData?['balance']?.toStringAsFixed(2) ?? '0.00'}',
          style: TextStyle(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (walletData?['is_active'] == true)
          Container(
            margin: EdgeInsets.only(top: 8),
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Active',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    ),
  );
}

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 15),
              backgroundColor: Colors.green,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            onPressed: () => _showAddFundsDialog(),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_circle_outline),
                SizedBox(width: 8),
                Text('Add Funds'),
              ],
            ),
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 15),
              backgroundColor: Colors.orange,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => PaymentMethodsPage()),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.payment),
                SizedBox(width: 8),
                Text('Methods'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecentTransactions() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Recent Transactions',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          
        ],
      ),
      if (recentTransactions.isEmpty)
        Center(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Text('No recent transactions'),
          ),
        )
      else
        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: min(recentTransactions.length, 5),
          itemBuilder: (context, index) {
            if (index < recentTransactions.length) {
              return _buildTransactionItem(recentTransactions[index]);
            }
            return SizedBox.shrink();
          },
        ),
    ],
  );
}

Widget _buildTransactionItem(Map<String, dynamic> transaction) {
  final isDeposit = transaction['type'] == 'DEPOSIT';
  final amount = double.parse(transaction['amount'].toString());
  final status = transaction['status'];
  final createdAt = DateTime.parse(transaction['created_at']);

  return Card(
    margin: EdgeInsets.symmetric(vertical: 8),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(15),
    ),
    child: ListTile(
      contentPadding: EdgeInsets.all(12),
      leading: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isDeposit ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          isDeposit ? Icons.add_circle : Icons.remove_circle,
          color: isDeposit ? Colors.green : Colors.red,
        ),
      ),
      title: Text(
        transaction['description'] ?? 'Transaction',
        style: TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 16,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 4),
          Text(
            transaction['payment_method_name'] ?? '',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
          SizedBox(height: 4),
          Text(
            DateFormat('MMM dd, yyyy - HH:mm').format(createdAt),
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
          SizedBox(height: 4),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: _getStatusColor(status).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              status,
              style: TextStyle(
                color: _getStatusColor(status),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
      trailing: Text(
        '${isDeposit ? '+' : '-'} EGP ${amount.toStringAsFixed(2)}',
        style: TextStyle(
          color: isDeposit ? Colors.green : Colors.red,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    ),
  );
}

Color _getStatusColor(String status) {
  switch (status.toUpperCase()) {
    case 'COMPLETED':
      return Colors.green;
    case 'PENDING':
      return Colors.orange;
    case 'FAILED':
      return Colors.red;
    default:
      return Colors.grey;
  }
}
  void _showAddFundsDialog() async {
  final _formKey = GlobalKey<FormState>();
  double? amount;
  String? selectedPaymentMethodId;
  bool isLoading = false;

  // جلب وسائل الدفع المتاحة
  final paymentMethodsResult = await WalletLogic.getPaymentMethods();
  final paymentMethods = paymentMethodsResult['success'] == true 
      ? paymentMethodsResult['data']['results'] ?? []
      : [];

  showDialog(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => Dialog(
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
                    'Add Funds',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 20),

                  // Amount Field
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Amount (EGP)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: Icon(Icons.money),
                    ),
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter amount';
                      }
                      final amount = double.tryParse(value);
                      if (amount == null || amount <= 0) {
                        return 'Please enter a valid amount';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      amount = double.tryParse(value);
                    },
                  ),
                  SizedBox(height: 16),

                  // Payment Method Dropdown
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Select Payment Method',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: Icon(Icons.payment),
                    ),
                    items: paymentMethods.map<DropdownMenuItem<String>>((method) {
                      return DropdownMenuItem<String>(
                        value: method['id'],
                        child: Text(
                          '${method['card_brand']} **** ${method['card_last4']}',
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      selectedPaymentMethodId = value;
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Please select a payment method';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 24),

                  // Add Funds Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: isLoading ? null : () async {
                        if (_formKey.currentState!.validate()) {
                          setState(() => isLoading = true);

                          final result = await WalletLogic.addFunds(
                            amount: amount!,
                            paymentMethodId: selectedPaymentMethodId!,
                          );

                          if (!mounted) return;

                          Navigator.pop(context);

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                result['message'] ?? 'Operation completed'
                              ),
                              backgroundColor: result['success'] 
                                  ? Colors.green 
                                  : Colors.red,
                            ),
                          );

                          if (result['success']) {
                            // تحديث بيانات المحفظة
                            _loadWalletData();
                          }
                        }
                      },
                      child: isLoading
                          ? CircularProgressIndicator(color: Colors.white)
                          : Text(
                              'Add Funds',
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
    ),
  );
}
}