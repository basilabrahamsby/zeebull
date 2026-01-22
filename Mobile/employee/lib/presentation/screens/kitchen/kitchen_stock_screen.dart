import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:orchid_employee/presentation/providers/inventory_provider.dart';
import 'package:orchid_employee/data/models/inventory_item_model.dart';
import 'package:orchid_employee/presentation/providers/kitchen_provider.dart';

class KitchenStockScreen extends StatefulWidget {
  const KitchenStockScreen({super.key});

  @override
  State<KitchenStockScreen> createState() => _KitchenStockScreenState();
}

class _KitchenStockScreenState extends State<KitchenStockScreen> {
  int? _kitchenLocationId;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    final inventory = context.read<InventoryProvider>();
    await inventory.fetchLocations();
    await inventory.fetchSellableItems(); // Fetch all items to get names

    // Try to find "Kitchen" or "Main Kitchen" location
    final kitchenLoc = inventory.locations.firstWhere(
      (l) => l['name'].toString().toLowerCase().contains('kitchen'),
      orElse: () => null,
    );

    if (kitchenLoc != null) {
      setState(() => _kitchenLocationId = kitchenLoc['id']);
      await inventory.fetchLocationStock(kitchenLoc['id']);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text("Kitchen Stock"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Consumer<InventoryProvider>(
        builder: (context, inventory, child) {
          if (_kitchenLocationId == null) {
            return const Center(child: Text("Kitchen location not found"));
          }

          final stock = inventory.locationStocks;
          final totalItems = stock.length;
          final lowStockCount = stock.values.where((v) => v < 5).length; // Example low stock threshold

          return Column(
            children: [
              _buildKpiSection(totalItems, lowStockCount),
              Expanded(
                child: stock.isEmpty
                    ? const Center(child: Text("No items currently in kitchen stock"))
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: stock.length,
                        itemBuilder: (context, index) {
                          final itemId = stock.keys.elementAt(index);
                          final quantity = stock[itemId]!;
                          
                          // Correctly handling firstWhere orElse to avoid type mismatch
                          final item = inventory.allItems.cast<InventoryItem?>().firstWhere(
                            (i) => i?.id == itemId, 
                            orElse: () => null
                          );

                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            child: ListTile(
                              title: Text(item?.name ?? "Item #$itemId", style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text(item?.category ?? "General"),
                              trailing: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: quantity < 5 ? Colors.red.shade50 : Colors.green.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  "$quantity ${item?.unit ?? 'pcs'}",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold, 
                                    color: quantity < 5 ? Colors.red : Colors.green
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildKpiSection(int total, int lowStock) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Row(
        children: [
          _buildKpiCard("Total Items", total.toString(), Colors.blue),
          const SizedBox(width: 8),
          _buildKpiCard("Low Stock", lowStock.toString(), Colors.red),
          const SizedBox(width: 8),
          _buildKpiCard("Location ID", "#$_kitchenLocationId", Colors.teal),
        ],
      ),
    );
  }

  Widget _buildKpiCard(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 2),
            Text(label, style: TextStyle(fontSize: 10, color: color.withOpacity(0.8), fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
