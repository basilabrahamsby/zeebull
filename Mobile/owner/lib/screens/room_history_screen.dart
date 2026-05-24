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
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8FAFC),
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF064E3B), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Room ${currentRoom.roomNumber}',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Color(0xFF064E3B),
            letterSpacing: -0.5,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: TabBar(
                controller: _tabController,
                isScrollable: true,
                indicator: BoxDecoration(
                  color: const Color(0xFF064E3B).withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF064E3B).withOpacity(0.2),
                    width: 1,
                  ),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                labelColor: const Color(0xFF064E3B),
                unselectedLabelColor: const Color(0xFF64748B),
                labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                dividerColor: Colors.transparent,
                tabs: const [
                  Tab(text: "Overview"),
                  Tab(text: "History"),
                  Tab(text: "Issues"),
                ],
              ),
            ),
          ),
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
          label: const Text('Report Issue', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.1)),
          icon: const Icon(Icons.report_problem_rounded, size: 20),
          backgroundColor: const Color(0xFF064E3B),
          foregroundColor: Colors.white,
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFF1F5F9), width: 1.2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.015),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Status',
                        style: TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            room.status == 'Available' ? Icons.check_circle_rounded : Icons.person_rounded,
                            color: room.status == 'Available' ? const Color(0xFF10B981) : const Color(0xFF3B82F6),
                            size: 22,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            room.status,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        'Housekeeping',
                        style: TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Switch(
                        value: !isDirty, 
                        activeColor: const Color(0xFF10B981),
                        activeTrackColor: const Color(0xFFD1FAE5),
                        inactiveThumbColor: const Color(0xFFF59E0B),
                        inactiveTrackColor: const Color(0xFFFEF3C7),
                        onChanged: (val) {
                          _updateStatus(housekeeping: val ? 'Clean' : 'Dirty');
                        },
                      ),
                      Text(
                        room.housekeepingStatus,
                        style: TextStyle(
                          color: isDirty ? const Color(0xFFD97706) : const Color(0xFF059669),
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 24),
        
        // Quick Actions
        const Text(
          "Quick Actions",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: Color(0xFF064E3B),
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 2.2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          children: [
            _buildActionButton(Icons.cleaning_services_rounded, "Clean Room", const Color(0xFF059669), () {
              _updateStatus(housekeeping: 'Clean');
            }),
            _buildActionButton(Icons.build_rounded, "Maintenance", const Color(0xFFD97706), () {
              _updateStatus(status: 'Maintenance');
            }),
            _buildActionButton(Icons.check_circle_outline_rounded, "Release Room", const Color(0xFF0284C7), () {
              _updateStatus(status: 'Available');
            }),
            _buildActionButton(Icons.block_rounded, "Block Room", const Color(0xFFDC2626), () {
              _updateStatus(status: 'Blocked');
            }),
          ],
        ),
        
        const SizedBox(height: 24),
        
        // Features
        const Text(
          "Features",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: Color(0xFF064E3B),
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            if (room.wifi) _buildFeatureChip("WiFi", Icons.wifi_rounded),
            if (room.airConditioning) _buildFeatureChip("AC", Icons.ac_unit_rounded),
            if (room.tv) _buildFeatureChip("TV", Icons.tv_rounded),
          ],
        )
      ],
    );
  }
  
  Widget _buildActionButton(IconData icon, String label, Color accentColor, VoidCallback onTap) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.01),
            blurRadius: 8,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.08),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 20, color: accentColor),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureChip(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF064E3B).withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF064E3B).withOpacity(0.12), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: const Color(0xFF064E3B)),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Color(0xFF064E3B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryTab() {
    if (_isLoadingHistory) return const Center(child: CircularProgressIndicator(color: Color(0xFF064E3B)));
    if (_history.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history_rounded, size: 60, color: Colors.grey[300]),
            const SizedBox(height: 16),
            const Text("No booking history found", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _history.length,
      itemBuilder: (context, index) {
        final booking = _history[index];
        final isCheckedIn = booking.status == 'Checked-in';
        final statusColor = isCheckedIn ? const Color(0xFF059669) : const Color(0xFF64748B);
        final statusBg = isCheckedIn ? const Color(0xFFD1FAE5) : const Color(0xFFF1F5F9);

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFF1F5F9), width: 1.2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.01),
                blurRadius: 8,
                offset: const Offset(0, 3),
              )
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context, 
                  MaterialPageRoute(builder: (_) => BookingDetailScreen(bookingId: booking.id, isPackage: booking.isPackage))
                );
              },
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            booking.guestName,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(Icons.calendar_month_rounded, size: 14, color: Color(0xFF94A3B8)),
                              const SizedBox(width: 6),
                              Text(
                                "${booking.checkInDate} - ${booking.checkOutDate}",
                                style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: statusBg,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        booking.status,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildIssuesTab() {
     return FutureBuilder<List<ServiceRequest>>(
        future: Provider.of<ServiceProvider>(context, listen: false).fetchRoomRequests(widget.room.id),
        builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
               return const Center(child: CircularProgressIndicator(color: Color(0xFF064E3B)));
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
               return Center(
                 child: Column(
                   mainAxisAlignment: MainAxisAlignment.center,
                   children: [
                     Icon(Icons.check_circle_outline_rounded, size: 60, color: const Color(0xFF059669).withOpacity(0.2)),
                     const SizedBox(height: 16),
                     const Text("No active issues", style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.bold)),
                   ],
                 ),
               );
            }
            final issues = snapshot.data!;
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: issues.length,
              itemBuilder: (context, index) {
                 final issue = issues[index];
                 final isPending = issue.status == 'pending';
                 final statusColor = isPending ? const Color(0xFFD97706) : const Color(0xFF059669);
                 final statusBg = isPending ? const Color(0xFFFEF3C7) : const Color(0xFFD1FAE5);

                 return Container(
                   margin: const EdgeInsets.only(bottom: 12),
                   decoration: BoxDecoration(
                     color: Colors.white,
                     borderRadius: BorderRadius.circular(16),
                     border: Border.all(color: const Color(0xFFF1F5F9), width: 1.2),
                     boxShadow: [
                       BoxShadow(
                         color: Colors.black.withOpacity(0.01),
                         blurRadius: 8,
                         offset: const Offset(0, 3),
                       )
                     ],
                   ),
                   child: Material(
                     color: Colors.transparent,
                     child: InkWell(
                       onTap: () => _showIssueDetails(issue),
                       borderRadius: BorderRadius.circular(16),
                       child: Padding(
                         padding: const EdgeInsets.all(16),
                         child: Row(
                           children: [
                             Container(
                               padding: const EdgeInsets.all(10),
                               decoration: BoxDecoration(
                                 color: statusBg,
                                 shape: BoxShape.circle,
                               ),
                               child: Icon(
                                 isPending ? Icons.warning_amber_rounded : Icons.check_circle_outline_rounded, 
                                 color: statusColor,
                                 size: 20,
                               ),
                             ),
                             const SizedBox(width: 14),
                             Expanded(
                               child: Column(
                                 crossAxisAlignment: CrossAxisAlignment.start,
                                 children: [
                                   Text(
                                     issue.description.split('|')[0],
                                     style: const TextStyle(
                                       fontSize: 14,
                                       fontWeight: FontWeight.bold,
                                       color: Color(0xFF1E293B),
                                     ),
                                   ),
                                   const SizedBox(height: 6),
                                   Text(
                                     "${issue.requestType.toUpperCase()} • ${issue.status.toUpperCase()}",
                                     style: TextStyle(
                                       fontSize: 11, 
                                       color: statusColor, 
                                       fontWeight: FontWeight.bold,
                                       letterSpacing: 0.3,
                                     ),
                                   ),
                                 ],
                               ),
                             ),
                             Text(
                               issue.createdAt.split('T')[0], 
                               style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8), fontWeight: FontWeight.bold),
                             ),
                           ],
                         ),
                       ),
                     ),
                   ),
                 );
              },
            );
        }
     );
  }

  void _showAddIssueDialog() {
     final descController = TextEditingController();
     showDialog(
       context: context, 
       builder: (context) => AlertDialog(
         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
         title: const Text(
           "Report Room Issue",
           style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF064E3B)),
         ),
         content: Column(
           mainAxisSize: MainAxisSize.min,
           children: [
              TextField(
                controller: descController,
                decoration: InputDecoration(
                   labelText: "Description",
                   hintText: "e.g. AC leaking, TV remote missing",
                   labelStyle: const TextStyle(color: Color(0xFF064E3B)),
                   focusedBorder: OutlineInputBorder(
                     borderRadius: BorderRadius.circular(12),
                     borderSide: const BorderSide(color: Color(0xFF064E3B), width: 1.5),
                   ),
                   enabledBorder: OutlineInputBorder(
                     borderRadius: BorderRadius.circular(12),
                     borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1.2),
                   ),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              const Text("This will create a maintenance request.", style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
           ],
         ),
         actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), 
              child: const Text("Cancel", style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.bold)),
            ),
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
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF064E3B),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text("Report", style: TextStyle(fontWeight: FontWeight.bold)),
            )
         ],
       ),
     );
  }

  void _showIssueDetails(ServiceRequest issue) {
      showDialog(
        context: context, 
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text(
            "Issue Details",
            style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF064E3B)),
          ),
          content: Column(
             mainAxisSize: MainAxisSize.min,
             crossAxisAlignment: CrossAxisAlignment.start,
             children: [
                Text(
                  issue.description, 
                  style: const TextStyle(fontSize: 15, color: Color(0xFF1E293B), fontWeight: FontWeight.w600, height: 1.4),
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 8),
                _buildDetailRow("Type", issue.requestType.toUpperCase()),
                const SizedBox(height: 6),
                _buildDetailRow("Status", issue.status.toUpperCase()),
                const SizedBox(height: 6),
                _buildDetailRow("Date", issue.createdAt.split('T')[0]),
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
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF059669),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text("Mark Resolved", style: TextStyle(fontWeight: FontWeight.bold)),
                 ),
              TextButton(
                onPressed: () => Navigator.pop(context), 
                child: const Text("Close", style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.bold)),
              ),
          ],
        ),
      );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w500)),
        Text(value, style: const TextStyle(fontSize: 12, color: Color(0xFF1E293B), fontWeight: FontWeight.bold)),
      ],
    );
  }
}
