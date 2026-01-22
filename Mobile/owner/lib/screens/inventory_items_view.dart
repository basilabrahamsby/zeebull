import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/inventory_provider.dart';
import '../models/inventory_item.dart';
import 'inventory_item_detail_screen.dart'; // Added

class InventoryItemsView extends StatefulWidget {
  final String? initialCategory;
  final Map<String, dynamic>? categoryData; // Added to receive full object
  const InventoryItemsView({super.key, this.initialCategory, this.categoryData});

  @override
  State<InventoryItemsView> createState() => _InventoryItemsViewState();
}

class _InventoryItemsViewState extends State<InventoryItemsView> {
  String _searchQuery = "";
  late String _filter;
  final List<String> _filters = ["All", "Low Stock", "Grocery", "Housekeeping", "Beverages", "Appliances"];

  @override
  void initState() {
    super.initState();
    _filter = widget.initialCategory ?? "All";
    
    if (widget.initialCategory != null && !_filters.contains(widget.initialCategory)) {
        // Handle custom filter logic if needed
    }

    Future.microtask(() =>
        Provider.of<InventoryProvider>(context, listen: false).fetchInventory());
  }

  void _showItemDetails(InventoryItem item) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => InventoryItemDetailScreen(item: item)));
  }

  Widget _catDetail(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.blue.shade300, fontSize: 10, fontWeight: FontWeight.bold)),
        Text(value, style: TextStyle(color: Colors.blue.shade900, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _detailCol(String label, String value, {bool isBold = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(fontSize: 16, fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
      ],
    );
  }
  
  void _showTotalLowStock(List<InventoryItem> items) {
      showDialog(context: context, builder: (_) => AlertDialog(
          title: const Text("All Low Stock Items"),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: items.length,
              itemBuilder: (_, i) => ListTile(
                 title: Text(items[i].name),
                 subtitle: Text("${items[i].quantity} ${items[i].unit} (Min: ${items[i].minQuantity})"),
                 trailing: IconButton(icon: const Icon(Icons.info_outline), onPressed: () { Navigator.pop(context); _showItemDetails(items[i]); }),
              ),
            ),
          ),
          actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("Close"))],
      ));
  }
  
  void _showPendingPOs() {
      // Fetch POs
      Provider.of<InventoryProvider>(context, listen: false).fetchPendingPOs();

      showModalBottomSheet(
        context: context, 
        builder: (context) => Consumer<InventoryProvider>(
          builder: (context, provider, child) {
            return Container(
              padding: const EdgeInsets.all(16),
              height: 400,
              child: Column(
                 crossAxisAlignment: CrossAxisAlignment.start,
                 mainAxisSize: MainAxisSize.min,
                 children: [
                    const Text("Pending Purchase Orders", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    if (provider.pendingPOs.isEmpty)
                       const Padding(padding: EdgeInsets.all(20), child: Text("No pending POs found.")),
                    Expanded(
                      child: ListView.builder(
                        itemCount: provider.pendingPOs.length,
                        itemBuilder: (context, index) {
                           final po = provider.pendingPOs[index];
                           return ListTile(
                             leading: const Icon(Icons.receipt_long, color: Colors.blue),
                             title: Text("${po.purchaseNumber} (${po.vendorName})"),
                             subtitle: Text("₹${po.totalAmount.toStringAsFixed(2)} • ${po.itemCount} Items"),
                             trailing: ElevatedButton(
                               onPressed: () async {
                                  bool success = await provider.approvePO(po.id);
                                  if (success && context.mounted) {
                                     ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("PO Approved Successfully!")));
                                  }
                               },
                               style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                               child: const Text("Approve"),
                             ),
                           );
                        },
                      ),
                    ),
                 ],
              ),
            );
          },
        )
      );
  }

  Widget _kpiCard(String title, String value, Color color) {
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

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<InventoryProvider>(context);
    
    // ... filtering logic ...
    List<InventoryItem> filteredItems = provider.items.where((i) {
      bool matchesSearch = i.name.toLowerCase().contains(_searchQuery.toLowerCase());
      bool matchesFilter = _filter == "All" ? true : 
                           _filter == "Low Stock" ? i.isLowStock : 
                           i.category == _filter;
      if (_filter == "Grocery") return matchesSearch && (i.category == "Fresh Produce" || i.category == "Grocery");
      return matchesSearch && matchesFilter;
    }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Inventory Items')),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // KPI Dashboard
                Container(
                   padding: const EdgeInsets.all(12),
                   color: Theme.of(context).primaryColor.withOpacity(0.05),
                   child: Row(
                     children: [
                       Expanded(child: _kpiCard("Total Value", "₹${filteredItems.fold(0.0, (sum, i) => sum + (i.quantity * i.price)).toStringAsFixed(0)}", Colors.purple)),
                       const SizedBox(width: 12),
                       Expanded(child: _kpiCard("Total Qty", filteredItems.fold(0.0, (sum, i) => sum + i.quantity).toStringAsFixed(0), Colors.blue)),
                       const SizedBox(width: 12),
                       Expanded(child: _kpiCard("Items", "${filteredItems.length}", Colors.teal)),
                     ],
                   ),
                ),

                // NEW: Category Details Card (if data provided)
                if (widget.categoryData != null && _filter != "All" && _filter != "Low Stock")
                  Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.categoryData!['name'], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueAccent)),
                        const SizedBox(height: 8),
                        if (widget.categoryData!['description'] != null)
                           Text(widget.categoryData!['description'], style: TextStyle(color: Colors.grey.shade700)),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            _catDetail("HSN Code", widget.categoryData!['hsn_sac_code'] ?? 'N/A'),
                            const SizedBox(width: 16),
                            _catDetail("Department", widget.categoryData!['parent_department'] ?? 'General'),
                            const SizedBox(width: 16),
                            _catDetail("GST Rate", "${widget.categoryData!['gst_tax_rate'] ?? 0}%"),
                          ],
                        )
                      ],
                    ),
                  ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    children: [
                      TextField(
                        decoration: InputDecoration(
                          hintText: "Search inventory...",
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                        ),
                        onChanged: (val) => setState(() => _searchQuery = val),
                      ),
                      const SizedBox(height: 12),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: _filters.map((f) => Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: FilterChip(
                              label: Text(f),
                              selected: _filter == f,
                              selectedColor: Colors.blue.shade100,
                              onSelected: (sel) => setState(() => _filter = f),
                            ),
                          )).toList(),
                        ),
                      )
                    ],
                  ),
                ),
                if (provider.lowStockItems.isNotEmpty && (_filter == "All" || _filter == "Low Stock"))
                  GestureDetector(
                    onTap: () => _showTotalLowStock(provider.lowStockItems),
                    child: Container(
                      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        border: Border.all(color: Colors.red.shade200),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.warning_amber_rounded, color: Colors.deepOrange),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Low Stock Alerts (${provider.lowStockItems.length})',
                                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red.shade900, fontSize: 16),
                                  ),
                                ],
                              ),
                              const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.red),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ...provider.lowStockItems.take(2).map((item) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('• ${item.name}'),
                                Text('${item.quantity} ${item.unit}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
                              ],
                            ),
                          )),
                        ],
                      ),
                    ),
                  ),
                Expanded(
                  child: filteredItems.isEmpty 
                    ? const Center(child: Text("No items found"))
                    : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filteredItems.length,
                    itemBuilder: (context, index) {
                      final item = filteredItems[index];
                      return Card(
                        elevation: 1,
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          onTap: () => _showItemDetails(item),
                          leading: CircleAvatar(
                            backgroundColor: item.isLowStock ? Colors.red.shade100 : Colors.green.shade100,
                            child: Icon(Icons.inventory_2, color: item.isLowStock ? Colors.red : Colors.green, size: 20),
                          ),
                          title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                          subtitle: Text("${item.category} • ₹${item.price}/unit"),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '${item.quantity} ${item.unit}',
                                style: TextStyle(fontWeight: FontWeight.bold, color: item.isLowStock ? Colors.red : Colors.black87, fontSize: 14),
                              ),
                              if (item.isLowStock)
                                const Text('Reorder', style: TextStyle(color: Colors.red, fontSize: 10)),
                            ],
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
}
