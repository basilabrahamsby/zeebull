import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/inventory_provider.dart';
import 'package:intl/intl.dart';

class AssetsScreen extends StatefulWidget {
  const AssetsScreen({super.key});

  @override
  State<AssetsScreen> createState() => _AssetsScreenState();
}

class _AssetsScreenState extends State<AssetsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        Provider.of<InventoryProvider>(context, listen: false).fetchAssetRegistry());
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<InventoryProvider>(context);
    final assets = provider.assetRegistry;
    
    // KPIs
    int totalAssets = assets.length;
    int active = assets.where((a) => (a['status'] ?? 'active').toString().toLowerCase() == 'active').length;
    int maintenance = assets.where((a) => (a['status'] ?? '').toString().toLowerCase().contains('maintenance')).length;

    return Scaffold(
      appBar: AppBar(title: const Text('Fixed Assets (Registry)'), elevation: 0),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : assets.isEmpty
              ? _buildEmptyState()
              : Column(
                  children: [
                    // Dashboard
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      color: Theme.of(context).primaryColor.withOpacity(0.05),
                      child: Row(
                        children: [
                          Expanded(child: _kpi("Total Assets", "$totalAssets", Colors.cyan)),
                          const SizedBox(width: 12),
                          Expanded(child: _kpi("Active", "$active", Colors.green)),
                          const SizedBox(width: 12),
                          Expanded(child: _kpi("Maintenance", "$maintenance", Colors.orange)),
                        ],
                      ),
                    ),
                    
                    Expanded(
                      child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: assets.length,
              itemBuilder: (context, index) {
                final asset = assets[index];
                // Handling potentially missing fields gracefully
                final itemName = asset['item_name'] ?? 'Unknown Asset';
                final locationName = asset['location_name'] ?? 'Unassigned';
                final condition = asset['condition'] ?? 'Good';
                final serial = asset['serial_number'] ?? 'N/A';
                
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.cyan.shade100,
                      child: const Icon(Icons.qr_code, color: Colors.cyan),
                    ),
                    title: Text(itemName, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                         Text("S/N: $serial"),
                         Text("Location: $locationName"),
                      ],
                    ),
                    trailing: _buildStatusChip(asset['status'] ?? 'active', condition),
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
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(10), 
        border: Border.all(color: color.withOpacity(0.2))
      ),
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

  Widget _buildEmptyState() {
     return Center(
       child: Column(
         mainAxisAlignment: MainAxisAlignment.center,
         children: [
           Icon(Icons.chair_alt, size: 64, color: Colors.grey.shade300),
           const SizedBox(height: 16),
           const Text("No registered assets found", style: TextStyle(color: Colors.grey, fontSize: 16)),
           const SizedBox(height: 8),
           const Text("Assets must be registered in the System first.", style: TextStyle(color: Colors.grey, fontSize: 12)),
         ],
       ),
     );
  }

  Widget _buildStatusChip(String status, String condition) {
    Color color = Colors.green;
    if (status == 'maintenance') color = Colors.orange;
    if (status == 'disposed') color = Colors.red;
    
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(status.toUpperCase(), style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
        Text(condition, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
      ],
    );
  }
}
