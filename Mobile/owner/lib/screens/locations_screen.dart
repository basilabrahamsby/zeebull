import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/inventory_provider.dart';

class LocationsScreen extends StatefulWidget {
  const LocationsScreen({super.key});

  @override
  State<LocationsScreen> createState() => _LocationsScreenState();
}

class _LocationsScreenState extends State<LocationsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        Provider.of<InventoryProvider>(context, listen: false).fetchLocations());
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<InventoryProvider>(context);

    // Group by location_type or just list
    // Let's list by Type if possible or just plain list
    // Data has: name, building, floor, location_type
    
    return Scaffold(
      appBar: AppBar(title: const Text('Locations')),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: provider.locations.length,
              itemBuilder: (context, index) {
                final loc = provider.locations[index];
                IconData icon;
                Color color;
                
                String type = loc['location_type'] ?? 'Unknown';
                if (type == 'WAREHOUSE' || type == 'CENTRAL_WAREHOUSE') {
                    icon = Icons.warehouse; color = Colors.indigo;
                } else if (type == 'GUEST_ROOM') {
                    icon = Icons.bed; color = Colors.orange;
                } else if (type == 'KITCHEN') {
                    icon = Icons.kitchen; color = Colors.red;
                } else {
                    icon = Icons.place; color = Colors.blue;
                }

                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: color.withOpacity(0.1),
                      child: Icon(icon, color: color),
                    ),
                    title: Text(loc['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text("${loc['building'] ?? ''} • $type"),
                    // trailing: const Icon(Icons.chevron_right),
                    // onTap: () {
                    //    // Show stock at location? (Next feature)
                    // },
                  ),
                );
              },
            ),
    );
  }
}
