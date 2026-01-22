import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/inventory_provider.dart';
import 'vendor_purchases_screen.dart'; // Added

class VendorsScreen extends StatefulWidget {
  const VendorsScreen({super.key});

  @override
  State<VendorsScreen> createState() => _VendorsScreenState();
}

class _VendorsScreenState extends State<VendorsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
       Provider.of<InventoryProvider>(context, listen: false).fetchVendors();
       Provider.of<InventoryProvider>(context, listen: false).fetchPurchaseHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<InventoryProvider>(context);

    // Calculate Vendor Stats
    Map<String, dynamic> _getVendorStats(int vendorId, String vendorName) {
       final items = provider.items.where((i) => i.lastVendor == vendorName || (i.lastVendor?.contains(vendorName) ?? false)).toList();
       
       // IMPROVED: More robust vendor matching (case-insensitive, partial match)
       final history = provider.purchaseHistory.where((p) {
         // Match by ID (exact)
         if (p.vendorId == vendorId) return true;
         
         // Match by name (case-insensitive, contains)
         final pVendorName = (p.vendorName ?? '').toLowerCase().trim();
         final searchName = vendorName.toLowerCase().trim();
         
         return pVendorName == searchName || 
                pVendorName.contains(searchName) || 
                searchName.contains(pVendorName);
       }).toList();
       
       // DEBUG: Print purchase history for this vendor
       print('DEBUG: Vendor $vendorName (ID: $vendorId)');
       print('DEBUG: Total purchase history count: ${provider.purchaseHistory.length}');
       print('DEBUG: Filtered history count: ${history.length}');
       for (var po in history) {
         print('DEBUG: PO ${po.purchaseNumber} - VendorID:${po.vendorId}, VendorName:"${po.vendorName}", Amount: ${po.totalAmount}, Status: ${po.paymentStatus}');
       }
       
       double totalPurchase = 0;
       double paidAmount = 0;
       double creditAmount = 0;

       for (var po in history) {
          totalPurchase += po.totalAmount;
          if (po.paymentStatus.toLowerCase() == 'paid') {
             paidAmount += po.totalAmount;
          } else {
             // pending or partial (simplified credit)
             creditAmount += po.totalAmount;
          }
       }
       
       print('DEBUG: Total: $totalPurchase, Paid: $paidAmount, Credit: $creditAmount');
       
       return {
         'items': items.length,
         'purchase': totalPurchase,
         'paid': paidAmount,
         'credit': creditAmount
       };
    }
    
    // ... rest of build method ...

    Widget _kpi(String label, String value, Color color) {
       return Column(
         children: [
           Text(value, style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 16)),
           Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 11)),
         ],
       );
    }

    // Global stats
    double totalPurchased = provider.purchaseHistory.fold(0, (sum, item) => sum + item.totalAmount);
    double totalOutstanding = provider.purchaseHistory
        .where((p) => p.paymentStatus != 'paid' && p.paymentStatus != 'PAID')
        .fold(0, (sum, item) => sum + item.totalAmount);

    return Scaffold(
      appBar: AppBar(title: const Text('Vendors'), elevation: 0),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Global Dashboard
                Container(
                   padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                   color: Theme.of(context).primaryColor.withOpacity(0.05),
                   child: Row(
                     children: [
                       Expanded(child: _globalKpi("Active Vendors", "${provider.vendors.length}", Colors.teal)),
                       const SizedBox(width: 12),
                       Expanded(child: _globalKpi("Total Purchased", "₹${totalPurchased.toStringAsFixed(0)}", Colors.blue)),
                       const SizedBox(width: 12),
                       Expanded(child: _globalKpi("Outstanding", "₹${totalOutstanding.toStringAsFixed(0)}", Colors.orange)),
                     ],
                   ),
                ),
                Expanded(
                  child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: provider.vendors.length,
              itemBuilder: (context, index) {
                final vendor = provider.vendors[index];
                final stats = _getVendorStats(vendor['id'] ?? 0, vendor['name'] ?? '');

                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ExpansionTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.teal.shade100,
                      child: Text(vendor['name'][0].toUpperCase(), style: TextStyle(color: Colors.teal.shade900)),
                    ),
                    title: Text(vendor['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Row(
                      children: [
                        Text(vendor['contact_person'] ?? 'No Contact'),
                      ],
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                             const SizedBox(height: 10),
                             // KPI Row
                             Container(
                               padding: const EdgeInsets.all(12),
                               decoration: BoxDecoration(
                                 color: Colors.grey.shade50,
                                 borderRadius: BorderRadius.circular(8),
                                 border: Border.all(color: Colors.grey.shade200)
                               ),
                               child: Row(
                                 mainAxisAlignment: MainAxisAlignment.spaceAround,
                                 children: [
                                   _kpi("Total Purchase", "₹${stats['purchase'].toStringAsFixed(0)}", Colors.purple),
                                   _kpi("Paid", "₹${stats['paid'].toStringAsFixed(0)}", Colors.green),
                                   _kpi("Credit", "₹${stats['credit'].toStringAsFixed(0)}", Colors.red),
                                 ],
                               ),
                             ),
                             const SizedBox(height: 16),
                             const Divider(),
                             _infoRow(Icons.email, vendor['email']),
                             _infoRow(Icons.phone, vendor['phone']),
                             _infoRow(Icons.confirmation_number, "GST: ${vendor['gst_number'] ?? 'N/A'}"),
                             _infoRow(Icons.location_on, vendor['address']),
                             const SizedBox(height: 12),
                              Row(
                               mainAxisAlignment: MainAxisAlignment.end,
                               children: [
                                 TextButton.icon(
                                   onPressed: () {
                                     Navigator.push(context, MaterialPageRoute(builder: (_) => VendorPurchasesScreen(
                                       vendorId: vendor['id'],
                                       vendorName: vendor['name'] ?? 'Vendor',
                                     )));
                                   },
                                   icon: const Icon(Icons.history, size: 16),
                                   label: const Text("History"),
                                 ),
                                 const SizedBox(width: 8),
                                 TextButton.icon(
                                   onPressed: () {
                                      // Edit Vendor
                                   },
                                   icon: const Icon(Icons.edit, size: 16),
                                   label: const Text("Edit"),
                                 ),
                                 const SizedBox(width: 8),
                                 ElevatedButton.icon(
                                   onPressed: () {
                                      // Call vendor
                                   },
                                   icon: const Icon(Icons.call, size: 16),
                                   label: const Text("Call"),
                                   style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, foregroundColor: Colors.white),
                                 )
                               ],
                             )
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

  Widget _globalKpi(String title, String value, Color color) {
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

  Widget _infoRow(IconData icon, String? value) {
    if (value == null || value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey),
          const SizedBox(width: 8),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }
}
