import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/inventory_provider.dart';
import 'package:intl/intl.dart';
import 'purchase_order_detail_screen.dart'; // Added

class VendorPurchasesScreen extends StatefulWidget {
  final int vendorId;
  final String vendorName;

  const VendorPurchasesScreen({super.key, required this.vendorId, required this.vendorName});

  @override
  State<VendorPurchasesScreen> createState() => _VendorPurchasesScreenState();
}

class _VendorPurchasesScreenState extends State<VendorPurchasesScreen> {
  List<dynamic> _purchases = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    final provider = Provider.of<InventoryProvider>(context, listen: false);
    final purchases = await provider.fetchVendorPurchases(widget.vendorId);
    if (mounted) {
      setState(() {
        _purchases = purchases;
        _isLoading = false;
      });
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'received': return Colors.green;
      case 'cancelled': return Colors.red;
      case 'draft': return Colors.grey;
      case 'confirmed': return Colors.blue;
      default: return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Purchases - ${widget.vendorName}")),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : _purchases.isEmpty 
           ? _buildEmptyState()
           : ListView.builder(
               padding: const EdgeInsets.all(16),
               itemCount: _purchases.length,
               itemBuilder: (context, index) {
                  final p = _purchases[index];
                  final date = DateTime.tryParse(p['purchase_date'] ?? '') ?? DateTime.now();
                  final amount = (p['total_amount'] is num) ? p['total_amount'] : double.tryParse(p['total_amount'].toString()) ?? 0.0;
                  
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                       contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                       leading: CircleAvatar(
                          backgroundColor: _getStatusColor(p['status'] ?? '').withOpacity(0.1),
                          child: Icon(Icons.receipt, color: _getStatusColor(p['status'] ?? '')),
                       ),
                       title: Text(p['purchase_number'] ?? 'PO #', style: const TextStyle(fontWeight: FontWeight.bold)),
                       subtitle: Text(DateFormat('MMM d, yyyy').format(date)),
                       trailing: Column(
                         mainAxisAlignment: MainAxisAlignment.center,
                         crossAxisAlignment: CrossAxisAlignment.end,
                         children: [
                            Text("₹${amount.toStringAsFixed(2)}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            Text(p['status']?.toUpperCase() ?? 'UNKNOWN', style: TextStyle(fontSize: 10, color: _getStatusColor(p['status'] ?? ''))),
                         ],
                       ),
                       onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => PurchaseOrderDetailScreen(purchase: p)));
                       },
                    ),
                  );
               },
           ),
    );
  }

  Widget _buildEmptyState() {
     return Center(
       child: Column(
         mainAxisAlignment: MainAxisAlignment.center,
         children: [
           Icon(Icons.shopping_bag_outlined, size: 64, color: Colors.grey.shade300),
           const SizedBox(height: 16),
           Text("No purchases found for this vendor", style: TextStyle(color: Colors.grey.shade500)),
         ],
       ),
     );
  }
}
