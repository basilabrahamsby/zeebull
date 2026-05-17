import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:orchid_employee/core/constants/app_colors.dart';
import 'package:orchid_employee/presentation/screens/waiter/waiter_service_screen.dart';
import 'package:orchid_employee/presentation/screens/waiter/menu_order_screen.dart';
import 'package:orchid_employee/presentation/providers/auth_provider.dart';
import 'package:orchid_employee/presentation/providers/room_provider.dart';
import 'package:orchid_employee/data/models/room_model.dart';
import 'package:orchid_employee/data/models/restaurant_table_model.dart';
import 'package:orchid_employee/presentation/widgets/onyx_glass_card.dart';
import 'package:orchid_employee/presentation/widgets/modals/create_service_request_modal.dart';
import 'package:orchid_employee/presentation/widgets/modals/food_order_modals.dart';
import 'package:orchid_employee/presentation/providers/kitchen_provider.dart';
import 'package:orchid_employee/data/services/api_service.dart';
import 'package:provider/provider.dart';

class WaiterDashboard extends StatefulWidget {
  const WaiterDashboard({super.key});

  @override
  State<WaiterDashboard> createState() => _WaiterDashboardState();
}

class _WaiterDashboardState extends State<WaiterDashboard> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RoomProvider>().fetchRestaurantTables();
      context.read<RoomProvider>().fetchRoomStats();
      context.read<RoomProvider>().fetchRoomTypes();
      context.read<KitchenProvider>().fetchActiveOrders(silent: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final roomProvider = context.watch<RoomProvider>();
    final kitchenProvider = context.watch<KitchenProvider>();
    
    final tables = roomProvider.restaurantTables;

    final available = tables.where((t) {
      final hasActive = kitchenProvider.activeKots.any((k) => k.tableId == t.id);
      return t.status.toLowerCase() == 'available' && !hasActive;
    }).length.toString();
    final occupied = tables.where((t) {
      final hasActive = kitchenProvider.activeKots.any((k) => k.tableId == t.id);
      return ['occupied', 'booked', 'checked_in'].contains(t.status.toLowerCase()) || hasActive;
    }).length.toString();
    final total = tables.length.toString();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.onyx,
        body: Column(
          children: [
            // Header Summary
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: AppColors.onyx,
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.menu_rounded, color: Colors.white),
                            onPressed: () => Scaffold.of(context).openDrawer(),
                          ),
                          const SizedBox(width: 12),
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "RESTAURANT",
                                style: TextStyle(color: AppColors.accent, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2),
                              ),
                              Text(
                                "STATUS",
                                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 0.5),
                              ),
                            ],
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.logout_rounded, color: Colors.white70),
                        onPressed: () async {
                          await context.read<AuthProvider>().logout();
                          if (context.mounted) {
                            Navigator.pushReplacementNamed(context, '/login');
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _QuickStat(label: "TOTAL TABLES", value: total, color: Colors.white),
                      const SizedBox(width: 24),
                      _QuickStat(label: "AVAIL TABLES", value: available, color: Colors.greenAccent),
                      const SizedBox(width: 24),
                      _QuickStat(label: "OCCUPIED", value: occupied, color: AppColors.accent),
                    ],
                  ),
                ],
              ),
            ),
            
            // Top TabBar
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
              ),
              child: TabBar(
                indicator: BoxDecoration(
                  color: AppColors.accent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.accent.withOpacity(0.2)),
                ),
                labelColor: AppColors.accent,
                unselectedLabelColor: Colors.white24,
                labelStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1),
                dividerColor: Colors.transparent,
                tabs: const [
                  Tab(text: "TABLES"),
                  Tab(text: "MY SERVICE TASKS"),
                ],
              ),
            ),

            Expanded(
              child: TabBarView(
                children: [
                  // Tab 1: Tables Grid
                  CustomScrollView(
                    slivers: [
                      // Search & Filter
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  style: const TextStyle(color: Colors.white, fontSize: 14),
                                  decoration: InputDecoration(
                                    hintText: "Search table...",
                                    hintStyle: const TextStyle(color: Colors.white24, fontSize: 14),
                                    prefixIcon: const Icon(Icons.search_rounded, color: Colors.white24, size: 20),
                                    fillColor: Colors.white10,
                                    filled: true,
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: BorderSide.none,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: IconButton(
                                  icon: const Icon(Icons.add_box_rounded, color: AppColors.accent),
                                  onPressed: () => _showCreateTableDialog(),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      // Table Grid
                      if (roomProvider.isLoading && tables.isEmpty)
                        const SliverFillRemaining(child: Center(child: CircularProgressIndicator(color: AppColors.accent)))
                      else
                        SliverPadding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          sliver: SliverGrid(
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              childAspectRatio: 0.85,
                            ),
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final table = tables[index];
                                final tableKots = kitchenProvider.activeKots.where((k) => k.tableId == table.id).toList();
                                return _buildTableCard(table, tableKots);
                              },
                              childCount: tables.length,
                            ),
                          ),
                        ),
                      const SliverToBoxAdapter(child: SizedBox(height: 80)),
                    ],
                  ),
                  
                  // Tab 2: Services View
                  const WaiterServiceScreen(hideHeader: true),
                ],
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _showCreateOptions(context),
          backgroundColor: AppColors.accent,
          icon: const Icon(Icons.add),
          label: const Text("CREATE"),
        ),
      ),
    );
  }

  Widget _buildTableCard(RestaurantTable table, List<dynamic> tableKots) {
    final bool hasActiveOrder = tableKots.isNotEmpty;
    final bool isOccupied = table.status.toLowerCase() == 'occupied' || hasActiveOrder;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: OnyxGlassCard(
        padding: const EdgeInsets.all(16),
        borderRadius: 24,
        borderColor: (isOccupied ? AppColors.accent : Colors.greenAccent).withOpacity(0.2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: (isOccupied ? AppColors.accent : Colors.greenAccent).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.restaurant_menu_rounded, 
                    color: isOccupied ? AppColors.accent : Colors.greenAccent, size: 20),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: (isOccupied ? AppColors.accent : Colors.greenAccent).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(table.status.toUpperCase(), 
                    style: TextStyle(color: isOccupied ? AppColors.accent : Colors.greenAccent, 
                      fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(table.tableNumber, 
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16)),
            Text("Capacity: ${table.seatingCapacity}", 
              style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 10, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (hasActiveOrder || isOccupied) {
                    _showActiveOrdersForTable(context, table.id, table.tableNumber);
                  } else {
                    showCreateFoodOrderModal(context, defaultTableId: table.id, onCreated: () {
                       context.read<KitchenProvider>().fetchActiveOrders(silent: true);
                    });
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.05),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: Text(hasActiveOrder ? "VIEW ORDERS" : (isOccupied ? "VIEW DETAILS" : "NEW ORDER"), 
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1)),
              ),
            ),
            if (hasActiveOrder) ...[
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _showBillingDialog(context, table, tableKots),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text("CREATE BILL", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showBillingDialog(BuildContext context, RestaurantTable table, List<dynamic> tableKots) async {
    showDialog(context: context, builder: (_) => const Center(child: CircularProgressIndicator(color: AppColors.accent)));
    
    try {
      final api = context.read<ApiService>();
      final resp = await api.getFoodOrders();
      if (!context.mounted) return;
      Navigator.pop(context); // close loader
      
      final allOrders = resp.data as List? ?? [];
      final tableOrders = allOrders.where((o) => o['table_id'] == table.id && o['status'] != 'completed' && o['status'] != 'cancelled' && o['billing_status'] != 'paid').toList();

      if (tableOrders.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("No unpaid active orders found for billing.")));
        return;
      }

      double grandTotal = 0.0;
      List<dynamic> allItems = [];
      for (var order in tableOrders) {
         grandTotal += (order['total_with_gst'] ?? order['amount'] ?? 0.0);
         allItems.addAll(order['items'] ?? []);
      }

      int? selectedRoomId;
      List<dynamic> activeRooms = [];
      bool loadingRooms = false;
      String paymentMethod = 'cash'; // 'cash', 'upi', 'room'

      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (ctx) => BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: StatefulBuilder(
            builder: (ctx, setSheetState) {
              if (paymentMethod == 'room' && activeRooms.isEmpty && !loadingRooms) {
                loadingRooms = true;
                WidgetsBinding.instance.addPostFrameCallback((_) async {
                  try {
                    final roomsResp = await api.getRooms(queryParameters: {'status': 'Checked-in'});
                    final rooms = roomsResp.data as List? ?? [];
                    setSheetState(() {
                      activeRooms = rooms.where((r) {
                        final status = (r['status'] ?? '').toString().toLowerCase();
                        return status == 'checked-in' || status == 'checked_in' || status == 'occupied';
                      }).toList();
                      loadingRooms = false;
                    });
                  } catch (e) {
                    setSheetState(() { loadingRooms = false; });
                  }
                });
              }

              return Container(
                decoration: BoxDecoration(color: AppColors.onyx.withOpacity(0.95), borderRadius: const BorderRadius.vertical(top: Radius.circular(32)), border: Border.all(color: Colors.white10)),
                height: MediaQuery.of(context).size.height * 0.82,
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("BILL FOR ${table.tableNumber}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 1.5)),
                        IconButton(icon: const Icon(Icons.close, color: Colors.white38), onPressed: () => Navigator.pop(ctx)),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Expanded(
                      child: ListView.builder(
                        itemCount: allItems.length,
                        itemBuilder: (context, index) {
                          final item = allItems[index];
                          final itemName = (item['food_item_name']?.toString() ?? 'UNKNOWN ITEM').toUpperCase();
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(color: Colors.white.withOpacity(0.03), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withOpacity(0.05))),
                            child: Row(
                              children: [
                                Text("${item['quantity']}X", style: const TextStyle(color: AppColors.accent, fontWeight: FontWeight.w900, fontSize: 14)),
                                const SizedBox(width: 16),
                                Expanded(child: Text(itemName, style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.white, fontSize: 13, letterSpacing: 0.5))),
                                Text("₹${item['subtotal'] ?? (item['price'] != null ? (item['price'] * item['quantity']) : '0')}", style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.white70, fontSize: 14)),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(color: AppColors.accent.withOpacity(0.1), borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.accent.withOpacity(0.3))),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("GRAND TOTAL", style: TextStyle(color: AppColors.accent, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1)),
                              const SizedBox(height: 4),
                              Text("${tableOrders.length} Orders • ${allItems.length} Items", style: const TextStyle(color: Colors.white60, fontSize: 10, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          Text("₹$grandTotal", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 24)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text("SELECT PAYMENT METHOD TO SETTLE:", style: TextStyle(color: Colors.white38, fontSize: 11, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () => setSheetState(() => paymentMethod = 'cash'),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: paymentMethod == 'cash' ? Colors.greenAccent.withOpacity(0.15) : Colors.white.withOpacity(0.02),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: paymentMethod == 'cash' ? Colors.greenAccent : Colors.white10),
                              ),
                              child: Column(
                                children: [
                                  Icon(Icons.money, color: paymentMethod == 'cash' ? Colors.greenAccent : Colors.white60),
                                  const SizedBox(height: 4),
                                  Text("CASH", style: TextStyle(color: paymentMethod == 'cash' ? Colors.greenAccent : Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: InkWell(
                            onTap: () => setSheetState(() => paymentMethod = 'upi'),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: paymentMethod == 'upi' ? Colors.blueAccent.withOpacity(0.15) : Colors.white.withOpacity(0.02),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: paymentMethod == 'upi' ? Colors.blueAccent : Colors.white10),
                              ),
                              child: Column(
                                children: [
                                  Icon(Icons.qr_code, color: paymentMethod == 'upi' ? Colors.blueAccent : Colors.white60),
                                  const SizedBox(height: 4),
                                  Text("UPI", style: TextStyle(color: paymentMethod == 'upi' ? Colors.blueAccent : Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: InkWell(
                            onTap: () => setSheetState(() => paymentMethod = 'room'),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: paymentMethod == 'room' ? AppColors.accent.withOpacity(0.15) : Colors.white.withOpacity(0.02),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: paymentMethod == 'room' ? AppColors.accent : Colors.white10),
                              ),
                              child: Column(
                                children: [
                                  Icon(Icons.hotel, color: paymentMethod == 'room' ? AppColors.accent : Colors.white60),
                                  const SizedBox(height: 4),
                                  Text("ROOM", style: TextStyle(color: paymentMethod == 'room' ? AppColors.accent : Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (paymentMethod == 'room') ...[
                      const SizedBox(height: 16),
                      if (loadingRooms)
                        const Center(child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: AppColors.accent, strokeWidth: 2)))
                      else if (activeRooms.isEmpty)
                        const Text("NO ACTIVE CHECKED-IN ROOMS AVAILABLE", style: TextStyle(color: Colors.redAccent, fontSize: 11, fontWeight: FontWeight.bold))
                      else
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.white10),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<int>(
                              value: selectedRoomId,
                              dropdownColor: AppColors.onyx,
                              isExpanded: true,
                              hint: const Text("SELECT GUEST ROOM", style: TextStyle(color: Colors.white24, fontSize: 12)),
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                              items: activeRooms.map((r) => DropdownMenuItem<int>(value: r['id'], child: Text("ROOM ${r['number'] ?? r['room_number']}"))).toList(),
                              onChanged: (v) => setSheetState(() => selectedRoomId = v),
                            ),
                          ),
                        ),
                    ],
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () {
                          if (paymentMethod == 'room') {
                            if (selectedRoomId == null) {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("PLEASE SELECT A ROOM TO CHARGE"), backgroundColor: Colors.orangeAccent));
                              return;
                            }
                            _settleBillToRoom(context, tableKots, selectedRoomId!);
                          } else {
                            _settleBill(context, tableKots, paymentMethod);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: paymentMethod == 'cash'
                              ? Colors.greenAccent
                              : paymentMethod == 'upi'
                                  ? Colors.blueAccent
                                  : AppColors.accent,
                          foregroundColor: paymentMethod == 'upi' ? Colors.white : AppColors.onyx,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: Text(
                          paymentMethod == 'room'
                              ? "CHARGE TO ROOM"
                              : "SETTLE BILL (${paymentMethod.toUpperCase()})",
                          style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5, fontSize: 14),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              );
            },
          ),
        ),
      );
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context); // close loader
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error fetching bill details: $e")));
      }
    }
  }

  void _settleBill(BuildContext context, List<dynamic> kots, String method) async {
    final provider = context.read<KitchenProvider>();
    final roomProvider = context.read<RoomProvider>();
    int successCount = 0;
    
    // Show loading
    showDialog(context: context, barrierDismissible: false, builder: (_) => const Center(child: CircularProgressIndicator()));

    for (var kot in kots) {
      final success = await provider.markOrderPaid(kot.id, method);
      if (success) successCount++;
    }

    if (context.mounted) {
      await roomProvider.fetchRestaurantTables();
      await provider.fetchActiveOrders(silent: true);
      Navigator.pop(context); // close loading
      Navigator.pop(context); // close billing dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Settled $successCount orders via ${method.toUpperCase()}")),
      );
    }
  }

  void _settleBillToRoom(BuildContext context, List<dynamic> kots, int roomId) async {
    final api = context.read<ApiService>();
    final provider = context.read<KitchenProvider>();
    final roomProvider = context.read<RoomProvider>();
    int successCount = 0;
    
    // Show loading
    showDialog(context: context, barrierDismissible: false, builder: (_) => const Center(child: CircularProgressIndicator(color: AppColors.accent)));

    for (var kot in kots) {
      try {
        final updateData = {
          'status': 'completed',
          'billing_status': 'unpaid',
          'room_id': roomId,
        };
        await api.updateFoodOrder(kot.id, updateData);
        successCount++;
      } catch (e) {
        print("Error settling KOT to room: $e");
      }
    }

    if (context.mounted) {
      await roomProvider.fetchRestaurantTables();
      await provider.fetchActiveOrders(silent: true);
      Navigator.pop(context); // close loading
      Navigator.pop(context); // close billing dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Charged $successCount orders to Room successfully"), backgroundColor: Colors.green),
      );
    }
  }

  void _showActiveOrdersForTable(BuildContext context, int tableId, String tableNumber) async {
    showDialog(context: context, builder: (_) => const Center(child: CircularProgressIndicator(color: AppColors.accent)));
    
    try {
      final api = context.read<ApiService>();
      final resp = await api.getFoodOrders();
      if (!context.mounted) return;
      Navigator.pop(context); // close loader
      
      final allOrders = resp.data as List? ?? [];
      final tableOrders = allOrders.where((o) => o['table_id'] == tableId && o['status'] != 'completed' && o['status'] != 'cancelled').toList();

      if (tableOrders.isEmpty) {
        showCreateFoodOrderModal(context, defaultTableId: tableId, onCreated: () {
          context.read<KitchenProvider>().fetchActiveOrders(silent: true);
        });
        return;
      }

      if (tableOrders.length == 1) {
        showFoodOrderDetailModal(context, tableOrders.first, () {
          context.read<KitchenProvider>().fetchActiveOrders(silent: true);
        });
        return;
      }

      // Show list of orders if multiple
      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (ctx) => BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(color: AppColors.onyx.withOpacity(0.95), borderRadius: const BorderRadius.vertical(top: Radius.circular(32)), border: Border.all(color: Colors.white10)),
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("ACTIVE ORDERS FOR $tableNumber", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16)),
                const SizedBox(height: 24),
                Expanded(
                  child: ListView.builder(
                    itemCount: tableOrders.length,
                    itemBuilder: (context, index) {
                      final order = tableOrders[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: OnyxGlassCard(
                          padding: EdgeInsets.zero,
                          child: ListTile(
                            title: Text("ORDER #${order['id']}", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14)),
                            subtitle: Text((order['status'] ?? 'PENDING').toString().toUpperCase(), style: const TextStyle(color: AppColors.accent, fontWeight: FontWeight.bold, fontSize: 10)),
                            trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white24, size: 16),
                            onTap: () {
                              Navigator.pop(ctx);
                              showFoodOrderDetailModal(context, order, () {
                                context.read<KitchenProvider>().fetchActiveOrders(silent: true);
                              });
                            },
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
      );

    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context); // close loader
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error fetching orders: $e")));
      }
    }
  }

  void _showCreateOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.onyx.withOpacity(0.95),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            border: Border.all(color: Colors.white10),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 40, height: 4, margin: const EdgeInsets.only(bottom: 24), decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(2))),
              const Text("WHAT WOULD YOU LIKE TO CREATE?", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 1)),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: _buildCreateOption(
                      title: "NEW SERVICE",
                      icon: Icons.cleaning_services_rounded,
                      color: Colors.blueAccent,
                      onTap: () {
                        Navigator.pop(ctx);
                        _showCreateServiceModal(context);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildCreateOption(
                      title: "NEW TABLE",
                      icon: Icons.add_business_rounded,
                      color: Colors.greenAccent,
                      onTap: () {
                        Navigator.pop(ctx);
                        _showCreateTableDialog();
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCreateOption({required String title, required IconData icon, required Color color, required VoidCallback onTap}) {
    return OnyxGlassCard(
      padding: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24.0),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(height: 12),
              Text(title, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1)),
            ],
          ),
        ),
      ),
    );
  }

  void _showCreateServiceModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const CreateServiceRequestModal(),
    );
  }

  void _showCreateTableDialog() {
    final roomProvider = context.read<RoomProvider>();
    final numberController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: AppColors.onyx,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Text("CREATE NEW TABLE", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: numberController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "Table Number (e.g. T101)",
                  hintStyle: const TextStyle(color: Colors.white24),
                  filled: true,
                  fillColor: Colors.white10,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("CANCEL", style: TextStyle(color: Colors.white38, fontWeight: FontWeight.bold)),
            ),
            ElevatedButton(
              onPressed: () async {
                if (numberController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please fill all fields")));
                  return;
                }
                
                final success = await roomProvider.createRestaurantTable({
                  "table_number": numberController.text,
                  "seating_capacity": 4,
                  "status": "Available",
                  "branch_id": 1,
                });
                if (success && context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Table created successfully")));
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.accent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: const Text("CREATE", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _QuickStat({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value, style: TextStyle(color: color, fontSize: 24, fontWeight: FontWeight.w900)),
        Text(label, style: TextStyle(color: color.withOpacity(0.4), fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1)),
      ],
    );
  }
}

class TableStatus {
  final String id;
  final int number;
  final String status;
  final int capacity;

  TableStatus({
    required this.id,
    required this.number,
    required this.status,
    required this.capacity,
  });
}
