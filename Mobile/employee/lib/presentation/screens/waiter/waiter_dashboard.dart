import 'package:flutter/material.dart';
import 'package:orchid_employee/core/constants/app_colors.dart';
import 'package:orchid_employee/presentation/screens/waiter/menu_order_screen.dart';
import 'package:orchid_employee/presentation/providers/auth_provider.dart';
import 'package:orchid_employee/presentation/providers/room_provider.dart';
import 'package:orchid_employee/data/models/room_model.dart';
import 'package:orchid_employee/presentation/widgets/onyx_glass_card.dart';
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
      context.read<RoomProvider>().fetchRooms();
      context.read<RoomProvider>().fetchRoomStats();
      context.read<RoomProvider>().fetchRoomTypes();
    });
  }

  @override
  Widget build(BuildContext context) {
    final roomProvider = context.watch<RoomProvider>();
    final rooms = roomProvider.rooms;
    final stats = roomProvider.roomStats;
    
    final available = stats['available']?.toString() ?? "0";
    final occupied = stats['occupied']?.toString() ?? "0";
    final total = rooms.length.toString();

    return Scaffold(
      backgroundColor: AppColors.onyx,
      body: CustomScrollView(
        slivers: [
          // Header Summary
          SliverToBoxAdapter(
            child: Container(
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
          ),

          // Search & Filter
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      style: TextStyle(color: Colors.white, fontSize: 14),
                      decoration: InputDecoration(
                        hintText: "Search table...",
                        hintStyle: TextStyle(color: Colors.white24, fontSize: 14),
                        prefixIcon: Icon(Icons.search_rounded, color: Colors.white24, size: 20),
                        fillColor: Colors.white10,
                        filled: true,
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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

          // Table/Room Grid
          if (roomProvider.isLoading && rooms.isEmpty)
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
                    final room = rooms[index];
                    return _buildRoomCard(room);
                  },
                  childCount: rooms.length,
                ),
              ),
            ),

          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const MenuOrderScreen()),
          );
        },
        backgroundColor: AppColors.accent,
        icon: const Icon(Icons.add),
        label: const Text("New Order"),
      ),
    );
  }

  Widget _buildRoomCard(dynamic room) {
    final bool isOccupied = room.status == 'Booked' || room.status == 'checked_in' || room.status == 'Occupied';
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
                  child: Icon(Icons.meeting_room_rounded, 
                    color: isOccupied ? AppColors.accent : Colors.greenAccent, size: 20),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: (isOccupied ? AppColors.accent : Colors.greenAccent).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(room.status.toUpperCase(), 
                    style: TextStyle(color: isOccupied ? AppColors.accent : Colors.greenAccent, 
                      fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text("TABLE ${room.roomNumber}", 
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16)),
            Text(room.type ?? "Standard", 
              style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 10, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => MenuOrderScreen(tableId: "Table ${room.roomNumber}"))),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.05),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: Text(isOccupied ? "VIEW ORDER" : "NEW ORDER", 
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateTableDialog() {
    final roomProvider = context.read<RoomProvider>();
    final numberController = TextEditingController();
    int? selectedTypeId;

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
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                value: selectedTypeId,
                dropdownColor: AppColors.onyx,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "Select Category",
                  hintStyle: const TextStyle(color: Colors.white24),
                  filled: true,
                  fillColor: Colors.white10,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
                items: roomProvider.roomTypes.map((type) => DropdownMenuItem(
                  value: type.id,
                  child: Text(type.name, style: const TextStyle(color: Colors.white)),
                )).toList(),
                onChanged: (val) => setState(() => selectedTypeId = val),
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
                if (numberController.text.isEmpty || selectedTypeId == null) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please fill all fields")));
                  return;
                }
                final success = await roomProvider.createRoom({
                  "number": numberController.text,
                  "room_type_id": selectedTypeId,
                  "status": "Available",
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
