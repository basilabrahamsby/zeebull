import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../providers/kitchen_provider.dart';
import '../../providers/inventory_provider.dart';
import '../../../data/models/inventory_item_model.dart';

class StockRequisitionScreen extends StatefulWidget {
  const StockRequisitionScreen({super.key});

  @override
  State<StockRequisitionScreen> createState() => _StockRequisitionScreenState();
}

class _StockRequisitionScreenState extends State<StockRequisitionScreen> {
  final List<Map<String, dynamic>> _selectedItems = [];
  final TextEditingController _notesController = TextEditingController();
  String _targetDepartment = 'Kitchen';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<InventoryProvider>().fetchSellableItems();
    });
  }

  void _addItem(InventoryItem item, double quantity) {
    setState(() {
      _selectedItems.add({
        'item_id': item.id,
        'item_name': item.name,
        'requested_quantity': quantity,
        'unit': item.unit,
      });
    });
  }

  void _submit() async {
    if (_selectedItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please add at least one item")));
      return;
    }

    final success = await context.read<KitchenProvider>().submitRequisition(
      _targetDepartment,
      _selectedItems,
      _notesController.text,
    );

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Requisition submitted successfully")));
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Failed to submit requisition")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text("Stock Requisition"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _submit,
            child: const Text("SUBMIT", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _notesController,
              decoration: InputDecoration(
                labelText: "Notes / Reason",
                hintText: "e.g. Extra tomatoes for weekend buffet",
                filled: true,
                fillColor: Colors.grey.shade50,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                prefixIcon: const Icon(Icons.note_alt_outlined),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Items to Request", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey)),
                  const SizedBox(height: 8),
                  Expanded(
                    child: _selectedItems.isEmpty 
                      ? _buildEmptyState()
                      : ListView.builder(
                          itemCount: _selectedItems.length,
                          itemBuilder: (context, index) {
                            final item = _selectedItems[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              child: ListTile(
                                title: Text(item['item_name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                                subtitle: Text("Unit: ${item['unit']}"),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(8)),
                                      child: Text(
                                        "${item['requested_quantity']}",
                                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                                      onPressed: () => setState(() => _selectedItems.removeAt(index)),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showItemPicker,
        icon: const Icon(Icons.add, color: Colors.white, size: 28),
        label: const Text(
          "ADD ITEM", 
          style: TextStyle(
            fontSize: 16, 
            fontWeight: FontWeight.bold, 
            color: Colors.white,
            letterSpacing: 1.2
          )
        ),
        backgroundColor: Colors.black,
        elevation: 4,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          const Text("No items added yet", style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  void _showItemPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.8,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
              const Padding(
                padding: EdgeInsets.all(20),
                child: Text("Select Item", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ),
              Expanded(
                child: Consumer<InventoryProvider>(
                  builder: (context, inventory, child) {
                    if (inventory.isLoading) return const Center(child: CircularProgressIndicator());
                    return ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: inventory.allItems.length,
                      separatorBuilder: (_, __) => const Divider(),
                      itemBuilder: (context, index) {
                        final item = inventory.allItems[index];
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text("Current Stock: ${item.currentStock} ${item.unit}"),
                          onTap: () {
                            Navigator.pop(context);
                            _showQuantityDialog(item);
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showQuantityDialog(InventoryItem item) {
    final TextEditingController qtyController = TextEditingController(text: "1");
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Request ${item.name}"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             Text("Enter quantity in ${item.unit}"),
             const SizedBox(height: 12),
             TextField(
               controller: qtyController,
               keyboardType: TextInputType.number,
               autofocus: true,
               decoration: const InputDecoration(border: OutlineInputBorder(), labelText: "Quantity"),
             ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("CANCEL")),
          ElevatedButton(
            onPressed: () {
              final qty = double.tryParse(qtyController.text) ?? 1.0;
              _addItem(item, qty);
              Navigator.pop(context);
            },
            child: const Text("ADD"),
          ),
        ],
      ),
    );
  }
}

