import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:orchid_employee/data/models/inventory_item_model.dart';
import 'package:orchid_employee/core/constants/app_colors.dart';
import 'package:orchid_employee/presentation/providers/inventory_provider.dart';
import 'package:orchid_employee/presentation/providers/service_request_provider.dart';

class AuditScreen extends StatefulWidget {
  final String roomNumber;
  final int roomId;

  const AuditScreen({super.key, required this.roomNumber, required this.roomId});

  @override
  State<AuditScreen> createState() => _AuditScreenState();
}

class _AuditScreenState extends State<AuditScreen> {
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<InventoryProvider>().fetchSellableItems();
    });
  }

  void _increment(InventoryItem item) {
    setState(() {
      item.consumedQty++;
    });
  }

  void _decrement(InventoryItem item) {
    setState(() {
      if (item.consumedQty > 0) {
        item.consumedQty--;
      }
    });
  }

  Future<void> _submitAudit() async {
    final inventoryProvider = context.read<InventoryProvider>();
    final consumedItems = inventoryProvider.sellableItems.where((i) => i.consumedQty > 0).toList();
    
    if (consumedItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No items marked as consumed.")),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final List<Map<String, dynamic>> refillData = consumedItems.map((i) => {
      'item_id': i.id,
      'quantity': i.consumedQty,
      'item_name': i.name,
    }).toList();

    final success = await context.read<ServiceRequestProvider>().createRefillRequest(
      widget.roomId, 
      refillData
    );

    if (mounted) {
      setState(() => _isSubmitting = false);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Audit submitted for Room ${widget.roomNumber}!")),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to submit audit. Please try again.")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final inventoryProvider = context.watch<InventoryProvider>();
    final items = inventoryProvider.sellableItems;

    return Scaffold(
      appBar: AppBar(
        title: Text("Audit: Room ${widget.roomNumber}", style: const TextStyle(color: Colors.white)),
        backgroundColor: AppColors.primary,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: inventoryProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : inventoryProvider.error != null
              ? Center(child: Text(inventoryProvider.error!))
              : Column(
                  children: [
                    Expanded(
                      child: ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: items.length,
                        separatorBuilder: (_, __) => const Divider(),
                        itemBuilder: (context, index) {
                          final item = items[index];
                          return Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(item.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                    Text("₹${item.price}", style: const TextStyle(color: Colors.grey)),
                                  ],
                                ),
                              ),
                              _QuantityControl(
                                qty: item.consumedQty,
                                onAdd: () => _increment(item),
                                onRemove: () => _decrement(item),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isSubmitting ? null : _submitAudit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.secondary,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: _isSubmitting
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text("Submit Consumption", style: TextStyle(fontSize: 18, color: Colors.white)),
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }
}

class _QuantityControl extends StatelessWidget {
  final int qty;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  const _QuantityControl({required this.qty, required this.onAdd, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: onRemove,
          icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
        ),
        SizedBox(
          width: 30,
          child: Text(
            "$qty",
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        IconButton(
          onPressed: onAdd,
          icon: const Icon(Icons.add_circle_outline, color: Colors.green),
        ),
      ],
    );
  }
}
