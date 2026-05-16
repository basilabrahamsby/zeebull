import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:orchid_employee/presentation/providers/food_management_provider.dart';
import 'package:orchid_employee/data/models/food_management_model.dart';
import 'package:orchid_employee/data/models/menu_model.dart';
import 'package:orchid_employee/core/constants/app_colors.dart';
import 'package:orchid_employee/presentation/widgets/onyx_glass_card.dart';

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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FoodManagementProvider>().fetchAllManagementData();
    });
  }

  List<String> _getCategories(List<FoodCategory> categories) {
    return ['All', ...categories.map((c) => c.name)];
  }

  List<FoodItem> _getFilteredMenu(List<FoodItem> items, List<FoodCategory> categories) {
    return items.where((item) {
      final category = categories.firstWhere((c) => c.id == item.categoryId, 
          orElse: () => FoodCategory(id: 0, name: "Unknown")).name;
      
      final matchesCategory = _selectedCategory == 'All' || category == _selectedCategory;
      final matchesSearch = item.name.toLowerCase().contains(_searchController.text.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();
  }

  void _addToCart(FoodItem item) {
    setState(() {
      final existingIndex = _cart.indexWhere((c) => c.item.id == item.id.toString());
      if (existingIndex != -1) {
        _cart[existingIndex].quantity++;
      } else {
        _cart.add(CartItem(item: MenuItem(
          id: item.id.toString(),
          name: item.name,
          category: "Food", // Fallback
          price: item.price,
          description: item.description,
        )));
      }
    });
  }

  void _removeFromCart(FoodItem item) {
    setState(() {
      final existingIndex = _cart.indexWhere((c) => c.item.id == item.id.toString());
      if (existingIndex != -1) {
        if (_cart[existingIndex].quantity > 1) {
          _cart[existingIndex].quantity--;
        } else {
          _cart.removeAt(existingIndex);
        }
      }
    });
  }

  int _getItemQuantity(int itemId) {
    final cartItem = _cart.firstWhere((c) => c.item.id == itemId.toString(), 
        orElse: () => CartItem(item: MenuItem(id: "", name: "", category: "", price: 0), quantity: 0));
    return cartItem.quantity;
  }

  double get _totalAmount => _cart.fold(0, (sum, item) => sum + (item.item.price * item.quantity));

  @override
  Widget build(BuildContext context) {
    final foodProvider = context.watch<FoodManagementProvider>();
    final items = foodProvider.items;
    final categories = foodProvider.categories;
    
    final filteredMenu = _getFilteredMenu(items, categories);
    final categoryList = _getCategories(categories);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(widget.tableId != null ? "Order for ${widget.tableId}" : "Take Order"),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
      ),
      body: foodProvider.isLoading && items.isEmpty 
        ? const Center(child: CircularProgressIndicator())
        : Column(
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
                    children: categoryList.map((cat) => Padding(
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
            child: filteredMenu.isEmpty 
              ? Center(child: Text("No items found", style: TextStyle(color: Colors.grey[400])))
              : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filteredMenu.length,
              itemBuilder: (context, index) {
                final item = filteredMenu[index];
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
  final FoodItem item;
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
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: Colors.grey.withOpacity(0.05))),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
                  const SizedBox(height: 4),
                  if (item.description != null && item.description!.isNotEmpty)
                    Text(item.description!, style: TextStyle(color: Colors.grey[600], fontSize: 13, height: 1.3), maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 12),
                  Text("₹${item.price.toStringAsFixed(0)}", style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Colors.black)),
                ],
              ),
            ),
            if (quantity == 0)
              TextButton(
                onPressed: onAdd,
                style: TextButton.styleFrom(
                  foregroundColor: Colors.green[700],
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.green[700]!, width: 1.5),
                  ),
                ),
                child: const Text("ADD", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13)),
              )
            else
              Container(
                decoration: BoxDecoration(
                  color: Colors.green[700],
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(color: Colors.green[700]!.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4)),
                  ],
                ),
                child: Row(
                  children: [
                    IconButton(icon: const Icon(Icons.remove, color: Colors.white, size: 20), onPressed: onRemove),
                    Text("$quantity", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16)),
                    IconButton(icon: const Icon(Icons.add, color: Colors.white, size: 20), onPressed: onAdd),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
