import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/dashboard_provider.dart';

class VendorDetailScreen extends StatefulWidget {
  final dynamic vendor;
  const VendorDetailScreen({super.key, required this.vendor});

  @override
  State<VendorDetailScreen> createState() => _VendorDetailScreenState();
}

class _VendorDetailScreenState extends State<VendorDetailScreen> {
  bool _isLoading = true;
  List<dynamic> _transactions = [];

  @override
  void initState() {
    super.initState();
    _fetchTransactions();
  }

  Future<void> _fetchTransactions() async {
    final id = widget.vendor['id'];
    if (id == null) return;
    final data = await Provider.of<DashboardProvider>(context, listen: false).fetchVendorTransactions(id);
    if (mounted) {
      setState(() {
        _transactions = data;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final format = NumberFormat.currency(locale: "en_IN", symbol: "₹");
    final v = widget.vendor;

    return Scaffold(
      appBar: AppBar(title: Text(v['name'] ?? 'Vendor Details')),
      body: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            color: Colors.blueGrey[50], // Light background
            child: Column(
              children: [
                Text(v['company_name'] ?? '', style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 10),
                Row(
                   mainAxisAlignment: MainAxisAlignment.spaceAround,
                   children: [
                     _metric("Total Purchased", v['total_purchases'], format, Colors.blue),
                     _metric("Balance Due", v['balance'], format, Colors.red)
                   ]
                )
              ],
            ),
          ),
          
          Expanded(
            child: _isLoading 
              ? const Center(child: CircularProgressIndicator())
              : _transactions.isEmpty
                 ? const Center(child: Text("No transaction history."))
                 : ListView.separated(
                     padding: const EdgeInsets.all(16),
                     itemCount: _transactions.length,
                     separatorBuilder: (_, __) => const Divider(),
                     itemBuilder: (ctx, index) {
                        final t = _transactions[index];
                        final date = t['date'] ?? '';
                        final amount = (t['amount'] ?? 0).toDouble();
                        final status = t['status'] ?? 'Due';
                        
                        return ListTile(
                          title: Text("PO #${t['number']}", style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text("$date\n${t['remarks'] ?? ''}"),
                          isThreeLine: true,
                          trailing: Column(
                             mainAxisAlignment: MainAxisAlignment.center,
                             crossAxisAlignment: CrossAxisAlignment.end,
                             children: [
                               Text(format.format(amount), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                               const SizedBox(height: 4),
                               Container(
                                 padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                 decoration: BoxDecoration(
                                   color: status == 'Paid' ? Colors.green[100] : Colors.orange[100],
                                   borderRadius: BorderRadius.circular(4)
                                 ),
                                 child: Text(status, style: TextStyle(fontSize: 10, color: status == 'Paid' ? Colors.green[800] : Colors.orange[800])),
                               )
                             ],
                          ),
                        );
                     },
                   ),
          )
        ],
      ),
    );
  }

  Widget _metric(String label, dynamic value, NumberFormat fmt, Color color) {
     return Column(
       children: [
         Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
         Text(fmt.format(value), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: color)),
       ],
     );
  }
}
