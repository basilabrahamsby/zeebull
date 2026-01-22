import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/inventory_provider.dart';
import 'package:intl/intl.dart';

class WasteLogScreen extends StatefulWidget {
  const WasteLogScreen({super.key});

  @override
  State<WasteLogScreen> createState() => _WasteLogScreenState();
}

class _WasteLogScreenState extends State<WasteLogScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        Provider.of<InventoryProvider>(context, listen: false).fetchWasteLogs());
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<InventoryProvider>(context);

    // Calculate KPIs
    int totalCount = provider.wasteLogs.length;
    double totalQty = provider.wasteLogs.fold(0, (sum, item) => sum + (double.tryParse(item['quantity'].toString()) ?? 0));
    String today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    int todayCount = provider.wasteLogs.where((l) => (l['waste_date'] ?? '').toString().startsWith(today)).length;

    return Scaffold(
      appBar: AppBar(title: const Text('Waste Log'), elevation: 0),
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
                       Expanded(child: _kpi("Incidents", "$totalCount", Colors.brown)),
                       const SizedBox(width: 12),
                       Expanded(child: _kpi("Total Qty", totalQty.toStringAsFixed(1), Colors.red)),
                       const SizedBox(width: 12),
                       Expanded(child: _kpi("Today", "$todayCount", Colors.orange)),
                     ],
                   ),
                ),
                
                Expanded(
                  child: provider.wasteLogs.isEmpty 
                    ? const Center(child: Text("No waste records found"))
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: provider.wasteLogs.length,
                        itemBuilder: (context, index) {
                          final log = provider.wasteLogs[index];
                          final date = log['waste_date'] != null ? DateTime.tryParse(log['waste_date']) ?? DateTime.now() : DateTime.now();
                          
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.brown.shade100,
                                child: const Icon(Icons.delete_outline, color: Colors.brown),
                              ),
                              title: Text(log['item_name'] ?? 'Unknown Item', style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("${log['reason_code']} • ${DateFormat('MMM d, yyyy').format(date)}"),
                                  if (log['notes'] != null && log['notes'].toString().isNotEmpty)
                                    Text("Note: ${log['notes']}", style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                                ],
                              ),
                              trailing: Text(
                                '-${log['quantity']} ${log['unit']}',
                                style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 16),
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
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: color.withOpacity(0.2))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
           Text(title, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
           const SizedBox(height: 4),
           Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}
