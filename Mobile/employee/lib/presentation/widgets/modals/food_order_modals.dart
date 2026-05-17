import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:orchid_employee/core/constants/app_colors.dart';
import 'package:orchid_employee/data/services/api_service.dart';
import 'package:orchid_employee/presentation/providers/food_management_provider.dart';
import 'package:orchid_employee/data/models/food_management_model.dart';
import 'package:orchid_employee/presentation/widgets/onyx_glass_card.dart';

void showCreateFoodOrderModal(BuildContext context, {int? defaultRoomId, int? defaultTableId, VoidCallback? onCreated}) async {
  List<dynamic> rooms = [];
  List<dynamic> tables = [];
  List<dynamic> employees = [];
  bool loadingData = true;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
      child: Container(
        decoration: BoxDecoration(color: AppColors.onyx.withOpacity(0.95), borderRadius: const BorderRadius.vertical(top: Radius.circular(32)), border: Border.all(color: Colors.white10)),
        height: MediaQuery.of(context).size.height * 0.9,
        child: StatefulBuilder(
          builder: (ctx, setModalState) {
            if (loadingData) {
              _loadModalData(context).then((data) {
                if (ctx.mounted) {
                  setModalState(() {
                    rooms = data['rooms'];
                    employees = data['employees'];
                    tables = data['tables'];
                    loadingData = false;
                  });
                }
              });
              return const Center(child: CircularProgressIndicator(color: AppColors.accent));
            }
            return _CreateOrderForm(
              rooms: rooms,
              tables: tables,
              employees: employees,
              foodItems: context.read<FoodManagementProvider>().items,
              defaultRoomId: defaultRoomId,
              defaultTableId: defaultTableId,
              onCreated: () {
                Navigator.pop(ctx);
                if (onCreated != null) onCreated();
              },
            );
          },
        ),
      ),
    ),
  );
}

Future<Map<String, dynamic>> _loadModalData(BuildContext context) async {
  final api = context.read<ApiService>();
  final results = await Future.wait([
    api.getRooms(),
    api.getEmployees(),
    api.getRestaurantTables(),
  ]);
  return {
    'rooms': results[0].data as List? ?? [],
    'employees': results[1].data as List? ?? [],
    'tables': results[2].data as List? ?? [],
  };
}

class _CreateOrderForm extends StatefulWidget {
  final List<dynamic> rooms;
  final List<dynamic> tables;
  final List<dynamic> employees;
  final List<FoodItem> foodItems;
  final int? defaultRoomId;
  final int? defaultTableId;
  final VoidCallback onCreated;

  const _CreateOrderForm({
    required this.rooms,
    required this.tables,
    required this.employees,
    required this.foodItems,
    this.defaultRoomId,
    this.defaultTableId,
    required this.onCreated,
  });

  @override
  State<_CreateOrderForm> createState() => _CreateOrderFormState();
}

class _CreateOrderFormState extends State<_CreateOrderForm> {
  int? selectedRoomId;
  int? selectedTableId;
  int? selectedEmployeeId;
  String orderType = 'dine_in';
  List<Map<String, dynamic>> selectedItems = [];

  @override
  void initState() {
    super.initState();
    if (widget.defaultTableId != null) {
      orderType = 'dine_in';
      final tableExists = widget.tables.any((t) => t['id'] == widget.defaultTableId);
      selectedTableId = tableExists ? widget.defaultTableId : null;
    } else if (widget.defaultRoomId != null) {
      orderType = 'room_service';
      final roomExists = widget.rooms.any((r) => r['id'] == widget.defaultRoomId);
      selectedRoomId = roomExists ? widget.defaultRoomId : null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Center(child: Container(width: 40, height: 4, margin: const EdgeInsets.only(bottom: 24), decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(2)))),
          const Text("CREATE FOOD ORDER", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 1.5)),
          const SizedBox(height: 32),
          Expanded(
            child: ListView(
              children: [
                _buildGlassPicker("ORDER TYPE", orderType, const [DropdownMenuItem(value: 'dine_in', child: Text("DINE IN")), DropdownMenuItem(value: 'room_service', child: Text("ROOM SERVICE"))], (v) => setState(() { orderType = v!; selectedTableId = null; selectedRoomId = null; })),
                const SizedBox(height: 16),
                if (orderType == 'dine_in') ...[
                  _buildGlassPicker("TARGET TABLE (OPTIONAL)", selectedTableId, widget.tables.map((t) => DropdownMenuItem<int>(value: t['id'], child: Text("TABLE ${t['table_number'] ?? t['id']}"))).toList(), (v) => setState(() => selectedTableId = v), allowClear: true),
                  const SizedBox(height: 16),
                ] else ...[
                  _buildGlassPicker("TARGET ROOM (OPTIONAL)", selectedRoomId, widget.rooms.where((r) {
                    final status = (r['status'] ?? '').toString().toLowerCase();
                    return status == 'checked-in' || status == 'checked_in' || status == 'occupied';
                  }).map((r) => DropdownMenuItem<int>(value: r['id'], child: Text("ROOM ${r['number'] ?? r['room_number'] ?? r['id']}"))).toList(), (v) => setState(() => selectedRoomId = v), allowClear: true),
                  const SizedBox(height: 16),
                ],
                _buildGlassPicker("ASSIGN WAITER", selectedEmployeeId, widget.employees.map((e) => DropdownMenuItem<int>(value: e['id'], child: Text(e['name'].toString().toUpperCase()))).toList(), (v) => setState(() => selectedEmployeeId = v)),
                const SizedBox(height: 32),
                Text("SELECT ITEMS", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 10, color: Colors.white.withOpacity(0.3), letterSpacing: 1)),
                const SizedBox(height: 16),
                ...widget.foodItems.map((item) {
                  final existing = selectedItems.indexWhere((i) => i['food_item_id'] == item.id);
                  final isSelected = existing != -1;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(color: isSelected ? AppColors.accent.withOpacity(0.05) : Colors.white.withOpacity(0.02), borderRadius: BorderRadius.circular(16), border: Border.all(color: isSelected ? AppColors.accent.withOpacity(0.3) : Colors.transparent)),
                    child: CheckboxListTile(
                      title: Text(item.name.toUpperCase(), style: TextStyle(color: isSelected ? Colors.white : Colors.white60, fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 0.5)),
                      subtitle: Text("₹${item.price}", style: TextStyle(color: isSelected ? AppColors.accent : Colors.white24, fontWeight: FontWeight.bold, fontSize: 11)),
                      value: isSelected,
                      activeColor: AppColors.accent,
                      checkColor: AppColors.onyx,
                      onChanged: (val) => setState(() { if (val == true) selectedItems.add({'food_item_id': item.id, 'quantity': 1, 'price': item.price}); else selectedItems.removeAt(existing); }),
                    ),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity, height: 56,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.accent, foregroundColor: AppColors.onyx, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
              onPressed: () async {
                if (selectedItems.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please select at least one item")));
                  return;
                }
                final data = {
                  if (orderType == 'dine_in' && selectedTableId != null) 'table_id': selectedTableId,
                  if (orderType == 'room_service' && selectedRoomId != null) 'room_id': selectedRoomId,
                  if (selectedEmployeeId != null) 'assigned_employee_id': selectedEmployeeId,
                  'order_type': orderType,
                  'status': 'pending',
                  'items': selectedItems,
                  'amount': selectedItems.fold(0.0, (sum, i) => sum + (i['price'] * i['quantity']))
                };
                try {
                  await context.read<ApiService>().createFoodOrder(data);
                  widget.onCreated();
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error creating order: $e")));
                }
              },
              child: const Text("PLACE ORDER", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassPicker<T>(String label, T? value, List<DropdownMenuItem<T>> items, Function(T?) onChanged, {bool allowClear = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white10)),
      child: DropdownButtonFormField<T>(
        value: value,
        dropdownColor: AppColors.onyx,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        items: [
          if (allowClear) DropdownMenuItem<T>(value: null, child: const Text("NONE", style: TextStyle(color: Colors.white38))),
          ...items
        ],
        onChanged: onChanged,
        decoration: InputDecoration(labelText: label, labelStyle: TextStyle(color: Colors.white.withOpacity(0.2), fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1), border: InputBorder.none),
      ),
    );
  }
}

void showFoodOrderDetailModal(BuildContext context, Map<String, dynamic> order, VoidCallback? onChanged) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
      child: Container(
        decoration: BoxDecoration(color: AppColors.onyx.withOpacity(0.95), borderRadius: const BorderRadius.vertical(top: Radius.circular(32)), border: Border.all(color: Colors.white10)),
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("ORDER #${order['id']}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 1.5)),
                IconButton(icon: const Icon(Icons.close, color: Colors.white38), onPressed: () => Navigator.pop(ctx)),
              ],
            ),
            const SizedBox(height: 24),
            Expanded(
              child: ListView(
                children: [
                  _buildGlassDetailRow("DESTINATION", (order['room_number'] != null || order['number'] != null || order['room_id'] != null ? "ROOM ${order['room_number'] ?? order['number'] ?? order['room_id']}" : "TABLE ${order['table_number'] ?? 'N/A'}").toUpperCase(), Colors.white),
                  _buildGlassDetailRow("ORDER TYPE", (order['order_type']?.toString() ?? "N/A").toUpperCase(), AppColors.accent),
                  _buildGlassDetailRow("STATUS", (order['status']?.toString() ?? "PENDING").toUpperCase(), _getStatusColor(order['status'])),
                  _buildGlassDetailRow("TOTAL BILL", "₹${order['total_with_gst'] ?? order['amount']}", Colors.greenAccent),
                  _buildGlassDetailRow("WAITER", (order['employee_name'] ?? order['waiter_name'] ?? "UNASSIGNED").toUpperCase(), (order['employee_name'] ?? order['waiter_name']) == null ? AppColors.accent : Colors.white70),
                  if (order['delivery_instructions'] != null)
                     _buildGlassDetailRow("NOTES", order['delivery_instructions'].toString().toUpperCase(), Colors.white38),
                  const SizedBox(height: 32),
                  Text("ITEMS ORDERED", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 10, color: Colors.white.withOpacity(0.3), letterSpacing: 1)),
                  const SizedBox(height: 16),
                  ...(order['items'] as List? ?? []).map((item) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: OnyxGlassCard(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Row(
                        children: [
                          Text("${item['quantity']}X", style: const TextStyle(color: AppColors.accent, fontWeight: FontWeight.w900, fontSize: 14)),
                          const SizedBox(width: 16),
                          Expanded(child: Text(item['food_item_name']?.toString().toUpperCase() ?? 'UNKNOWN ITEM', style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.white, fontSize: 12, letterSpacing: 0.5))),
                          Text("₹${item['subtotal'] ?? item['price'] ?? 'N/A'}", style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.white70, fontSize: 13)),
                        ],
                      ),
                    ),
                  )),
                ],
              ),
            ),
            const SizedBox(height: 24),
            if (order['status'] != 'completed' && order['status'] != 'cancelled')
              SizedBox(
                width: double.infinity, height: 56,
                child: ElevatedButton(
                  onPressed: () {
                     Navigator.pop(ctx);
                     _showCompletionModal(context, order, onChanged);
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.greenAccent, foregroundColor: AppColors.onyx, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                  child: const Text("COMPLETE & SETTLE", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1)),
                ),
              ),
          ],
        ),
      ),
    ),
  );
}

Widget _buildGlassDetailRow(String label, String value, Color color) {
  return Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    decoration: BoxDecoration(color: Colors.white.withOpacity(0.03), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withOpacity(0.05))),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 9, color: Colors.white.withOpacity(0.2), fontWeight: FontWeight.w900, letterSpacing: 1)),
        Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: color)),
      ],
    ),
  );
}

Color _getStatusColor(String? status) {
  if (status == null) return AppColors.accent;
  switch (status.toLowerCase()) {
    case 'completed': return Colors.greenAccent;
    case 'in progress': return Colors.blueAccent;
    case 'cancelled': return Colors.redAccent;
    case 'pending': return Colors.orangeAccent;
    case 'requested': return Colors.purpleAccent;
    default: return AppColors.accent;
  }
}

void _showCompletionModal(BuildContext context, Map<String, dynamic> order, VoidCallback? onChanged) {
  String paymentStatus = 'unpaid';
  String paymentMethod = 'Cash'; // Default
  final paymentMethods = ['Cash', 'Card', 'UPI', 'Bank Transfer'];

  int? chosenRoomId;
  List<dynamic> activeRooms = [];
  bool loadingRooms = false;

  showDialog(
    context: context,
    builder: (ctx) => BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      child: StatefulBuilder(
        builder: (context, setModalState) {
          if (paymentStatus == 'unpaid' && order['room_id'] == null && activeRooms.isEmpty && !loadingRooms) {
            loadingRooms = true;
            WidgetsBinding.instance.addPostFrameCallback((_) async {
              try {
                final api = context.read<ApiService>();
                final resp = await api.getRooms(queryParameters: {'status': 'Checked-in'});
                final rooms = resp.data as List? ?? [];
                setModalState(() {
                  activeRooms = rooms.where((r) {
                    final status = (r['status'] ?? '').toString().toLowerCase();
                    return status == 'checked-in' || status == 'checked_in' || status == 'occupied';
                  }).toList();
                  loadingRooms = false;
                });
              } catch (e) {
                setModalState(() { loadingRooms = false; });
              }
            });
          }

          return AlertDialog(
            backgroundColor: AppColors.onyx,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24), side: const BorderSide(color: Colors.white10)),
            title: const Text("COMPLETE ORDER", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("SELECT FINAL SETTLEMENT STATUS:", style: TextStyle(color: Colors.white38, fontSize: 11, fontWeight: FontWeight.bold)),
                const SizedBox(height: 24),
                _buildSettlementTile("UNPAID", 'unpaid', paymentStatus, (v) => setModalState(() => paymentStatus = v)),
                _buildSettlementTile("PAID", 'paid', paymentStatus, (v) => setModalState(() => paymentStatus = v)),
                
                if (paymentStatus == 'paid') ...[
                  const SizedBox(height: 24),
                  const Text("PAYMENT MODE:", style: TextStyle(color: Colors.white38, fontSize: 11, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: paymentMethod,
                        dropdownColor: AppColors.onyx,
                        isExpanded: true,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                        items: paymentMethods.map((m) => DropdownMenuItem(value: m, child: Text(m.toUpperCase()))).toList(),
                        onChanged: (v) => setModalState(() => paymentMethod = v!),
                      ),
                    ),
                  ),
                ] else if (paymentStatus == 'unpaid' && order['room_id'] == null) ...[
                  const SizedBox(height: 24),
                  const Text("CHARGE TO GUEST ROOM:", style: TextStyle(color: Colors.white38, fontSize: 11, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
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
                          value: chosenRoomId,
                          dropdownColor: AppColors.onyx,
                          isExpanded: true,
                          hint: const Text("SELECT GUEST ROOM", style: TextStyle(color: Colors.white24, fontSize: 12)),
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                          items: activeRooms.map((r) => DropdownMenuItem<int>(value: r['id'], child: Text("ROOM ${r['number'] ?? r['room_number']}"))).toList(),
                          onChanged: (v) => setModalState(() => chosenRoomId = v),
                        ),
                      ),
                    ),
                ],
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("CANCEL", style: TextStyle(color: Colors.white24, fontWeight: FontWeight.bold))),
              TextButton(
                onPressed: () async {
                  if (paymentStatus == 'unpaid' && order['room_id'] == null && chosenRoomId == null) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("PLEASE SELECT A ROOM TO CHARGE"), backgroundColor: Colors.orangeAccent));
                    return;
                  }

                  try {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("PROCESSING SETTLEMENT..."), duration: Duration(milliseconds: 500)));
                    
                    final Map<String, dynamic> updateData = {
                      'status': 'completed',
                      'billing_status': paymentStatus,
                    };
                    
                    if (paymentStatus == 'paid') {
                      updateData['payment_method'] = paymentMethod;
                    } else if (paymentStatus == 'unpaid' && chosenRoomId != null) {
                      updateData['room_id'] = chosenRoomId;
                    }
                    
                    await context.read<ApiService>().updateFoodOrder(order['id'], updateData);
                    
                    if (context.mounted) {
                       Navigator.pop(ctx);
                       if (onChanged != null) onChanged();
                       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("ORDER COMPLETED SUCCESSFULLY"), backgroundColor: Colors.green));
                    }
                  } catch (e) {
                    print("Error completing order: $e");
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("ERROR COMPLETING ORDER: $e"), backgroundColor: Colors.red));
                    }
                  }
                },
                child: const Text("CONFIRM", style: TextStyle(color: AppColors.accent, fontWeight: FontWeight.w900)),
              ),
            ],
          );
        },
      ),
    ),
  );
}

Widget _buildSettlementTile(String label, String value, String current, Function(String) onSelect) {
   final isSelected = value == current;
   return Container(
     margin: const EdgeInsets.only(bottom: 8),
     decoration: BoxDecoration(color: isSelected ? AppColors.accent.withOpacity(0.1) : Colors.white.withOpacity(0.03), borderRadius: BorderRadius.circular(12), border: Border.all(color: isSelected ? AppColors.accent.withOpacity(0.3) : Colors.transparent)),
     child: ListTile(
       title: Text(label, style: TextStyle(color: isSelected ? AppColors.accent : Colors.white60, fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1)),
       leading: Radio<String>(
         value: value, 
         groupValue: current, 
         activeColor: AppColors.accent,
         onChanged: (v) => onSelect(v!),
       ),
     ),
   );
}
