import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/inventory_provider.dart';
import 'inventory_items_view.dart'; // Added

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        Provider.of<InventoryProvider>(context, listen: false).fetchCategories());
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<InventoryProvider>(context);

    Map<String, dynamic> _getCategoryStats(String categoryName) {
      final items = provider.items.where((i) => i.category == categoryName).toList();
      double totalStock = 0;
      double totalValue = 0;
      for (var i in items) {
        totalStock += i.quantity;
        totalValue += (i.quantity * i.price);
      }
      return {
        'items': items.length,
        'stock': totalStock,
        'value': totalValue
      };
    }

    Widget _kpiItem(String label, String value, Color color) {
      return Column(
        children: [
          Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
          Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
        ],
      );
    }

    // Global Stats
    double globalValue = provider.items.fold(0, (sum, i) => sum + (i.quantity * i.price));
    int globalItems = provider.items.length;

    return Scaffold(
      appBar: AppBar(title: const Text('Categories')),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Container(
                   padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                   color: Theme.of(context).primaryColor.withOpacity(0.05),
                   child: Row(
                     children: [
                       Expanded(child: _globalKpi("Total Value", "₹${globalValue.toStringAsFixed(0)}", Colors.purple)),
                       const SizedBox(width: 12),
                       Expanded(child: _globalKpi("Total Items", "$globalItems", Colors.blue)),
                     ],
                   ),
                ),
                Expanded(
                  child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: provider.categories.length,
              itemBuilder: (context, index) {
                final cat = provider.categories[index];
                final stats = _getCategoryStats(cat['name']);

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                  child: InkWell(
                    onTap: () {
                       Navigator.push(
                         context, 
                         MaterialPageRoute(
                           builder: (_) => InventoryItemsView(
                             initialCategory: cat['name'],
                             categoryData: cat,
                           )
                         )
                       );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: Colors.purple.shade50,
                                child: Icon(Icons.category, color: Colors.purple),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(cat['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                    Text(cat['parent_department'] ?? 'General', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                                  ],
                                ),
                              ),
                              const Icon(Icons.chevron_right, color: Colors.grey),
                            ],
                          ),
                          const Divider(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _kpiItem("Items", stats['items'].toString(), Colors.blue),
                              _kpiItem("Stock", stats['stock'].toStringAsFixed(0), Colors.orange),
                              _kpiItem("Value", "₹${stats['value'].toStringAsFixed(0)}", Colors.green),
                            ],
                          )
                        ],
                      ),
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
}
