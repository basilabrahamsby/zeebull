import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/inventory_provider.dart';
import 'package:intl/intl.dart';

class StockIssuesScreen extends StatefulWidget {
  const StockIssuesScreen({super.key});

  @override
  State<StockIssuesScreen> createState() => _StockIssuesScreenState();
}

class _StockIssuesScreenState extends State<StockIssuesScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        Provider.of<InventoryProvider>(context, listen: false).fetchStockIssues());
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<InventoryProvider>(context);
    
    // Calculate KPIs
    int totalIssues = provider.stockIssues.length;
    // Count distinct destinations
    Set<String> destinations = provider.stockIssues.map((i) => i['destination_location_name'].toString()).toSet();
    // Issues today
    String today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    int todayIssues = provider.stockIssues.where((i) => i['issue_date'].toString().startsWith(today)).length;

    return Scaffold(
      appBar: AppBar(title: const Text('Stock Issues & Transfers'), elevation: 0),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Dashboard
                Container(
                   padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                   color: Theme.of(context).primaryColor.withOpacity(0.05),
                   child: Row(
                     children: [
                       Expanded(child: _kpi("Total Issues", "$totalIssues", Colors.deepOrange)),
                       const SizedBox(width: 12),
                       Expanded(child: _kpi("Today", "$todayIssues", Colors.blue)),
                       const SizedBox(width: 12),
                       Expanded(child: _kpi("Destinations", "${destinations.length}", Colors.purple)),
                     ],
                   ),
                ),
                
                Expanded(
                  child: provider.stockIssues.isEmpty
                    ? const Center(child: Text("No stock issues found"))
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: provider.stockIssues.length,
                        itemBuilder: (context, index) {
                          final issue = provider.stockIssues[index];
                          final details = issue['details'] as List<dynamic>;
                          final date = DateTime.tryParse(issue['issue_date']) ?? DateTime.now();
                          
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ExpansionTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.deepOrange.shade100,
                                child: const Icon(Icons.output, color: Colors.deepOrange),
                              ),
                              title: Text("Issue #${issue['issue_number']}", style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("${DateFormat('MMM d, yyyy').format(date)}"),
                                  Text("To: ${issue['destination_location_name'] ?? 'Unknown Location'}", style: TextStyle(color: Colors.grey.shade700)),
                                ],
                              ),
                              children: [
                                 Padding(
                                   padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                                   child: Column(
                                     crossAxisAlignment: CrossAxisAlignment.stretch,
                                     children: [
                                       const Divider(),
                                       ...details.map((d) => Padding(
                                         padding: const EdgeInsets.symmetric(vertical: 4),
                                         child: Row(
                                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                           children: [
                                             Expanded(child: Text(d['item_name'] ?? 'Unknown Item')),
                                             Text("${d['issued_quantity']} ${d['unit']}", style: const TextStyle(fontWeight: FontWeight.bold)),
                                           ],
                                         ),
                                       )),
                                       if (issue['notes'] != null && issue['notes'].isNotEmpty)
                                          Padding(
                                            padding: const EdgeInsets.only(top: 8),
                                            child: Text("Note: ${issue['notes']}", style: const TextStyle(fontStyle: FontStyle.italic)),
                                          ),
                                     ],
                                   ),
                                 )
                              ],
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
