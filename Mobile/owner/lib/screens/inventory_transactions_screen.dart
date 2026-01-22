import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/inventory_provider.dart';
import 'package:intl/intl.dart';

class InventoryTransactionsScreen extends StatefulWidget {
  const InventoryTransactionsScreen({super.key});

  @override
  State<InventoryTransactionsScreen> createState() => _InventoryTransactionsScreenState();
}

class _InventoryTransactionsScreenState extends State<InventoryTransactionsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        Provider.of<InventoryProvider>(context, listen: false).fetchTransactions());
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<InventoryProvider>(context);

    // Calculate KPIs
    int totalCount = provider.transactions.length;
    double totalIn = 0;
    double totalOut = 0;
    double totalWaste = 0;

    for (var t in provider.transactions) {
       String type = (t['transaction_type'] ?? '').toString().toUpperCase();
       double qty = double.tryParse(t['quantity'].toString()) ?? 0;
       
       if (type.contains('IN') || type.contains('PURCHASE') || type.contains('RECEIVE')) {
         totalIn += qty;
       } else if (type.contains('WASTE') || type.contains('SPOILAGE') || type.contains('DAMAGED')) {
         totalWaste += qty;
       } else {
         // Assume OUT for everything else unless explicitly specified
         totalOut += qty;
       }
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Transactions'), elevation: 0),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // KPI Dashboard
                Container(
                   padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                   color: Theme.of(context).primaryColor.withOpacity(0.05),
                   child: Row(
                     children: [
                       Expanded(child: _kpi("Transactions", "$totalCount", Colors.blueGrey)),
                       const SizedBox(width: 8),
                       Expanded(child: _kpi("Stock In", totalIn.toStringAsFixed(0), Colors.green)),
                       const SizedBox(width: 8),
                       Expanded(child: _kpi("Stock Out", totalOut.toStringAsFixed(0), Colors.orange)),
                       const SizedBox(width: 8),
                       Expanded(child: _kpi("Waste", totalWaste.toStringAsFixed(0), Colors.red)),
                     ],
                   ),
                ),
                
                Expanded(
                  child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: provider.transactions.length,
              itemBuilder: (context, index) {
                final trans = provider.transactions[index];
                final isPositive = trans['transaction_type'] == 'in' || trans['transaction_type'] == 'adjustment' && (trans['quantity'] ?? 0) > 0;
                final date = trans['created_at'] != null ? DateTime.parse(trans['created_at']) : DateTime.now();
                
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: isPositive ? Colors.green.shade50 : Colors.red.shade50,
                      child: Icon(
                        isPositive ? Icons.arrow_downward : Icons.arrow_upward,
                        color: isPositive ? Colors.green : Colors.red,
                        size: 20
                      ),
                    ),
                    title: Text(trans['item_name'] ?? 'Unknown Item', style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                         Text("${trans['transaction_type'].toString().toUpperCase()} • ${DateFormat('MMM d, h:mm a').format(date)}"),
                         if (trans['notes'] != null && trans['notes'].toString().isNotEmpty)
                           Text(trans['notes'], style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                      ],
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${isPositive ? '+' : '-'}${trans['quantity']} ${trans['unit'] ?? ''}',
                          style: TextStyle(fontWeight: FontWeight.bold, color: isPositive ? Colors.green : Colors.red),
                        ),
                        Text(
                          trans['created_by_name'] ?? 'System',
                          style: const TextStyle(fontSize: 10, color: Colors.grey),
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
    );
  }

  Widget _kpi(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: color.withOpacity(0.2))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
           Text(title, style: TextStyle(fontSize: 10, color: Colors.grey.shade600), maxLines: 1, overflow: TextOverflow.ellipsis),
           const SizedBox(height: 4),
           Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}
