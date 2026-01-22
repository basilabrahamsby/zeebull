import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/food_provider.dart';
import '../models/food_order.dart';

class FoodHistoryScreen extends StatelessWidget {
  const FoodHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<FoodProvider>(context);
    final currency = NumberFormat.simpleCurrency(name: 'INR');
    
    // Sort by Date Descending
    final orders = List<FoodOrder>.from(provider.historyOrders)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    if (orders.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text("No order history found"),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        final DateTime? date = DateTime.tryParse(order.createdAt);
        final dateStr = date != null ? DateFormat('MMM dd, hh:mm a').format(date) : order.createdAt;

        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 12),
          child: ExpansionTile(
            leading: CircleAvatar(
              backgroundColor: Colors.grey.shade200,
              child: const Icon(Icons.receipt_long, color: Colors.grey),
            ),
            title: Text("Room ${order.roomNumber}", style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text("$dateStr • ${order.orderType.replaceAll('_', ' ').toUpperCase()}"),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(currency.format(order.totalAmount), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                Text(order.status, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
            children: [
              const Divider(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  children: order.items.map((item) => Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                       Text("${item.quantity}x ${item.name}"),
                       Text(currency.format(item.price * item.quantity)),
                    ],
                  )).toList(),
                ),
              ),
              if (order.assignedEmployeeId != null) 
                 Padding(
                   padding: const EdgeInsets.all(8.0),
                   child: Row(
                     children: [
                       const Icon(Icons.person, size: 16, color: Colors.blue),
                       const SizedBox(width: 4),
                       Text("Served by Staff #${order.assignedEmployeeId}", style: const TextStyle(color: Colors.blue, fontStyle: FontStyle.italic)),
                     ],
                   ),
                 )
            ],
          ),
        );
      },
    );
  }
}
