import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/dashboard_provider.dart';

class PnLScreen extends StatefulWidget {
  const PnLScreen({super.key});

  @override
  State<PnLScreen> createState() => _PnLScreenState();
}

class _PnLScreenState extends State<PnLScreen> {
  bool _isLoading = true;
  Map<String, dynamic> _data = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  Future<void> _loadData() async {
    final provider = Provider.of<DashboardProvider>(context, listen: false);
    final data = await provider.fetchPnL();
    if(mounted) {
      setState(() {
        _data = data;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (_data.isEmpty) return const Scaffold(body: Center(child: Text("No Data")));

    final revenue = _data['revenue'] ?? {};
    final expenses = _data['expenses'] ?? {};
    final netProfit = (_data['net_profit'] ?? 0).toDouble();
    final format = NumberFormat.currency(locale: 'en_IN', symbol: '₹');

    return Scaffold(
      appBar: AppBar(title: const Text("Profit & Loss (Month)")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildSection("Revenue", revenue, format, Colors.green),
            const SizedBox(height: 20),
            _buildSection("Expenses", expenses, format, Colors.red),
             const SizedBox(height: 20),
             Card(
               color: netProfit >= 0 ? Colors.green[50] : Colors.red[50],
               child: Padding(
                 padding: const EdgeInsets.all(20),
                 child: Row(
                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                   children: [
                     const Text("Net Profit", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                     Text(format.format(netProfit), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, 
                       color: netProfit >= 0 ? Colors.green[800] : Colors.red[800]))
                   ],
                 ),
               ),
             )
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, Map<String, dynamic> data, NumberFormat format, Color color) {
    // Flatten data for display
    final List<Widget> rows = [];
    double total = (data['total'] ?? 0).toDouble();

    data.forEach((k, v) {
      if (k == 'total' || k == 'operational' || k == 'by_mode') return; // Skip complex or total
      rows.add(_buildRow(k.toUpperCase(), (v ?? 0).toDouble(), format));
    });
    
    // Handle operational expenses list
    if (data['operational'] is List) {
       for (var item in data['operational']) {
         rows.add(_buildRow(item['category'] ?? 'Misc', (item['amount'] ?? 0).toDouble(), format));
       }
    }

    // Handle Payment Modes (Revenue)
    if (data['by_mode'] is Map) {
       rows.add(const Divider());
       rows.add(Padding(
         padding: const EdgeInsets.symmetric(vertical: 4),
         child: Text("By Payment Mode", style: TextStyle(fontSize: 13, color: Colors.grey[700], fontWeight: FontWeight.bold)),
       ));
       final modes = data['by_mode'] as Map;
       modes.forEach((k, v) {
          rows.add(_buildRow(k.toString(), (v??0).toDouble(), format));
       });
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
            const Divider(),
            ...rows,
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("TOTAL", style: TextStyle(fontWeight: FontWeight.bold)),
                Text(format.format(total), style: TextStyle(fontWeight: FontWeight.bold, color: color)),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildRow(String label, double amount, NumberFormat format) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
         mainAxisAlignment: MainAxisAlignment.spaceBetween,
         children: [
           Text(label, style: const TextStyle(fontSize: 13)),
           Text(format.format(amount), style: const TextStyle(fontSize: 13)),
         ],
      ),
    );
  }
}
