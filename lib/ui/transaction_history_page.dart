/*import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:egy_metro/cubit/wallet_logic.dart';

class TransactionHistoryPage extends StatefulWidget {
  @override
  _TransactionHistoryPageState createState() => _TransactionHistoryPageState();
}

class _TransactionHistoryPageState extends State<TransactionHistoryPage> {
  bool isLoading = true;
  List<dynamic> transactions = [];
  String? selectedFilter;

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions({String? type}) async {
    setState(() => isLoading = true);
    final result = await WalletLogic.getRecentTransactions(
      
    );
    
    if (result['success']) {
      setState(() {
        transactions = result['data']['transactions'] ?? [];
        isLoading = false;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load transactions')),
      );
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Transaction History'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() => selectedFilter = value);
              _loadTransactions(type: value == 'All' ? null : value);
            },
            itemBuilder: (context) => [
              PopupMenuItem(value: 'All', child: Text('All')),
              PopupMenuItem(value: 'CREDIT', child: Text('Credits')),
              PopupMenuItem(value: 'DEBIT', child: Text('Debits')),
            ],
            icon: Icon(Icons.filter_list),
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : transactions.isEmpty
              ? Center(child: Text('No transactions found'))
              : ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: transactions.length,
                  itemBuilder: (context, index) {
                    final transaction = transactions[index];
                    return _buildTransactionItem(transaction);
                  },
                ),
    );
  }

  Widget _buildTransactionItem(Map<String, dynamic> transaction) {
    final isCredit = transaction['type'] == 'CREDIT';
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.all(16),
        leading: Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isCredit ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            isCredit ? Icons.add_circle : Icons.remove_circle,
            color: isCredit ? Colors.green : Colors.red,
          ),
        ),
        title: Text(
          transaction['description'] ?? 'Transaction',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 8),
            Text(
              DateFormat('MMM dd, yyyy - HH:mm').format(
                DateTime.parse(transaction['date']),
              ),
              style: TextStyle(color: Colors.grey),
            ),
            if (transaction['status'] != null)
              Container(
                margin: EdgeInsets.only(top: 8),
                padding: EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _getStatusColor(transaction['status']),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  transaction['status'],
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        ),
        trailing: Text(
          '${isCredit ? '+' : '-'} EGP ${transaction['amount'].toStringAsFixed(2)}',
          style: TextStyle(
            color: isCredit ? Colors.green : Colors.red,
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
}*/