import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:orchid_employee/core/constants/app_colors.dart';
import 'package:orchid_employee/presentation/providers/service_request_provider.dart';
import 'package:orchid_employee/presentation/providers/auth_provider.dart';
import 'package:orchid_employee/presentation/providers/inventory_provider.dart';
import 'package:orchid_employee/presentation/widgets/onyx_glass_card.dart';
import 'package:orchid_employee/presentation/widgets/onyx_glass_dialog.dart';
import 'package:orchid_employee/data/models/service_request_model.dart';
import 'package:orchid_employee/presentation/screens/housekeeping/checkout_verification_dialog.dart';

class WaiterServiceScreen extends StatefulWidget {
  final bool hideHeader;
  const WaiterServiceScreen({super.key, this.hideHeader = false});

  @override
  State<WaiterServiceScreen> createState() => _WaiterServiceScreenState();
}

class _WaiterServiceScreenState extends State<WaiterServiceScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ServiceRequestProvider>().fetchRequests();
      context.read<InventoryProvider>().fetchLocations();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final requestProvider = context.watch<ServiceRequestProvider>();
    final employeeId = authProvider.employeeId;
    final userRole = authProvider.role;

    print("[DEBUG-SERVICE] EmployeeID: $employeeId, Role: $userRole");
    print("[DEBUG-SERVICE] Total requests in provider: ${requestProvider.requests.length}");

    // Filter requests
    List<ServiceRequest> myRequests;
    if (userRole == UserRole.manager) {
      // Managers see everything
      myRequests = List.from(requestProvider.requests);
    } else {
      // Staff see only assigned
      // Use toString() comparison to avoid int/string mismatch issues
      myRequests = requestProvider.requests.where((r) {
        final match = r.employeeId?.toString() == employeeId?.toString();
        return match;
      }).toList();
    }
    
    print("[DEBUG-SERVICE] Filtered requests count: ${myRequests.length}");

    // Sort by creation date (newest first)
    myRequests.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return Scaffold(
      backgroundColor: AppColors.onyx,
      body: CustomScrollView(
        slivers: [
          // Header
          if (!widget.hideHeader)
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
                decoration: const BoxDecoration(
                  color: AppColors.onyx,
                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "ASSIGNED",
                      style: TextStyle(color: AppColors.accent, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2),
                    ),
                    Text(
                      "MY SERVICES",
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 0.5),
                    ),
                  ],
                ),
              ),
            ),

          // Requests List
          if (requestProvider.isLoading && myRequests.isEmpty)
            const SliverFillRemaining(child: Center(child: CircularProgressIndicator(color: AppColors.accent)))
          else if (myRequests.isEmpty)
            const SliverFillRemaining(
              child: Center(
                child: Text(
                  "NO SERVICES ASSIGNED",
                  style: TextStyle(color: Colors.white24, fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final request = myRequests[index];
                    return _ServiceRequestItem(request: request);
                  },
                  childCount: myRequests.length,
                ),
              ),
            ),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }
}

class _ServiceRequestItem extends StatelessWidget {
  final ServiceRequest request;
  const _ServiceRequestItem({required this.request});

  @override
  Widget build(BuildContext context) {
    final DateFormat formatter = DateFormat('dd/M/yyyy, hh:mm:ss a');
    final createdAtStr = formatter.format(request.createdAt);
    final completedAtStr = request.completedAt != null ? formatter.format(request.completedAt!) : '-';
    
    final statusColor = _getStatusColor(request.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: OnyxGlassCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.room_service_rounded, color: AppColors.accent, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "ROOM ${request.roomNumber} - ${(request.type).toUpperCase()}",
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13),
                      ),
                      if (request.description.isNotEmpty)
                        Text(
                          request.description,
                          style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 10, fontWeight: FontWeight.bold),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
                _StatusBadge(status: request.status, color: statusColor),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(color: Colors.white10, height: 1),
            const SizedBox(height: 12),
            Row(
              children: [
                _TimeDetail(label: "CREATED AT", value: createdAtStr),
                const Spacer(),
                _TimeDetail(label: "COMPLETED AT", value: completedAtStr),
              ],
            ),
            if (request.status.toLowerCase() != 'completed') ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _updateStatus(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: request.status.toLowerCase() == 'pending' ? AppColors.accent : AppColors.success,
                    foregroundColor: AppColors.onyx,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    request.status.toLowerCase() == 'pending' ? "START SERVICE" : "COMPLETE SERVICE",
                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orangeAccent;
      case 'in_progress':
      case 'started':
        return Colors.blueAccent;
      case 'completed':
        return Colors.greenAccent;
      default:
        return Colors.white24;
    }
  }

  Future<void> _executeStatusUpdate(BuildContext context, String nextStatus, {
    String? billingStatus, 
    String? paymentMode,
    List<Map<String, dynamic>>? inventoryReturns,
    int? returnLocationId,
  }) async {
    final success = await context.read<ServiceRequestProvider>().updateRequestStatus(
      request.id, 
      nextStatus,
      employeeId: context.read<AuthProvider>().employeeId,
      billingStatus: billingStatus,
      paymentMode: paymentMode,
      inventoryReturns: inventoryReturns,
      returnLocationId: returnLocationId,
    );

    if (success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("SERVICE ${nextStatus.toUpperCase()} SUCCESSFUL"),
          backgroundColor: nextStatus == 'completed' ? Colors.green : Colors.blue,
        ),
      );
    }
  }

  void _updateStatus(BuildContext context) async {
    final nextStatus = request.status.toLowerCase() == 'pending' ? 'in_progress' : 'completed';
    String? billingStatus;
    String? paymentMode;
    List<Map<String, dynamic>>? inventoryReturns;
    int? returnLocationId;

    if (nextStatus == 'completed') {
      if (request.type.toLowerCase() == 'checkout_verification' || request.type.toLowerCase() == 'checkout') {
         showDialog(
           context: context,
           builder: (_) => CheckoutVerificationDialog(
             roomNumber: request.roomNumber,
             onSuccess: () => _executeStatusUpdate(context, nextStatus),
           )
         );
         return;
      }

      // 1. Check for Return Verification (Inventory items used)
      final items = request.inventoryItemsUsed;
      if (items.isNotEmpty) {
          final invProvider = context.read<InventoryProvider>();
          final locations = invProvider.locations;
          int? selectedLocId;
          final Map<int, TextEditingController> qtyControllers = {};
          for (var item in items) {
             qtyControllers[item['id']] = TextEditingController(); 
          }

          final proceed = await showDialog<bool>(
            context: context,
            barrierDismissible: false,
            builder: (ctx) => StatefulBuilder(
              builder: (context, setDialogState) => OnyxGlassDialog(
                title: "RETURN VERIFICATION",
                children: [
                  const Text(
                    "RECORD ANY ITEMS BEING RETURNED FROM THE ROOM.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white24, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1),
                  ),
                  const SizedBox(height: 24),
                  _buildGlassDropdown<int?>(
                    label: "RETURN REPOSITORY",
                    value: selectedLocId,
                    items: [
                      const DropdownMenuItem<int?>(value: null, child: Text("ALL CONSUMED / NO RETURNS", style: TextStyle(color: Colors.white24, fontSize: 11, fontWeight: FontWeight.bold))),
                      ...locations.map((l) => DropdownMenuItem<int?>(
                        value: l['id'], 
                        child: Text(((l['name'] ?? 'LOCATION').toString()).toUpperCase(), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold))
                      ))
                    ],
                    onChanged: (v) => setDialogState(() => selectedLocId = v),
                  ),
                  const SizedBox(height: 24),
                  const Text("ASSIGNED ITEMS SUMMARY", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 9, color: AppColors.accent, letterSpacing: 2)),
                  const SizedBox(height: 12),
                  ...items.map((item) {
                      final itemName = (item['name'] ?? 'ITEM').toString().toUpperCase();
                      final itemUnit = (item['unit'] ?? '').toString().toUpperCase();
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: Colors.white.withOpacity(0.03), borderRadius: BorderRadius.circular(16)),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(itemName, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: Colors.white)),
                                  Text("ISSUED: ${item['quantity'] ?? 1} $itemUnit", style: TextStyle(fontSize: 9, color: Colors.white.withOpacity(0.3), fontWeight: FontWeight.bold)),
                                ],
                              )
                            ),
                            const SizedBox(width: 10),
                            if (selectedLocId != null)
                              Expanded(
                                flex: 1,
                                child: _buildGlassInput(qtyControllers[item['id']]!, "RTN QTY", Icons.assignment_return_outlined, type: TextInputType.number),
                              )
                            else 
                              const Text("CONSUMED", style: TextStyle(fontSize: 9, color: Colors.white24, fontWeight: FontWeight.w900, letterSpacing: 1)),
                          ],
                        ),
                      );
                  }),
                ],
                actions: [
                  TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("CANCEL", style: TextStyle(color: Colors.white24, fontWeight: FontWeight.w900, letterSpacing: 1))),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(ctx, true), 
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.accent, foregroundColor: AppColors.onyx),
                    child: const Text("VERIFY & CONTINUE", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 0.5))
                  ),
                ],
              )
            )
          );

          if (proceed != true) return;
          
          returnLocationId = selectedLocId;
          if (selectedLocId != null) {
              inventoryReturns = [];
              for (var item in items) {
                  final text = qtyControllers[item['id']]?.text;
                  if (text != null && text.isNotEmpty) {
                      final val = double.tryParse(text);
                      if (val != null && val > 0) {
                          final parsedReqId = int.tryParse(request.id);
                          inventoryReturns!.add({
                              "inventory_item_id": item['id'],
                              "quantity_returned": val,
                              "assignment_id": (parsedReqId != null && parsedReqId > 2000000) ? parsedReqId - 2000000 : null
                          });
                      }
                  }
              }
          }
      }

      // 2. Settlement Check
      final isFoodRequest = (request.foodItems.isNotEmpty || request.foodOrderTotal > 0) && request.billingStatus.toLowerCase() != 'paid';
      if (isFoodRequest) {
        final result = await showDialog<Map<String, String>>(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            backgroundColor: AppColors.onyx,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: const BorderSide(color: Colors.white10)),
            title: const Text("FINALIZE SERVICE", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16)),
            content: const Text("How would you like to settle this service?", style: TextStyle(color: Colors.white60, fontSize: 13)),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, {'status': 'unpaid'}),
                child: const Text("UNPAID", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
              ),
              ElevatedButton(
                onPressed: () async {
                  final mode = await showDialog<String>(
                    context: ctx,
                    builder: (pctx) => SimpleDialog(
                      backgroundColor: AppColors.onyx,
                      title: const Text("SELECT PAYMENT MODE", style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                      children: [
                        SimpleDialogOption(onPressed: () => Navigator.pop(pctx, 'Cash'), child: const Text("CASH", style: TextStyle(color: Colors.white))),
                        SimpleDialogOption(onPressed: () => Navigator.pop(pctx, 'Card'), child: const Text("CARD", style: TextStyle(color: Colors.white))),
                        SimpleDialogOption(onPressed: () => Navigator.pop(pctx, 'UPI'), child: const Text("UPI", style: TextStyle(color: Colors.white))),
                      ],
                    ),
                  );
                  if (mode != null && ctx.mounted) {
                    Navigator.pop(ctx, {'status': 'paid', 'mode': mode});
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.success, foregroundColor: AppColors.onyx),
                child: const Text("PAID", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        );

        if (result == null) return;
        billingStatus = result['status'];
        paymentMode = result['mode'];
      }
    }

    if (!context.mounted) return;
    await _executeStatusUpdate(context, nextStatus, 
      billingStatus: billingStatus, 
      paymentMode: paymentMode,
      inventoryReturns: inventoryReturns,
      returnLocationId: returnLocationId,
    );
  }

  // --- Glass UI Helpers ---

  Widget _buildGlassInput(TextEditingController controller, String label, IconData icon, {TextInputType type = TextInputType.text}) {
    return Container(
      height: 45,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: Colors.white24),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: type,
              style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                hintText: label,
                hintStyle: const TextStyle(color: Colors.white10, fontSize: 10, fontWeight: FontWeight.w900),
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassDropdown<T>({required String label, required T? value, required List<DropdownMenuItem<T>> items, required Function(T?) onChanged}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.white24, fontSize: 8, fontWeight: FontWeight.w900, letterSpacing: 1)),
          DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: value,
              isExpanded: true,
              dropdownColor: AppColors.onyx,
              items: items,
              onChanged: onChanged,
              icon: const Icon(Icons.arrow_drop_down, color: Colors.white24),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  final Color color;
  const _StatusBadge({required this.status, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.toUpperCase().replaceAll('_', ' '),
        style: TextStyle(color: color, fontSize: 8, fontWeight: FontWeight.w900, letterSpacing: 0.5),
      ),
    );
  }
}

class _TimeDetail extends StatelessWidget {
  final String label;
  final String value;
  const _TimeDetail({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.white.withOpacity(0.2), fontSize: 8, fontWeight: FontWeight.w900, letterSpacing: 1),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(color: Colors.white60, fontSize: 9, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
