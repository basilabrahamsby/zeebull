import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/inventory_provider.dart';
import 'inventory_items_view.dart';
import 'inventory_transactions_screen.dart';
import 'purchase_orders_screen.dart';
import 'vendors_screen.dart';
import 'categories_screen.dart';
import 'waste_log_screen.dart';
import 'requisitions_screen.dart';
import 'locations_screen.dart';
import 'assets_screen.dart';
import 'recipes_screen.dart';
import 'stock_issues_screen.dart';
import 'location_stock_screen.dart';

class InventoryScreen extends StatelessWidget {
  const InventoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Trigger fetches
    Future.microtask(() {
      final p = Provider.of<InventoryProvider>(context, listen: false);
      p.fetchInventory(); 
      p.fetchPendingPOs(); 
      p.fetchVendors(); // Added
      p.fetchCategories(); // Added
      p.fetchRequisitions(); // Added
    });
    
    return Scaffold(
      appBar: AppBar(title: const Text('Inventory & Stock'), elevation: 0),
      backgroundColor: Colors.grey.shade100,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
               // Header Stats / Alerts
               Consumer<InventoryProvider>(builder: (context, provider, _) { 
                  int lowStock = provider.lowStockItems.length;
                  int pendingPO = provider.pendingPOs.length;
                  double inventoryValue = provider.items.fold(0, (sum, item) => sum + (item.quantity * item.price));
                  
                  return Column(
                    children: [
                      Row(
                        children: [
                           Expanded(
                               child: _buildStatCard(context, "Inventory Value", "₹${inventoryValue.toStringAsFixed(0)}", Colors.purple, Icons.monetization_on, () {}),
                           ),
                           const SizedBox(width: 16),
                           Expanded(
                             child: _buildStatCard(context, "Pending POs", "$pendingPO Orders", Colors.orange, Icons.pending_actions, () {
                                  Navigator.push(context, MaterialPageRoute(builder: (_) => const PurchaseOrderScreen()));
                             }),
                           ),
                        ],
                      ),
                      if (lowStock > 0) ...[
                        const SizedBox(height: 16),
                        _buildStatCard(context, "Low Stock Warning", "$lowStock Items below minimum level", Colors.red, Icons.warning, () {
                              Navigator.push(context, MaterialPageRoute(builder: (_) => const InventoryItemsView()));
                        }, isFullWidth: true),
                      ]
                    ],
                  );
               }),
               
               const SizedBox(height: 24),
               const Text("Modules", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
               const SizedBox(height: 16),
               
               Consumer<InventoryProvider>(builder: (ctx, prov, _) {
                 return GridView.count(
                   shrinkWrap: true,
                   physics: const NeverScrollableScrollPhysics(),
                   crossAxisCount: 3,
                   crossAxisSpacing: 12,
                   mainAxisSpacing: 12,
                   childAspectRatio: 0.85, // Taller for badge
                   children: [
                      _buildModuleCard(context, "Items", Icons.inventory_2, Colors.blue, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const InventoryItemsView())), badge: "${prov.items.length}"),
                      _buildModuleCard(context, "Categories", Icons.category, Colors.purple, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CategoriesScreen())), badge: "${prov.categories.length}"),
                      _buildModuleCard(context, "Vendors", Icons.store, Colors.teal, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const VendorsScreen())), badge: "${prov.vendors.length}"),
                      
                      _buildModuleCard(context, "Purchases", Icons.receipt_long, Colors.green, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PurchaseOrderScreen())), badge: prov.pendingPOs.isNotEmpty ? "${prov.pendingPOs.length} Pending" : null),
                      _buildModuleCard(context, "Transactions", Icons.history, Colors.blueGrey, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const InventoryTransactionsScreen()))),
                      _buildModuleCard(context, "Requisitions", Icons.assignment, Colors.amber, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RequisitionsScreen())), badge: prov.requisitions.where((r) => r['status'] == 'pending').length > 0 ? "${prov.requisitions.where((r) => r['status'] == 'pending').length} New" : null),
                      
                      _buildModuleCard(context, "Issues", Icons.output, Colors.deepOrange, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const StockIssuesScreen()))),
                      _buildModuleCard(context, "Waste Log", Icons.delete_outline, Colors.brown, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const WasteLogScreen()))),
                      _buildModuleCard(context, "Location Stock", Icons.warehouse, Colors.indigo, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LocationStockScreen()))),

                      _buildModuleCard(context, "Locations", Icons.place, Colors.pink, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LocationsScreen()))),
                      _buildModuleCard(context, "Assets", Icons.chair, Colors.cyan, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AssetsScreen()))),
                      _buildModuleCard(context, "Recipes", Icons.restaurant_menu, Colors.deepPurple, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RecipesScreen()))),
                   ],
                 );
               })
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value, Color color, IconData icon, VoidCallback onTap, {bool isFullWidth = false}) {
      return GestureDetector(
        onTap: onTap,
        child: Container(
           width: isFullWidth ? double.infinity : null,
           padding: const EdgeInsets.all(16),
           decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)]),
           child: Row(
             children: [
                CircleAvatar(backgroundColor: color.withOpacity(0.1), child: Icon(icon, color: color)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                       Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
                       Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                )
             ],
           ),
        ),
      );
  }

  Widget _buildModuleCard(BuildContext context, String title, IconData icon, Color color, VoidCallback onTap, {String? badge}) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white, 
              borderRadius: BorderRadius.circular(12),
               boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)]
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                 CircleAvatar(radius: 20, backgroundColor: color.withOpacity(0.1), child: Icon(icon, color: color, size: 20)),
                 const SizedBox(height: 12),
                 Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          if (badge != null)
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(8)),
                child: Text(badge, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            )
        ],
      ),
    );
  }
}
