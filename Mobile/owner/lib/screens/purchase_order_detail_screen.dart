import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PurchaseOrderDetailScreen extends StatelessWidget {
  final Map<String, dynamic> purchase;

  const PurchaseOrderDetailScreen({super.key, required this.purchase});

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'received': return Colors.green;
      case 'cancelled': return Colors.red;
      case 'draft': return Colors.grey;
      case 'confirmed': return Colors.blue;
      default: return Colors.orange;
    }
  }

  double _parse(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0.0;
  }

  @override
  Widget build(BuildContext context) {
    final date = DateTime.tryParse(purchase['purchase_date'] ?? '') ?? DateTime.now();
    final List<dynamic> details = purchase['details'] ?? [];
    
    // Calculate total from items
    double calculatedTotal = 0;
    for (var item in details) {
       final double unitPrice = (item['unit_price'] is num) ? (item['unit_price'] as num).toDouble() : double.tryParse(item['unit_price'].toString()) ?? 0.0;
       final double qty = (item['quantity'] is num) ? (item['quantity'] as num).toDouble() : double.tryParse(item['quantity'].toString()) ?? 0.0;
       calculatedTotal += (unitPrice * qty);
    }
    
    double amount = _parse(purchase['total_amount']);
    if (amount == 0 && calculatedTotal > 0) {
       amount = calculatedTotal;
    }

    String subTotalStr = (purchase['sub_total'] ?? 0).toString();
    if (_parse(purchase['sub_total']) == 0 && calculatedTotal > 0) {
       subTotalStr = calculatedTotal.toStringAsFixed(2);
    }

    return Scaffold(
      appBar: AppBar(title: Text(purchase['purchase_number'] ?? 'Purchase Order')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                       Text("Total Amount", style: TextStyle(color: Colors.grey.shade600)),
                       Container(
                         padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                         decoration: BoxDecoration(
                           color: _getStatusColor(purchase['status'] ?? '').withOpacity(0.1),
                           borderRadius: BorderRadius.circular(4)
                         ),
                         child: Text(
                           purchase['status']?.toUpperCase() ?? 'UNKNOWN',
                           style: TextStyle(color: _getStatusColor(purchase['status'] ?? ''), fontWeight: FontWeight.bold, fontSize: 12),
                         ),
                       )
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text("₹${amount.toStringAsFixed(2)}", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const Divider(height: 32),
                  const Divider(height: 32),
                  _row("Vendor", purchase['vendor_name'] ?? 'Unknown Vendor'),
                  if (purchase['vendor_gst'] != null) _row("Vendor GST", purchase['vendor_gst']),
                  _row("Date", DateFormat('MMM d, yyyy').format(date)),
                  if (purchase['invoice_number'] != null) ...[
                     _row("Invoice No", purchase['invoice_number']),
                     if (purchase['invoice_date'] != null) 
                       _row("Invoice Date", purchase['invoice_date']),
                  ],
                  if (purchase['destination_location_name'] != null)
                     _row("Destination", purchase['destination_location_name']),
                  
                  const Divider(height: 24),
                  
                  // Tax Breakdown
                  _row("Subtotal", "₹$subTotalStr"),
                  if (_parse(purchase['discount']) > 0)
                     _row("Discount", "-₹${purchase['discount']}", color: Colors.green),
                  if (_parse(purchase['cgst']) > 0) _row("CGST", "₹${purchase['cgst']}"),
                  if (_parse(purchase['sgst']) > 0) _row("SGST", "₹${purchase['sgst']}"),
                  if (_parse(purchase['igst']) > 0) _row("IGST", "₹${purchase['igst']}"),
                  
                  const SizedBox(height: 12),
                  _row("Grand Total", "₹${amount.toStringAsFixed(2)}", isBold: true, fontSize: 18),
                  
                  const Divider(height: 24),
                  _row("Payment Status", purchase['payment_status']?.toUpperCase() ?? 'PENDING'),
                  if (purchase['payment_method'] != null)
                     _row("Payment Method", purchase['payment_method'].toString().toUpperCase()),

                  if (purchase['created_by_name'] != null)
                     Padding(
                       padding: const EdgeInsets.only(top: 8.0),
                       child: Text("Created by: ${purchase['created_by_name']}", style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                     ),

                  if (purchase['notes'] != null && purchase['notes'].toString().isNotEmpty)
                     Padding(
                       padding: const EdgeInsets.only(top: 8.0),
                       child: Text("Notes: ${purchase['notes']}", style: TextStyle(color: Colors.grey.shade600, fontStyle: FontStyle.italic)),
                     ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Align(alignment: Alignment.centerLeft, child: Text("Items", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey))),
            ),
            if (details.isEmpty)
               const Padding(padding: EdgeInsets.all(32), child: Text("No items found.")),
            
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: details.length,
              itemBuilder: (context, index) {
                final item = details[index];
                final double unitPrice = (item['unit_price'] is num) ? (item['unit_price'] as num).toDouble() : double.tryParse(item['unit_price'].toString()) ?? 0.0;
                final double qty = (item['quantity'] is num) ? (item['quantity'] as num).toDouble() : double.tryParse(item['quantity'].toString()) ?? 0.0;
                final double total = unitPrice * qty;
                
                return Container(
                  color: Colors.white,
                  margin: const EdgeInsets.only(bottom: 1),
                  child: ListTile(
                    title: Text(item['item_name'] ?? 'Unknown Item', style: const TextStyle(fontWeight: FontWeight.w500)),
                    subtitle: Text("${qty} ${item['unit']} x ₹${unitPrice}"),
                    trailing: Text("₹${total.toStringAsFixed(2)}", style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                );
              },
            )
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value, {bool isBold = false, double fontSize = 14, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey.shade600)),
          Text(value, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.w500, fontSize: fontSize, color: color)),
        ],
      ),
    );
  }
}
