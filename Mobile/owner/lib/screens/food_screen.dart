import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/food_provider.dart';
import 'food_analytics_screen.dart';
import 'food_history_screen.dart';
import 'food_add_item_screen.dart';
import 'package:intl/intl.dart';

class FoodScreen extends StatefulWidget {
  const FoodScreen({super.key});

  @override
  State<FoodScreen> createState() => _FoodScreenState();
}

class _FoodScreenState extends State<FoodScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _menuSearch = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    Future.microtask(() =>
        Provider.of<FoodProvider>(context, listen: false).fetchFoodData());
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'ordered': return Colors.blue;
      case 'preparing': return Colors.orange;
      case 'ready': return Colors.green;
      case 'delivered': return Colors.grey;
      default: return Colors.grey;
    }
  }

  void _showAssignStaffDialog(BuildContext context, int orderId) {
    final provider = Provider.of<FoodProvider>(context, listen: false);
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Assign Staff", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              provider.employees.isEmpty 
               ? const Text("No staff found") 
               : SizedBox(
                   height: 200,
                   child: ListView.builder(
                     itemCount: provider.employees.length,
                     itemBuilder: (context, index) {
                       final emp = provider.employees[index];
                       return ListTile(
                         leading: const CircleAvatar(child: Icon(Icons.person)),
                         title: Text(emp['name'] ?? 'Staff #${emp['id']}'),
                         onTap: () {
                           provider.assignEmployee(orderId, emp['id']);
                           Navigator.pop(ctx);
                         },
                       );
                     },
                   ),
                 )
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<FoodProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('F&B Management'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Dashboard'),
            Tab(text: 'Live Orders'),
            Tab(text: 'History'),
            Tab(text: 'Menu'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 1: Analytics
          RefreshIndicator(
            onRefresh: provider.fetchFoodData,
            child: const SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              child: FoodAnalyticsScreen(),
            ),
          ),

          // Tab 2: Live Orders
          RefreshIndicator(
            onRefresh: provider.fetchFoodData,
            child: provider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : provider.activeOrders.isEmpty
                    ? SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: Container(
                          height: MediaQuery.of(context).size.height * 0.7,
                          alignment: Alignment.center,
                          child: const Text("No active orders"),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: provider.activeOrders.length,
                        itemBuilder: (context, index) {
                          final order = provider.activeOrders[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            elevation: 3,
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(children: [
                                        CircleAvatar(
                                          backgroundColor: _getStatusColor(order.status).withOpacity(0.2),
                                          child: Icon(Icons.restaurant, color: _getStatusColor(order.status)),
                                        ),
                                        const SizedBox(width: 12),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text('Room ${order.roomNumber}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                            Text("#${order.id} • ${DateFormat('hh:mm a').format(DateTime.parse(order.createdAt))}", style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                          ],
                                        ),
                                      ]),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(color: _getStatusColor(order.status), borderRadius: BorderRadius.circular(12)),
                                        child: Text(order.status.toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                                      )
                                    ],
                                  ),
                                  const Divider(),
                                  ...order.items.map((item) => Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 2.0),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text("${item.quantity}x ${item.name}"),
                                        Text("₹${(item.price * item.quantity).toStringAsFixed(0)}"),
                                      ],
                                    ),
                                  )),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                       Text("Total: ₹${order.totalAmount}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                       if (order.assignedEmployeeId == null)
                                          OutlinedButton.icon(
                                            onPressed: () => _showAssignStaffDialog(context, order.id),
                                            icon: const Icon(Icons.person_add, size: 16),
                                            label: const Text("Assign Staff"),
                                          )
                                       else
                                          Chip(
                                            avatar: const Icon(Icons.person, size: 14),
                                            label: Text("Staff #${order.assignedEmployeeId}"),
                                            backgroundColor: Colors.blue.shade50,
                                          )
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      if (order.status.toLowerCase() == 'ordered') Expanded(child: OutlinedButton(child: const Text("Mark Preparing"), onPressed: () => provider.updateOrderStatus(order.id, 'Preparing'))),
                                      const SizedBox(width: 8),
                                      if (order.status.toLowerCase() == 'preparing') Expanded(child: OutlinedButton(child: const Text("Mark Ready"), onPressed: () => provider.updateOrderStatus(order.id, 'Ready'))),
                                      const SizedBox(width: 8),
                                      if (order.status.toLowerCase() == 'ready') Expanded(child: ElevatedButton(child: const Text("Mark Delivered"), onPressed: () => provider.updateOrderStatus(order.id, 'Delivered'))),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),

          // Tab 3: History
          RefreshIndicator(
            onRefresh: provider.fetchFoodData,
            child: const FoodHistoryScreen()
          ),

          // Tab 4: Menu Management
          Scaffold(
            body: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: "Search Menu...",
                      prefixIcon: Icon(Icons.search),
                      contentPadding: EdgeInsets.symmetric(horizontal: 10)
                    ),
                    onChanged: (val) {
                      setState(() {
                        _menuSearch = val;
                      });
                    },
                  ),
                ),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: provider.fetchFoodData,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _getFilteredMenuItems(provider).length,
                      itemBuilder: (context, index) {
                        final item = _getFilteredMenuItems(provider)[index];
                        return Card(
                          child: ListTile(
                            title: Text(item.name, style: TextStyle(decoration: item.isAvailable ? null : TextDecoration.lineThrough)),
                            subtitle: Text("${item.category} • ₹${item.price}"),
                            trailing: Switch(
                              value: item.isAvailable,
                              onChanged: (val) => provider.updateItemAvailability(item.id, val),
                            ),
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(builder: (_) => FoodAddItemScreen(item: item)));
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (_) => const FoodAddItemScreen()));
              },
              child: const Icon(Icons.add),
            ),
          ),
        ],
      ),
    );
  }

  List<dynamic> _getFilteredMenuItems(FoodProvider provider) {
    if (_menuSearch.isEmpty) return provider.menuItems;
    return provider.menuItems.where((i) => i.name.toLowerCase().contains(_menuSearch.toLowerCase())).toList();
  }
}

