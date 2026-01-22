import 'package:flutter/material.dart';
import 'package:orchid_employee/data/models/menu_model.dart';
import 'package:orchid_employee/core/constants/app_colors.dart';

class MenuOrderScreen extends StatefulWidget {
  final String? tableId;
  const MenuOrderScreen({super.key, this.tableId});

  @override
  State<MenuOrderScreen> createState() => _MenuOrderScreenState();
}

class _MenuOrderScreenState extends State<MenuOrderScreen> {
  String _selectedCategory = 'All';
  final List<CartItem> _cart = [];
  final TextEditingController _searchController = TextEditingController();

  // Mock Menu Data
  final List<MenuItem> _menuItems = [
    MenuItem(id: "1", name: "Paneer Tikka", category: "Starters", price: 280, description: "Grilled cottage cheese with spices"),
    MenuItem(id: "2", name: "Chicken 65", category: "Starters", price: 320),
    MenuItem(id: "3", name: "Butter Chicken", category: "Main Course", price: 450),
    MenuItem(id: "4", name: "Dal Makhani", category: "Main Course", price: 350),
    MenuItem(id: "5", name: "Butter Naan", category: "Breads", price: 60),
    MenuItem(id: "6", name: "Garlic Naan", category: "Breads", price: 80),
    MenuItem(id: "7", name: "Jeera Rice", category: "Rice", price: 180),
    MenuItem(id: "8", name: "Gulab Jamun", category: "Desserts", price: 120),
    MenuItem(id: "9", name: "Fresh Lime Soda", category: "Beverages", price: 90),
  ];

  List<String> get _categories => ['All', ..._menuItems.map((m) => m.category).toSet()];

  List<MenuItem> get _filteredMenu {
    return _menuItems.where((item) {
      final matchesCategory = _selectedCategory == 'All' || item.category == _selectedCategory;
      final matchesSearch = item.name.toLowerCase().contains(_searchController.text.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();
  }

  void _addToCart(MenuItem item) {
    setState(() {
      final existingIndex = _cart.indexWhere((c) => c.item.id == item.id);
      if (existingIndex != -1) {
        _cart[existingIndex].quantity++;
      } else {
        _cart.add(CartItem(item: item));
      }
    });
  }

  void _removeFromCart(MenuItem item) {
    setState(() {
      final existingIndex = _cart.indexWhere((c) => c.item.id == item.id);
      if (existingIndex != -1) {
        if (_cart[existingIndex].quantity > 1) {
          _cart[existingIndex].quantity--;
        } else {
          _cart.removeAt(existingIndex);
        }
      }
    });
  }

  int _getItemQuantity(String itemId) {
    final cartItem = _cart.firstWhere((c) => c.item.id == itemId, orElse: () => CartItem(item: MenuItem(id: "", name: "", category: "", price: 0), quantity: 0));
    return cartItem.quantity;
  }

  double get _totalAmount => _cart.fold(0, (sum, item) => sum + (item.item.price * item.quantity));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(widget.tableId != null ? "Order for ${widget.tableId}" : "Take Order"),
        backgroundColor: Colors.green[700],
      ),
      body: Column(
        children: [
          // Search & Filters
          Container(
            color: Colors.white,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (v) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: "Search dishes...",
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.only(left: 16, bottom: 16),
                  child: Row(
                    children: _categories.map((cat) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(cat),
                        selected: _selectedCategory == cat,
                        onSelected: (selected) {
                          if (selected) setState(() => _selectedCategory = cat);
                        },
                        selectedColor: Colors.green[700],
                        labelStyle: TextStyle(color: _selectedCategory == cat ? Colors.white : Colors.black87),
                      ),
                    )).toList(),
                  ),
                ),
              ],
            ),
          ),

          // Menu List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _filteredMenu.length,
              itemBuilder: (context, index) {
                final item = _filteredMenu[index];
                final qty = _getItemQuantity(item.id);
                return _MenuCard(
                  item: item,
                  quantity: qty,
                  onAdd: () => _addToCart(item),
                  onRemove: () => _removeFromCart(item),
                );
              },
            ),
          ),

          // Bottom Cart Summary
          if (_cart.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, -5)),
                ],
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("${_cart.length} Items Selected", style: const TextStyle(fontWeight: FontWeight.bold)),
                          Text("Total: ₹${_totalAmount.toStringAsFixed(0)}", style: TextStyle(color: Colors.green[700], fontSize: 18, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        // Navigate to Review/Submit Order
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[700],
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text("PLACE ORDER", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  final MenuItem item;
  final int quantity;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  const _MenuCard({
    required this.item,
    required this.quantity,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  if (item.description != null)
                    Text(item.description!, style: TextStyle(color: Colors.grey[600], fontSize: 12), maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 8),
                  Text("₹${item.price.toStringAsFixed(0)}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                ],
              ),
            ),
            if (quantity == 0)
              TextButton(
                onPressed: onAdd,
                style: TextButton.styleFrom(
                  foregroundColor: Colors.green[700],
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(color: Colors.green[700]!),
                  ),
                ),
                child: const Text("ADD"),
              )
            else
              Container(
                decoration: BoxDecoration(
                  color: Colors.green[700],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    IconButton(icon: const Icon(Icons.remove, color: Colors.white), onPressed: onRemove),
                    Text("$quantity", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    IconButton(icon: const Icon(Icons.add, color: Colors.white), onPressed: onAdd),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
