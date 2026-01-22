import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:orchid_employee/data/models/room_model.dart';
import 'package:orchid_employee/core/constants/app_colors.dart';
import 'package:orchid_employee/presentation/providers/room_provider.dart';
import 'package:orchid_employee/presentation/screens/housekeeping/audit_screen.dart';
import 'package:orchid_employee/presentation/screens/housekeeping/damage_report_screen.dart';

class RoomListScreen extends StatefulWidget {
  const RoomListScreen({super.key});

  @override
  State<RoomListScreen> createState() => _RoomListScreenState();
}

class _RoomListScreenState extends State<RoomListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RoomProvider>().fetchRooms();
    });
  }

  @override
  Widget build(BuildContext context) {
    final roomProvider = context.watch<RoomProvider>();
    final rooms = roomProvider.rooms;

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Rooms", style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.primary,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: roomProvider.isLoading 
          ? const Center(child: CircularProgressIndicator())
          : roomProvider.error != null
              ? Center(child: Text(roomProvider.error!))
              : RefreshIndicator(
                  onRefresh: () => roomProvider.fetchRooms(),
                  child: rooms.isEmpty
                      ? const Center(child: Text("No rooms assigned yet."))
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: rooms.length,
                          itemBuilder: (context, index) {
                            final room = rooms[index];
                            return _buildRoomCard(context, room);
                          },
                        ),
                ),
    );
  }

  Widget _buildRoomCard(BuildContext context, Room room) {
    Color statusColor;
    IconData statusIcon;

    final status = room.status.toLowerCase();

    if (status == 'clean') {
      statusColor = Colors.green;
      statusIcon = Icons.check_circle;
    } else if (status == 'dirty') {
      statusColor = Colors.red;
      statusIcon = Icons.cleaning_services;
    } else if (status == 'occupied' || status == 'checked-in') {
      statusColor = Colors.blue;
      statusIcon = Icons.person;
    } else if (status == 'cleaning') {
      statusColor = Colors.orange;
      statusIcon = Icons.hourglass_empty;
    } else if (status.contains('inspection')) {
      statusColor = Colors.orange;
      statusIcon = Icons.fact_check;
    } else {
      statusColor = Colors.grey;
      statusIcon = Icons.help;
    }

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                    Text(
                      "Room ${room.roomNumber}",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      room.type,
                      style: const TextStyle(color: Colors.grey),
                    ),
                    if (room.guestName != null)
                      Text(
                        room.guestName!,
                        style: TextStyle(color: Colors.grey[600], fontSize: 13),
                      ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: statusColor),
                  ),
                  child: Row(
                    children: [
                      Icon(statusIcon, size: 16, color: statusColor),
                      const SizedBox(width: 4),
                      Text(
                        room.status,
                        style: TextStyle(
                            color: statusColor, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                if (status == 'dirty')
                  _ActionButton(
                    icon: Icons.play_arrow,
                    label: "Start",
                    color: AppColors.primary,
                    onTap: () async {
                       final success = await context.read<RoomProvider>().updateRoomStatus(room.id, 'Cleaning');
                       if (success && mounted) {
                         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Started Cleaning Room ${room.roomNumber}")));
                       }
                    },
                  ),
                if (status == 'cleaning')
                  _ActionButton(
                    icon: Icons.check,
                    label: "Mark Clean",
                    color: Colors.green,
                    onTap: () async {
                       final success = await context.read<RoomProvider>().updateRoomStatus(room.id, 'Clean');
                       if (success && mounted) {
                         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Room ${room.roomNumber} marked as Clean")));
                       }
                    },
                  ),
                if (status == 'occupied' || status == 'checked-in' || status == 'dirty' || status == 'cleaning')
                  _ActionButton(
                    icon: Icons.inventory_2,
                    label: "Audit",
                    color: AppColors.secondary,
                    onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => AuditScreen(
                              roomNumber: room.roomNumber,
                              roomId: room.id
                            )
                          )
                        );
                    },
                  ),
                _ActionButton(
                  icon: Icons.report_problem,
                  label: "Damage",
                  color: Colors.red,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => DamageReportScreen(
                          roomNumber: room.roomNumber,
                          roomId: room.id
                        )
                      )
                    );
                  },
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Column(
          children: [
            CircleAvatar(
              backgroundColor: color.withOpacity(0.1),
              radius: 20,
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}
