import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/dashboard_provider.dart';

class LedgerScreen extends StatefulWidget {
  const LedgerScreen({super.key});

  @override
  State<LedgerScreen> createState() => _LedgerScreenState();
}

class _LedgerScreenState extends State<LedgerScreen> {
  bool _isLoading = true;
  List<dynamic> _transactions = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
       _fetchTransactions();
    });
  }

  Future<void> _fetchTransactions() async {
     try {
       final provider = Provider.of<DashboardProvider>(context, listen: false);
       final data = await provider.fetchTransactionsList();
       if (mounted) {
         setState(() {
           _transactions = data;
           _isLoading = false;
         });
       }
     } catch (e) {
       if (mounted) {
         setState(() {
           _error = e.toString();
           _isLoading = false;
         });
       }
     }
  }

  @override
  Widget build(BuildContext context) {
    final format = NumberFormat.currency(locale: "en_IN", symbol: "₹");

    return Scaffold(
      appBar: AppBar(title: const Text("Business Ledger")),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator()) 
          : _error != null 
              ? Center(child: Text("Error: $_error"))
              : _transactions.isEmpty 
                  ? const Center(child: Text("No transactions found"))
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: _transactions.length,
                      separatorBuilder: (_, __) => const Divider(),
                      itemBuilder: (ctx, index) {
                         final item = _transactions[index];
                         final isIncome = item['is_income'] == true;
                         final amount = (item['amount'] ?? 0).toDouble();
                         final dateStr = item['date'] ?? '';
                         DateTime? date;
                         try { date = DateTime.parse(dateStr); } catch (_) {}

                         return ListTile(
                           leading: CircleAvatar(
                             backgroundColor: isIncome ? Colors.green[50] : Colors.red[50], // Light BG
                             child: Icon(
                               isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                               color: isIncome ? Colors.green : Colors.red,
                             ),
                           ),
                           title: Text(item['description'] ?? 'Unknown', style: const TextStyle(fontWeight: FontWeight.bold)),
                           subtitle: Text(date != null ? DateFormat('MMM dd, hh:mm a').format(date) : dateStr),
                           trailing: Text(
                             "${isIncome ? '+' : '-'} ${format.format(amount)}",
                             style: TextStyle(
                               color: isIncome ? Colors.green[800] : Colors.red[800],
                               fontWeight: FontWeight.bold,
                               fontSize: 15
                             ),
                           ),
                         );
                      },
                    ),
    );
  }
}
