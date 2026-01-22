import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/booking_provider.dart';
import '../providers/room_provider.dart';
import '../models/booking.dart';
import '../models/room.dart';
import '../models/service_request.dart';
import '../providers/service_provider.dart';
import 'booking_detail_screen.dart';

class RoomHistoryScreen extends StatefulWidget {
  final Room room;

  const RoomHistoryScreen({super.key, required this.room});

  @override
  State<RoomHistoryScreen> createState() => _RoomHistoryScreenState();
}

class _RoomHistoryScreenState extends State<RoomHistoryScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Booking> _history = [];
  bool _isLoadingHistory = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (mounted) setState(() {});
    });
    _loadHistory();
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadHistory() async {
    final bookings = await Provider.of<BookingProvider>(context, listen: false).fetchRoomHistory(widget.room.id);
    if (mounted) {
      setState(() {
        _history = bookings;
        _isLoadingHistory = false;
      });
    }
  }

  Future<void> _updateStatus({String? status, String? housekeeping}) async {
    final success = await Provider.of<RoomProvider>(context, listen: false)
        .updateRoom(roomId: widget.room.id, status: status, housekeepingStatus: housekeeping);
    
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Room updated successfully')));
      // Navigator pop not needed as Provider refreshes list, but this screen holds 'widget.room'.
      // Issue: 'widget.room' is immutable. We should listen to RoomProvider to get updated room.
      // But for now, we rely on the list update when popping back.
      // Or we can assume success and update local UI if needed, but 'fetchRooms' triggers notifyListeners.
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get latest room data from provider to show updates
    final roomProvider = Provider.of<RoomProvider>(context);
    final currentRoom = roomProvider.rooms.firstWhere((r) => r.id == widget.room.id, orElse: () => widget.room);

    return Scaffold(
      appBar: AppBar(
        title: Text('Room ${currentRoom.roomNumber}'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: "Overview"),
            Tab(text: "History"),
            Tab(text: "Issues"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(currentRoom),
          _buildHistoryTab(),
          _buildIssuesTab(),
        ],
      ),
      floatingActionButton: _buildFab(),
    );
  }

  Widget _buildFab() {
     if (_tabController.index == 2) {
        return FloatingActionButton.extended(
          onPressed: _showAddIssueDialog,
          label: const Text('Report Issue'),
          icon: const Icon(Icons.report_problem),
          backgroundColor: Colors.orange,
        );
     }
     return const SizedBox.shrink(); // Hide for other tabs for now
  }

  Widget _buildOverviewTab(Room room) {
    bool isDirty = room.housekeepingStatus.toLowerCase() == 'dirty';
    
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Status Card
        Card(
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                       const Text('Status', style: TextStyle(color: Colors.grey)),
                       const SizedBox(height: 4),
                       Row(
                         children: [
                           Icon(
                             room.status == 'Available' ? Icons.check_circle : Icons.person,
                             color: room.status == 'Available' ? Colors.green : Colors.blue,
                           ),
                           const SizedBox(width: 8),
                           Text(room.status, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                         ],
                       )
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                       const Text('Housekeeping', style: TextStyle(color: Colors.grey)),
                       const SizedBox(height: 4),
                       Switch(
                         value: !isDirty, 
                         activeColor: Colors.green,
                         inactiveThumbColor: Colors.orange,
                         onChanged: (val) {
                           _updateStatus(housekeeping: val ? 'Clean' : 'Dirty');
                         },
                       ),
                       Text(room.housekeepingStatus, style: TextStyle(
                         color: isDirty ? Colors.orange : Colors.green,
                         fontWeight: FontWeight.bold
                       )),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Quick Actions
        const Text("Quick Actions", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 2.5,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          children: [
            _buildActionButton(Icons.cleaning_services, "Clean Room", () {
              _updateStatus(housekeeping: 'Clean');
            }),
            _buildActionButton(Icons.build, "Maintenance", () {
              _updateStatus(status: 'Maintenance');
            }),
            _buildActionButton(Icons.check_circle_outline, "Release Room", () {
              _updateStatus(status: 'Available');
            }),
             _buildActionButton(Icons.block, "Block Room", () {
              _updateStatus(status: 'Blocked');
            }),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // Features
        const Text("Features", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Wrap(
          spacing: 8,
          children: [
            if (room.wifi) const Chip(label: Text("WiFi"), avatar: Icon(Icons.wifi, size: 16)),
            if (room.airConditioning) const Chip(label: Text("AC"), avatar: Icon(Icons.ac_unit, size: 16)),
            if (room.tv) const Chip(label: Text("TV"), avatar: Icon(Icons.tv, size: 16)),
            // Add more chips
          ],
        )
      ],
    );
  }
  
  Widget _buildActionButton(IconData icon, String label, VoidCallback onTap) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        alignment: Alignment.centerLeft,
      ),
    );
  }

  Widget _buildHistoryTab() {
    if (_isLoadingHistory) return const Center(child: CircularProgressIndicator());
    if (_history.isEmpty) return const Center(child: Text("No history found"));

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _history.length,
      separatorBuilder: (_, __) => const Divider(),
      itemBuilder: (context, index) {
         final booking = _history[index];
         return ListTile(
            title: Text(booking.guestName),
            subtitle: Text("${booking.checkInDate} - ${booking.checkOutDate}"),
            trailing: Chip(
              label: Text(booking.status, style: const TextStyle(fontSize: 10, color: Colors.white)),
              backgroundColor: booking.status == 'Checked-in' ? Colors.green : Colors.grey,
            ),
            onTap: () {
               Navigator.push(
                 context, 
                 MaterialPageRoute(builder: (_) => BookingDetailScreen(bookingId: booking.id, isPackage: booking.isPackage))
               );
            },
         );
      },
    );
  }

  Widget _buildIssuesTab() {
     return FutureBuilder<List<ServiceRequest>>(
        future: Provider.of<ServiceProvider>(context, listen: false).fetchRoomRequests(widget.room.id),
        builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
               return const Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
               return Center(
                 child: Column(
                   mainAxisAlignment: MainAxisAlignment.center,
                   children: [
                     Icon(Icons.check_circle_outline, size: 60, color: Colors.grey[300]),
                     const SizedBox(height: 16),
                     const Text("No active issues", style: TextStyle(color: Colors.grey)),
                   ],
                 ),
               );
            }
            final issues = snapshot.data!;
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: issues.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (context, index) {
                 final issue = issues[index];
                 // Filter for "Issue" type or all? API returns all including refills.
                 // We can distinguish by type.
                 return ListTile(
                   leading: CircleAvatar(
                      backgroundColor: issue.status == 'pending' ? Colors.orange[100] : Colors.green[100],
                      child: Icon(
                        issue.status == 'pending' ? Icons.warning : Icons.check, 
                        color: issue.status == 'pending' ? Colors.orange : Colors.green
                      ),
                   ),
                   title: Text(issue.description.split('|')[0]), // Simple view
                   subtitle: Text("${issue.requestType} • ${issue.status}"),
                   trailing: Text(issue.createdAt.split('T')[0], style: const TextStyle(fontSize: 10, color: Colors.grey)),
                   onTap: () {
                      // View details or update status?
                      _showIssueDetails(issue);
                   },
                 );
              },
            );
        }
     );
  }

  void _showAddIssueDialog() {
     final descController = TextEditingController();
     showDialog(context: context, builder: (context) => AlertDialog(
        title: const Text("Report Room Issue"),
        content: Column(
           mainAxisSize: MainAxisSize.min,
           children: [
              TextField(
                controller: descController,
                decoration: const InputDecoration(
                   labelText: "Description",
                   hintText: "e.g. AC leaking, TV remote missing",
                   border: OutlineInputBorder()
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              const Text("This will create a maintenance request.", style: TextStyle(fontSize: 12, color: Colors.grey)),
           ],
        ),
        actions: [
           TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
           ElevatedButton(
              onPressed: () async {
                 if (descController.text.isNotEmpty) {
                    final success = await Provider.of<ServiceProvider>(context, listen: false).createRequest({
                       "room_id": widget.room.id,
                       "request_type": "maintenance",
                       "description": descController.text,
                       "status": "pending"
                    });
                    if (success && mounted) {
                       Navigator.pop(context);
                       setState(() {}); // Refresh future builder
                       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Issue reported")));
                    }
                 }
              }, 
              child: const Text("Report")
           )
        ],
     ));
  }

  void _showIssueDetails(ServiceRequest issue) {
      // Simple dialog to show full details and allow "Mark Solved"
      showDialog(context: context, builder: (context) => AlertDialog(
         title: const Text("Issue Details"),
         content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
               Text(issue.description),
               const SizedBox(height: 16),
               Text("Type: ${issue.requestType}"),
               Text("Status: ${issue.status}"),
               Text("Date: ${issue.createdAt}"),
            ],
         ),
         actions: [
             if (issue.status != 'completed')
                ElevatedButton(
                   onPressed: () async {
                       await Provider.of<ServiceProvider>(context, listen: false).updateRequestStatus(issue.id, 'completed');
                       if (mounted) {
                           Navigator.pop(context);
                           setState(() {});
                       }
                   },
                   style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                   child: const Text("Mark Resolved"),
                ),
             TextButton(onPressed: () => Navigator.pop(context), child: const Text("Close")),
         ],
      ));
  }
}
