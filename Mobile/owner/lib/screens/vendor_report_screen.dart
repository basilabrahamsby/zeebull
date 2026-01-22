import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/dashboard_provider.dart';
import 'vendor_detail_screen.dart';

class VendorReportScreen extends StatefulWidget {
  const VendorReportScreen({Key? key}) : super(key: key);

  @override
  State<VendorReportScreen> createState() => _VendorReportScreenState();
}

class _VendorReportScreenState extends State<VendorReportScreen> {
  bool _isLoading = true;
  List<dynamic> _vendors = [];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    final data = await Provider.of<DashboardProvider>(context, listen: false).fetchVendorStats();
    if (mounted) {
      setState(() {
        _vendors = data;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final format = NumberFormat.currency(locale: "en_IN", symbol: "₹");

    return Scaffold(
      appBar: AppBar(title: const Text("Vendor Payables")),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : _vendors.isEmpty
          ? const Center(child: Text("No Vendor activity found."))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _vendors.length,
              itemBuilder: (context, index) {
                final v = _vendors[index];
                final balance = (v['balance'] ?? 0).toDouble();
                // final purchases = (v['total_purchases'] ?? 0).toDouble();
                // final payments = (v['total_payments'] ?? 0).toDouble();

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    title: Text(v['name'] ?? 'Unknown', style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(v['company_name'] ?? 'No Company Name'),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          format.format(balance),
                          style: TextStyle(
                            color: balance > 0 ? Colors.red : Colors.green,
                            fontWeight: FontWeight.bold,
                            fontSize: 16
                          ),
                        ),
                        Text("Due", style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                      ],
                    ),
                    onTap: () {
                         _showDetails(context, v);
                    },
                  ),
                );
              },
            ),
    );
  }

  void _showDetails(BuildContext context, dynamic vendor) {
      final format = NumberFormat.currency(locale: "en_IN", symbol: "₹");
      showModalBottomSheet(
          context: context,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20))
          ),
          builder: (ctx) => Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                      Text(vendor['name'], style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      _row("Total Purchases (Billed)", vendor['total_purchases'], format),
                      const Divider(),
                      _row("Total Payments", vendor['total_payments'], format),
                      const Divider(thickness: 2),
                      _row("Outstanding Balance", vendor['balance'], format, isBold: true),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                           onPressed: () {
                              Navigator.pop(context); 
                              Navigator.push(context, MaterialPageRoute(builder: (_) => VendorDetailScreen(vendor: vendor)));
                           },
                           child: const Text("View Transaction History"),
                        ),
                      )
                  ],
              ),
          )
      );
  }

  Widget _row(String label, dynamic val, NumberFormat fmt, {bool isBold = false}) {
      return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                  Text(label, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
                  Text(fmt.format(val), style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal))
              ],
          ),
      );
  }
}
