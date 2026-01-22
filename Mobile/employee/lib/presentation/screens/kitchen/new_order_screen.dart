import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:orchid_employee/presentation/providers/kitchen_provider.dart';
import 'package:orchid_employee/presentation/providers/inventory_provider.dart';
import 'package:orchid_employee/presentation/providers/auth_provider.dart';
import 'package:orchid_employee/core/constants/app_colors.dart';

class NewOrderScreen extends StatefulWidget {
  const NewOrderScreen({super.key});

  @override
  State<NewOrderScreen> createState() => _NewOrderScreenState();
}

class _NewOrderScreenState extends State<NewOrderScreen> {
  final _formKey = GlobalKey<FormState>();
  int? _selectedRoomId;
  String? _selectedRoomNumber;
  String _orderType = 'dine_in'; // dine_in or room_service
  final TextEditingController _notesController = TextEditingController();
  int? _assignedEmployeeId;
  
  List<Map<String, dynamic>> _selectedItems = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<InventoryProvider>().fetchRooms();
      context.read<KitchenProvider>().fetchFoodItems();
      context.read<KitchenProvider>().fetchEmployees();
    });
  }

  double get _totalAmount {
    double total = 0;
    for (var item in _selectedItems) {
      total += (item['price'] as num) * item['quantity'];
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text("New Order"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Consumer2<InventoryProvider, KitchenProvider>(
        builder: (context, inventory, kitchen, child) {
          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildSectionHeader("Order Information"),
                const SizedBox(height: 12),
                _buildRoomSelector(inventory.rooms.where((r) {
                  final status = (r['status'] as String?)?.toLowerCase() ?? '';
                  return status == 'occupied' || status == 'checked-in';
                }).toList()),
                const SizedBox(height: 16),
                _buildOrderTypeSelector(),
                const SizedBox(height: 16),
                _buildEmployeeSelector(kitchen.employees),
                const SizedBox(height: 24),
                
                _buildSectionHeader("Selected Items"),
                const SizedBox(height: 12),
                if (_selectedItems.isEmpty)
                   _buildEmptyItemsState()
                else
                   ..._selectedItems.asMap().entries.map((entry) => _buildSelectedItemCard(entry.key, entry.value)),
                
                const SizedBox(height: 16),
                _buildAddItemButton(kitchen.foodItems),
                
                const SizedBox(height: 24),
                _buildSectionHeader("Notes"),
                const SizedBox(height: 12),
                TextField(
                  controller: _notesController,
                  decoration: InputDecoration(
                    hintText: "Enter any special requests...",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    fillColor: Colors.white,
                    filled: true,
                  ),
                  maxLines: 3,
                ),
                
                const SizedBox(height: 32),
                _buildSummary(kitchen),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title.toUpperCase(),
      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey.shade600, letterSpacing: 1),
    );
  }

  Widget _buildRoomSelector(List<dynamic> rooms) {
    return DropdownButtonFormField<int>(
      decoration: InputDecoration(
        labelText: "Select Room",
        prefixIcon: const Icon(Icons.meeting_room),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.white,
      ),
      value: _selectedRoomId,
      items: rooms.map((room) {
        return DropdownMenuItem<int>(
          value: room['id'],
          child: Text("Room ${room['number']}"),
        );
      }).toList(),
      onChanged: (val) {
        setState(() {
          _selectedRoomId = val;
          final room = rooms.firstWhere((r) => r['id'] == val);
          _selectedRoomNumber = room['number'].toString();
        });
      },
      validator: (val) => val == null ? "Please select a room" : null,
    );
  }

  Widget _buildEmployeeSelector(List<dynamic> employees) {
    return DropdownButtonFormField<int>(
      decoration: InputDecoration(
        labelText: "Assign For Delivery",
        prefixIcon: const Icon(Icons.person_outline),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.white,
      ),
      value: _assignedEmployeeId,
      items: employees.map((emp) {
        return DropdownMenuItem<int>(
          value: emp['id'],
          child: Text("${emp['name']} (${emp['role']})"),
        );
      }).toList(),
      onChanged: (val) => setState(() => _assignedEmployeeId = val),
      hint: const Text("Select Delivery Staff"),
    );
  }

  Widget _buildOrderTypeSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _buildTypeOption('dine_in', "Dine In", Icons.restaurant),
          _buildTypeOption('room_service', "Room Service", Icons.room_service),
        ],
      ),
    );
  }

  Widget _buildTypeOption(String type, String label, IconData icon) {
    final bool isSelected = _orderType == type;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _orderType = type),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isSelected ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)] : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: isSelected ? Colors.blue : Colors.grey),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? Colors.blue : Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedItemCard(int index, Map<String, dynamic> item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 0,
      child: ListTile(
        title: Text(item['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text("₹${item['price']} x ${item['quantity']}"),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.remove_circle_outline, color: Colors.grey),
              onPressed: () {
                setState(() {
                  if (item['quantity'] > 1) {
                    item['quantity']--;
                  } else {
                    _selectedItems.removeAt(index);
                  }
                });
              },
            ),
            Text("${item['quantity']}", style: const TextStyle(fontWeight: FontWeight.bold)),
            IconButton(
              icon: const Icon(Icons.add_circle_outline, color: Colors.blue),
              onPressed: () {
                setState(() {
                  item['quantity']++;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyItemsState() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Icon(Icons.shopping_basket_outlined, size: 48, color: Colors.grey.shade300),
          const SizedBox(height: 12),
          Text("No items selected yet", style: TextStyle(color: Colors.grey.shade500)),
        ],
      ),
    );
  }

  Widget _buildAddItemButton(List<dynamic> foodItems) {
    return ElevatedButton.icon(
      onPressed: () => _showAddItemDialog(foodItems),
      icon: const Icon(Icons.add),
      label: const Text("Add Menu Item"),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.blue,
        elevation: 0,
        padding: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Colors.blue),
        ),
      ),
    );
  }

  void _showAddItemDialog(List<dynamic> foodItems) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return Column(
              children: [
                const SizedBox(height: 12),
                Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text("Select Item", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: foodItems.length,
                    itemBuilder: (context, index) {
                      final item = foodItems[index];
                      final bool available = item['available'] == true || item['available'] == 'true';
                      if (!available) return const SizedBox.shrink();

                      return ListTile(
                        leading: Container(
                          width: 40, height: 40,
                          decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(8)),
                          child: const Icon(Icons.fastfood, color: Colors.blue),
                        ),
                        title: Text(item['name']),
                        subtitle: Text("₹${item['price']}"),
                        onTap: () {
                          setState(() {
                            final existingIndex = _selectedItems.indexWhere((element) => element['id'] == item['id']);
                            if (existingIndex != -1) {
                              _selectedItems[existingIndex]['quantity']++;
                            } else {
                              _selectedItems.add({
                                'id': item['id'],
                                'name': item['name'],
                                'price': item['price'],
                                'quantity': 1,
                              });
                            }
                          });
                          Navigator.pop(context);
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildSummary(KitchenProvider kitchen) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Total Amount", style: TextStyle(fontSize: 16, color: Colors.grey)),
              Text("₹${_totalAmount.toStringAsFixed(2)}", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: kitchen.isLoading || _selectedItems.isEmpty || _selectedRoomId == null
                  ? null
                  : () => _submitOrder(kitchen),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: kitchen.isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("PLACE ORDER", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submitOrder(KitchenProvider kitchen) async {
    if (!_formKey.currentState!.validate()) return;
    
    final auth = context.read<AuthProvider>();
    
    final List<Map<String, dynamic>> items = _selectedItems.map((item) => {
      'food_item_id': item['id'],
      'quantity': item['quantity'],
    }).toList();

    final orderData = {
      'room_id': _selectedRoomId,
      'amount': _totalAmount,
      'assigned_employee_id': _assignedEmployeeId ?? auth.employeeId,
      'items': items,
      'billing_status': 'unbilled',
      'order_type': _orderType,
      'delivery_request': _notesController.text,
    };

    final success = await kitchen.createOrder(orderData);
    if (success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Order placed successfully!")));
        Navigator.pop(context);
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(kitchen.error ?? "Failed to place order")));
      }
    }
  }
}
