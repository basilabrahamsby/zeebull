import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:orchid_employee/core/constants/app_colors.dart';
import 'package:orchid_employee/presentation/providers/kitchen_provider.dart';
import 'package:orchid_employee/presentation/providers/attendance_provider.dart';
import 'package:orchid_employee/presentation/providers/auth_provider.dart';
import 'package:intl/intl.dart';
import 'kot_screen.dart';
import 'kot_history_screen.dart';
import 'stock_requisition_screen.dart';
import 'stock_requisition_list_screen.dart';
import 'kitchen_stock_screen.dart';
import 'wastage_log_screen.dart';
import 'wastage_list_screen.dart';
import 'kitchen_menu_screen.dart';
import 'new_order_screen.dart';

class KitchenDashboard extends StatefulWidget {
  const KitchenDashboard({super.key});

  @override
  State<KitchenDashboard> createState() => _KitchenDashboardState();
}

class _KitchenDashboardState extends State<KitchenDashboard> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      context.read<KitchenProvider>().fetchActiveOrders();
      context.read<KitchenProvider>().fetchOrderHistory(); // Add this
      context.read<KitchenProvider>().fetchRequisitions();
      context.read<KitchenProvider>().fetchEmployees(); // Add this
      context.read<AttendanceProvider>().checkTodayStatus(auth.employeeId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF8F9FA),
      child: Consumer3<KitchenProvider, AttendanceProvider, AuthProvider>(
        builder: (context, kitchen, attendance, auth, child) {
          final now = DateTime.now();
          final completedCount = kitchen.orderHistory.where((k) {
            final isToday = k.createdAt.year == now.year && 
                           k.createdAt.month == now.month && 
                           k.createdAt.day == now.day;
            final isCompleted = k.status.toLowerCase() == 'completed' || k.status.toLowerCase() == 'paid';
            return isToday && isCompleted;
          }).length;
          
          final pendingOrders = kitchen.activeKots.where((k) => k.status == 'pending').toList();
          final cookingOrders = kitchen.activeKots.where((k) => 
              k.status == 'cooking' || k.status == 'accepted' || k.status == 'preparing').toList();
          
          return Column(
            children: [
              _buildTopBar(attendance, auth),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    await Future.wait([
                      kitchen.fetchActiveOrders(),
                      kitchen.fetchOrderHistory(),
                      kitchen.fetchRequisitions(),
                      attendance.checkTodayStatus(auth.employeeId),
                    ]);
                  },
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSummaryCards(kitchen, attendance, completedCount),
                        const SizedBox(height: 24),
                        _buildLiveOrdersHeader(pendingOrders.length),
                        const SizedBox(height: 12),
                        if (pendingOrders.isEmpty && cookingOrders.isEmpty)
                          _buildEmptyState()
                        else ...[
                          ...pendingOrders.map((kot) => _buildOrderRequestCard(kot, isNew: true, isOnDuty: attendance.isClockedIn)),
                          ...cookingOrders.map((kot) => _buildOrderRequestCard(kot, isNew: false, isOnDuty: attendance.isClockedIn)),
                        ],
                        const SizedBox(height: 24),
                        _buildQuickActions(context),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTopBar(AttendanceProvider attendance, AuthProvider auth) {
    final bool isOnDuty = attendance.isClockedIn;
    return Container(
      padding: const EdgeInsets.only(top: 50, left: 20, right: 20, bottom: 20),
      decoration: BoxDecoration(
        color: isOnDuty ? const Color(0xFF1A1A1A) : Colors.red.shade900,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.menu, color: Colors.white),
                    onPressed: () => Scaffold.of(context).openDrawer(),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        DateFormat('EEEE, MMM d').format(DateTime.now()),
                        style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Chef ${auth.userName?.split(' ')[0] ?? 'User'}",
                        style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
              Row(
                children: [
                   _buildStatusToggle(attendance, auth),
                   const SizedBox(width: 10),
                   IconButton(
                     icon: const Icon(Icons.logout, color: Colors.white70, size: 20),
                     onPressed: () async {
                       await auth.logout();
                       if (context.mounted) {
                         Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
                       }
                     },
                   ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusToggle(AttendanceProvider attendance, AuthProvider auth) {
    final bool isOnDuty = attendance.isClockedIn;
    return InkWell(
      onTap: () async {
        if (attendance.isLoading) return;
        if (isOnDuty) {
          await attendance.clockOut(auth.employeeId!);
        } else {
          await attendance.clockIn(auth.employeeId!);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isOnDuty ? Colors.green.shade600 : Colors.white,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          children: [
            if (attendance.isLoading)
              const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.blue))
            else ...[
               Icon(Icons.power_settings_new, size: 18, color: isOnDuty ? Colors.white : Colors.red),
               const SizedBox(width: 8),
               Text(
                 isOnDuty ? "GO OFFLINE" : "GO ONLINE",
                 style: TextStyle(
                   color: isOnDuty ? Colors.white : Colors.black,
                   fontWeight: FontWeight.bold,
                   fontSize: 12,
                 ),
               ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCards(KitchenProvider kitchen, AttendanceProvider attendance, int completedToday) {
    final pendingReqs = kitchen.requisitions.where((r) => r['status'] == 'pending').length;
    
    return Column(
      children: [
        Row(
          children: [
            _buildStatBox("Orders Today", completedToday.toString(), Icons.check_circle, Colors.green),
            const SizedBox(width: 12),
            _buildStatBox("Active Now", kitchen.activeKots.length.toString(), Icons.timer, Colors.orange),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildStatBox("Duty Time", _formatDuration(attendance.clockInTime), Icons.access_time, Colors.blue),
            const SizedBox(width: 12),
            _buildStatBox("Pending Reqs", pendingReqs.toString(), Icons.assignment_late, Colors.purple),
          ],
        ),
      ],
    );
  }

  Widget _buildStatBox(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 2),
            Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildLiveOrdersHeader(int count) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const Text("Live Orders", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(width: 8),
            if (count > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(10)),
                child: Text(count.toString(), style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
              ),
          ],
        ),
        Row(
          children: [
            TextButton.icon(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NewOrderScreen())),
              icon: const Icon(Icons.add, size: 18),
              label: const Text("New Order"),
              style: TextButton.styleFrom(foregroundColor: Colors.blue),
            ),
            TextButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const KOTScreen())),
              child: const Text("View All"),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOrderRequestCard(dynamic kot, {required bool isNew, required bool isOnDuty}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0,
      child: Container(
         decoration: BoxDecoration(
           border: isNew ? Border.all(color: Colors.red.withOpacity(0.3), width: 1.5) : null,
           borderRadius: BorderRadius.circular(16),
         ),
         child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          if (isNew) 
                            Container(
                              margin: const EdgeInsets.only(right: 8),
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(4)),
                              child: const Text("NEW", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                            ),
                          Text(kot.roomNumber, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text("${kot.items.length} Items • ${kot.orderType.replaceAll('_', ' ').toUpperCase()}", 
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 12, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 2),
                      SizedBox(
                        width: 200,
                        child: Text(
                          kot.items.map((i) => "${i.quantity}x ${i.itemName}").join(", "),
                          style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  Text(DateFormat('hh:mm a').format(kot.createdAt), style: TextStyle(color: Colors.grey.shade400, fontSize: 12)),
                ],
              ),
              const Divider(height: 24),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: isOnDuty ? () => _showOrderActionDialog(context, kot) : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isOnDuty 
                            ? (isNew ? Colors.blue.shade600 : Colors.green.shade600)
                            : Colors.grey.shade400,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: Text(
                        isOnDuty 
                            ? (isNew ? "START COOKING" : "MARK READY")
                            : "CLOCK IN TO START"
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showOrderActionDialog(BuildContext context, dynamic kot) {
    final bool isNew = kot.status == 'pending';
    final kitchen = context.read<KitchenProvider>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isNew ? "Accept and Cook" : "Mark as Ready"),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: [
              Text("Room: ${kot.roomNumber ?? 'N/A'}", style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              const Text("Items:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              ...kot.items.map((item) => FutureBuilder<Map<String, dynamic>?>(
                future: kitchen.fetchRecipe(item.foodItemId),
                builder: (context, snapshot) {
                  final recipe = snapshot.data;
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("${item.quantity}x ${item.itemName}", style: const TextStyle(fontWeight: FontWeight.bold)),
                              if (recipe != null)
                                const Icon(Icons.receipt_long, size: 16, color: Colors.blue),
                            ],
                          ),
                          if (recipe != null) ...[
                            const SizedBox(height: 4),
                            Text("Recipe: ${recipe['name']}", style: const TextStyle(fontSize: 11, color: Colors.blue, fontStyle: FontStyle.italic)),
                            if (recipe['ingredients'] != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  "Ingredients: ${(recipe['ingredients'] as List).map((ing) => "${ing['quantity']} ${ing['unit']} ${ing['inventory_item_name']}").join(", ")}",
                                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                                ),
                              ),
                          ] else if (snapshot.connectionState == ConnectionState.waiting)
                            const LinearProgressIndicator()
                          else
                            const Text("No recipe found", style: TextStyle(fontSize: 10, color: Colors.grey)),
                        ],
                      ),
                    ),
                  );
                },
              )),
              if (kot.deliveryRequest != null && kot.deliveryRequest!.isNotEmpty) ...[
                const SizedBox(height: 12),
                const Text("Notes:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                Text(kot.deliveryRequest!, style: const TextStyle(fontSize: 12, color: Colors.red)),
              ],
              const SizedBox(height: 16),
              Consumer<AuthProvider>(
                builder: (context, auth, _) {
                  if (auth.role != UserRole.manager) return const SizedBox.shrink();
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Assign Delivery (Optional):", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      const SizedBox(height: 8),
                      StatefulBuilder(
                        builder: (context, setState) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<int>(
                                isExpanded: true,
                                hint: const Text("Select Staff Member"),
                                value: kot.assignedEmployeeId,
                                items: kitchen.employees.map<DropdownMenuItem<int>>((emp) {
                                  final bool isActive = emp['status'] == 'on_duty';
                                  return DropdownMenuItem<int>(
                                    value: emp['id'],
                                    child: Text(
                                      "${emp['name']} (${emp['role']})${isActive ? ' [ACTIVE]' : ''}",
                                      style: TextStyle(
                                        color: isActive ? Colors.green.shade700 : Colors.black,
                                        fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                                      ),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (val) async {
                                  if (val != null) {
                                    final success = await kitchen.assignOrder(kot.id, val);
                                    if (success) {
                                      setState(() {
                                        kot.assignedEmployeeId = val;
                                      });
                                    }
                                  }
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  );
                }
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("CANCEL")),
          ElevatedButton(
            onPressed: () async {
              final newStatus = isNew ? 'preparing' : 'ready';
              final success = await kitchen.updateStatus(kot.id, newStatus);
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(success ? "Order updated to $newStatus" : "Failed to update order"))
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: isNew ? Colors.blue : Colors.green, foregroundColor: Colors.white),
            child: Text(isNew ? "START COOKING" : "MARK READY"),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
     return Center(
       child: Padding(
         padding: const EdgeInsets.symmetric(vertical: 40),
         child: Column(
           children: [
             Icon(Icons.restaurant_menu, size: 64, color: Colors.grey.shade300),
             const SizedBox(height: 16),
             Text("No new orders right now", style: TextStyle(color: Colors.grey.shade500, fontSize: 16)),
           ],
         ),
       ),
     );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Kitchen Tools", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildActionIcon(context, "Stock", Icons.inventory, Colors.teal, const KitchenStockScreen()),
            _buildActionIcon(context, "Req Stock", Icons.add_shopping_cart, Colors.purple, const StockRequisitionScreen()),
            _buildActionIcon(context, "Requests", Icons.assignment, Colors.indigo, const StockRequisitionListScreen()),
            _buildActionIcon(context, "Wastage", Icons.delete_sweep, Colors.orange, const WastageListScreen()),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            _buildActionIcon(context, "History", Icons.history, Colors.blueGrey, const KOTHistoryScreen()),
            _buildActionIcon(context, "Menu", Icons.book, Colors.brown, const KitchenMenuScreen()),
            const Spacer(flex: 2), // Fill space
          ],
        ),
      ],
    );
  }

  Widget _buildActionIcon(BuildContext context, String label, IconData icon, Color color, Widget? screen) {
    return Expanded(
      child: InkWell(
        onTap: () {
          if (screen != null) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
          } else {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Coming soon!")));
          }
        },
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  String _formatDuration(DateTime? clockInTime) {
    if (clockInTime == null) return "0h 0m";
    final diff = DateTime.now().difference(clockInTime);
    return "${diff.inHours}h ${diff.inMinutes % 60}m";
  }
}
