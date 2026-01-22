import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:orchid_employee/presentation/providers/kitchen_provider.dart';
import 'wastage_log_screen.dart';
import 'package:intl/intl.dart';

class WastageListScreen extends StatefulWidget {
  const WastageListScreen({super.key});

  @override
  State<WastageListScreen> createState() => _WastageListScreenState();
}

class _WastageListScreenState extends State<WastageListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<KitchenProvider>().fetchWasteLogs();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text("Waste Reports"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Consumer<KitchenProvider>(
        builder: (context, kitchen, child) {
          if (kitchen.isLoading && kitchen.wasteLogs.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          final totalWaste = kitchen.wasteLogs.length;
          final foodWaste = kitchen.wasteLogs.where((w) {
            final dynamic raw = w['is_food_item'];
            return raw == true || raw == 'true' || raw == 1 || raw == '1';
          }).length;
          final inventoryWaste = totalWaste - foodWaste;

          return Column(
            children: [
              _buildKpiSection(totalWaste, foodWaste, inventoryWaste),
              Expanded(
                child: kitchen.wasteLogs.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.delete_sweep_outlined, size: 64, color: Colors.grey.shade300),
                            const SizedBox(height: 16),
                            const Text("No waste reports found", style: TextStyle(color: Colors.grey)),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () => kitchen.fetchWasteLogs(),
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: kitchen.wasteLogs.length,
                          itemBuilder: (context, index) {
                            final log = kitchen.wasteLogs[index];
                            return _buildWasteCard(log);
                          },
                        ),
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const WastageLogScreen()),
        ).then((_) => context.read<KitchenProvider>().fetchWasteLogs()),
        label: const Text("LOG WASTE"),
        icon: const Icon(Icons.add_circle_outline),
        backgroundColor: Colors.black,
      ),
    );
  }

  Widget _buildKpiSection(int total, int food, int inventory) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Row(
        children: [
          _buildKpiCard("Total Reports", total.toString(), Colors.orange),
          const SizedBox(width: 8),
          _buildKpiCard("Food Waste", food.toString(), Colors.deepOrange),
          const SizedBox(width: 8),
          _buildKpiCard("Inv Waste", inventory.toString(), Colors.blueGrey),
        ],
      ),
    );
  }

  Widget _buildKpiCard(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.1)),
        ),
        child: Column(
          children: [
            Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 2),
            Text(label, style: TextStyle(fontSize: 10, color: color.withOpacity(0.6), fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildWasteCard(dynamic log) {
    final dateStr = log['waste_date'] ?? log['created_at'];
    final date = DateTime.parse(dateStr);
    final itemName = log['item_name'] ?? log['food_item_name'] ?? "Unknown Item";
    final dynamic isFoodRaw = log['is_food_item'];
    final bool isFood = isFoodRaw == true || isFoodRaw == 'true' || isFoodRaw == 1 || isFoodRaw == '1';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    itemName,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: (isFood ? Colors.deepOrange : Colors.blueGrey).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    isFood ? "FOOD" : "INVENTORY",
                    style: TextStyle(color: isFood ? Colors.deepOrange : Colors.blueGrey, fontSize: 9, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 12, color: Colors.grey.shade400),
                const SizedBox(width: 4),
                Text(
                  DateFormat('MMM d, yyyy • hh:mm a').format(date),
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("QUANTITY", style: TextStyle(color: Colors.grey.shade500, fontSize: 10, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text("${log['quantity']} ${log['unit']}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text("REASON", style: TextStyle(color: Colors.grey.shade500, fontSize: 10, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(6)),
                      child: Text(
                        log['reason_code']?.toUpperCase() ?? "N/A",
                        style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            if (log['notes'] != null && log['notes'].toString().isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  log['notes'],
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontStyle: FontStyle.italic),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
