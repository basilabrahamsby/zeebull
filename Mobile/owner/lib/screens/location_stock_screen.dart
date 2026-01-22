import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/inventory_provider.dart';

class LocationStockScreen extends StatefulWidget {
  const LocationStockScreen({super.key});

  @override
  State<LocationStockScreen> createState() => _LocationStockScreenState();
}

class _LocationStockScreenState extends State<LocationStockScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        Provider.of<InventoryProvider>(context, listen: false).fetchLocations());
  }

  void _showStockForLocation(BuildContext context, dynamic location) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6, // Start slightly taller
        minChildSize: 0.4,
        maxChildSize: 0.95,
        builder: (_, scrollController) => _LocationStockDetailSheet(
          location: location,
          scrollController: scrollController,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<InventoryProvider>(context);
    final locations = provider.locations;
    
    // KPIs
    int totalLocs = locations.length;
    int warehouses = locations.where((l) => (l['location_type'] ?? '').toString().contains('WAREHOUSE') || (l['location_type'] ?? '').toString().contains('STORE')).length;
    int rooms = locations.where((l) => (l['location_type'] ?? '').toString() == 'GUEST_ROOM').length;
    
    double totalValue = 0;
    int totalItems = 0;
    for (var l in locations) {
        totalValue += (double.tryParse((l['total_value'] ?? 0).toString()) ?? 0);
        totalItems += (int.tryParse((l['total_items'] ?? 0).toString()) ?? 0);
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Stock by Location'), elevation: 0),
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
                       Expanded(child: _kpi("Total Locations", "$totalLocs", Colors.indigo)),
                       const SizedBox(width: 8),
                       Expanded(child: _kpi("Value", "₹${(totalValue/1000).toStringAsFixed(1)}k", Colors.green)),
                       const SizedBox(width: 8),
                       Expanded(child: _kpi("Items", "$totalItems", Colors.orange)),
                     ],
                   ),
                ),

                Expanded(
                  child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: locations.length,
              itemBuilder: (context, index) {
                final loc = locations[index];
                IconData icon;
                Color color;
                
                String type = loc['location_type'] ?? 'Unknown';
                if (type == 'WAREHOUSE' || type == 'CENTRAL_WAREHOUSE') {
                    icon = Icons.warehouse; color = Colors.indigo;
                } else if (type == 'KITCHEN') {
                    icon = Icons.kitchen; color = Colors.red;
                } else if (type == 'GUEST_ROOM') {
                    icon = Icons.bed; color = Colors.orange;
                } else {
                    icon = Icons.store; color = Colors.blue;
                }

                return Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: InkWell(
                    onTap: () => _showStockForLocation(context, loc),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            backgroundColor: color.withOpacity(0.1),
                            child: Icon(icon, color: color),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            loc['name'], 
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          // Stats Row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                                Text("${loc['total_items'] ?? 0} items", style: TextStyle(fontSize: 10, color: Colors.grey.shade700)),
                                const SizedBox(width: 8),
                                Text("₹${(double.tryParse((loc['total_value'] ?? 0).toString()) ?? 0).toStringAsFixed(0)}", style: TextStyle(fontSize: 10, color: Colors.green.shade700, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            type.replaceAll('_', ' '), 
                            style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                            textAlign: TextAlign.center,
                          ),
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

class _LocationStockDetailSheet extends StatefulWidget {
  final dynamic location;
  final ScrollController scrollController;

  const _LocationStockDetailSheet({
    required this.location,
    required this.scrollController,
  });

  @override
  State<_LocationStockDetailSheet> createState() => _LocationStockDetailSheetState();
}

class _LocationStockDetailSheetState extends State<_LocationStockDetailSheet> {
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  void _fetch() async {
    final provider = Provider.of<InventoryProvider>(context, listen: false);
    await provider.fetchLocationStock(widget.location['id']);
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<InventoryProvider>(context);
    final stockItems = provider.getLocationStock(widget.location['id']);
    
    // Sheet KPIs
    double totalValue = 0;
    int lowStock = 0;
    for (var item in stockItems) {
       totalValue += (double.tryParse(item['quantity'].toString()) ?? 0) * (double.tryParse(item['unit_price'].toString()) ?? 0);
       if (item['is_low_stock'] == true) lowStock++;
    }

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.warehouse, color: Colors.indigo),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "Stock in ${widget.location['name']}",
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                )
              ],
            ),
          ),
          
          // Sheet Dashboard
           Container(
             margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
             decoration: BoxDecoration(
               color: Colors.indigo.shade50,
               borderRadius: BorderRadius.circular(12)
             ),
             child: Row(
               mainAxisAlignment: MainAxisAlignment.spaceBetween,
               children: [
                  _sheetKpi("Items", "${stockItems.length}"),
                  _sheetKpi("Total Value", "₹${totalValue.toStringAsFixed(0)}"),
                  _sheetKpi("Low Stock", "$lowStock"),
               ],
             ),
           ),

          const Divider(height: 1),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : stockItems.isEmpty
                    ? const Center(child: Text("No items in stock at this location"))
                    : ListView.builder(
                        controller: widget.scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount: stockItems.length,
                        itemBuilder: (context, index) {
                          final item = stockItems[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              title: Text(item['item_name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text(item['category_name'] ?? 'Uncategorized'),
                              trailing: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.indigo.shade50,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: Colors.indigo.shade100),
                                ),
                                child: Text(
                                  "${item['quantity']} ${item['unit']}",
                                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo),
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
  
  Widget _sheetKpi(String label, String value) {
     return Column(
       children: [
         Text(label, style: TextStyle(fontSize: 10, color: Colors.indigo.shade300)),
         Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.indigo)),
       ],
     );
  }
}
