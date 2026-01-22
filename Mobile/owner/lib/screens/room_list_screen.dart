import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/room_provider.dart';
import '../providers/booking_provider.dart';
import '../models/room.dart';
import '../models/booking.dart';
import 'room_history_screen.dart';
import '../config/constants.dart';

class RoomListScreen extends StatefulWidget {
  const RoomListScreen({super.key});

  @override
  State<RoomListScreen> createState() => _RoomListScreenState();
}

class _RoomListScreenState extends State<RoomListScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    // Tabs: All, Vacant, Occupied, Clean, Dirty, Maintenance
    _tabController = TabController(length: 6, vsync: this);
    Future.microtask(() {
      Provider.of<RoomProvider>(context, listen: false).fetchRooms();
      Provider.of<BookingProvider>(context, listen: false).fetchBookings();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<Room> _filterRooms(List<Room> rooms, int tabIndex, String query) {
    List<Room> filtered = rooms;

    // Filter by Tab
    switch (tabIndex) {
      case 1: // Vacant (Available)
        filtered = rooms.where((r) => r.status.toLowerCase() == 'available').toList();
        break;
      case 2: // Occupied (includes checked-in, occupied, and booked)
        filtered = rooms.where((r) => 
          r.status.toLowerCase() == 'occupied' || 
          r.status.toLowerCase() == 'booked' ||
          r.status.toLowerCase() == 'checked-in' ||
          r.status.toLowerCase().replaceAll(' ', '-') == 'checked-in'
        ).toList();
        break;
      case 3: // Clean
        filtered = rooms.where((r) => r.housekeepingStatus.toLowerCase() == 'clean').toList();
        break;
      case 4: // Dirty
        filtered = rooms.where((r) => r.housekeepingStatus.toLowerCase() == 'dirty').toList();
        break;
      case 5: // Maintenance
         filtered = rooms.where((r) => r.status.toLowerCase() == 'maintenance').toList();
         break;
    }

    // Filter by Search
    if (query.isNotEmpty) {
      filtered = filtered.where((r) => 
        r.roomNumber.toLowerCase().contains(query.toLowerCase())
      ).toList();
    }
    
    return filtered;
  }

  Booking? _findActiveBooking(String roomNumber, List<Booking> bookings) {
    try {
      return bookings.firstWhere((b) => 
        b.roomNumber == roomNumber && 
        (b.status.toLowerCase() == 'checked-in' || b.status.toLowerCase() == 'confirmed' || b.status.toLowerCase() == 'booked')
      );
    } catch (e) {
      return null;
    }
  }
  
  String _getImageUrl(String? path) {
    if (path == null || path.isEmpty) return 'https://placehold.co/400x300/e2e8f0/a0aec0?text=No+Image';
    if (path.startsWith('http')) return path;
    
    String baseUrl = AppConstants.baseUrl;
    if (baseUrl.endsWith('/api')) {
      baseUrl = baseUrl.replaceAll('/api', '');
    }
    if (path.startsWith('/')) {
      return '$baseUrl$path';
    }
    return '$baseUrl/$path';
  }

  @override
  Widget build(BuildContext context) {
    final roomProvider = Provider.of<RoomProvider>(context);
    final bookingProvider = Provider.of<BookingProvider>(context);

    // KPI Calc
    final total = roomProvider.rooms.length;
    final available = roomProvider.rooms.where((r) => r.status.toLowerCase() == 'available').length;
    final occupiedRooms = roomProvider.rooms.where((r) => r.status.toLowerCase() == 'occupied' || r.status.toLowerCase() == 'booked' || r.status.toLowerCase() == 'checked-in');
    final occupied = occupiedRooms.length;
    final maintenance = roomProvider.rooms.where((r) => r.status.toLowerCase() == 'maintenance').length;
    final dirtyRooms = roomProvider.rooms.where((r) => r.housekeepingStatus.toLowerCase() == 'dirty');
    final dirty = dirtyRooms.length;
    final clean = roomProvider.rooms.where((r) => r.housekeepingStatus.toLowerCase() == 'clean').length;
    
    // RevPAR Estimate (Occupied Room Price Sum / Total Rooms)
    double revenueToday = occupiedRooms.fold(0, (sum, r) => sum + r.price);
    // Add checked-in bookings revenue? Room price is a proxy.
    double revPar = total > 0 ? revenueToday / total : 0;
    
    // Turnover
    double turnoverProgress = (clean + dirty) > 0 ? clean / (clean + dirty) : 1.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Room Operations'),
        bottom: TabBar(
            // ... (keep tabs)
          controller: _tabController,
          isScrollable: true,
          onTap: (index) => setState(() {}),
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Vacant'),
            Tab(text: 'Occupied'),
            Tab(text: 'Clean'),
            Tab(text: 'Dirty'),
            Tab(text: 'Maint.'),
          ],
        ),
      ),
      body: Column(
        children: [
          // KPI Section (Horizontal Scroll)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Row(
              children: [
                _buildKpiCard('RevPAR', '₹${revPar.toStringAsFixed(0)}', Colors.purple),
                _buildTurnoverCard(clean, dirty),
                _buildKpiCard('Total', total.toString(), Colors.blue),
                _buildKpiCard('Available', available.toString(), Colors.green),
                _buildKpiCard('Occupied', occupied.toString(), Colors.red),
                // _buildKpiCard('Dirty', dirty.toString(), Colors.orange), // Covered by Turnover
                _buildKpiCard('Maint.', maintenance.toString(), Colors.grey),
              ],
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search Room Number...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 16),
              ),
              onChanged: (val) => setState(() {}),
            ),
          ),
          
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.7, // Taller cards for images
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: _filterRooms(roomProvider.rooms, _tabController.index, _searchController.text).length,
              itemBuilder: (context, index) {
                final room = _filterRooms(roomProvider.rooms, _tabController.index, _searchController.text)[index];
                final activeBooking = _findActiveBooking(room.roomNumber, bookingProvider.bookings);
                
                return _buildRoomCard(room, activeBooking);
              },
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildTurnoverCard(int clean, int dirty) {
     int total = clean + dirty;
     double progress = total > 0 ? clean / total : 1.0;
     
     return Container(
       margin: const EdgeInsets.only(right: 12),
       padding: const EdgeInsets.all(12),
       decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade300)),
       width: 140,
       child: Column(
         crossAxisAlignment: CrossAxisAlignment.start,
         children: [
            Text("Turnover", style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                 Text("$clean/$total Clean", style: const TextStyle(fontWeight: FontWeight.bold)),
                 Text("${(progress * 100).toInt()}%", style: const TextStyle(fontSize: 10, color: Colors.green)),
              ],
            ),
            const SizedBox(height: 6),
            LinearProgressIndicator(value: progress, backgroundColor: Colors.orange.shade100, color: Colors.green, minHeight: 6, borderRadius: BorderRadius.circular(4)),
         ],
       ),
     );
  }

  Widget _buildKpiCard(String title, String value, Color color) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
          Text(title, style: TextStyle(fontSize: 12, color: color.withOpacity(0.8))),
        ],
      ),
    );
  }

  Widget _buildRoomCard(Room room, Booking? booking) {
    Color statusColor = Colors.grey;
    if (room.status.toLowerCase() == 'available') statusColor = Colors.green;
    if (room.status.toLowerCase() == 'occupied' || room.status.toLowerCase() == 'booked' || room.status.toLowerCase() == 'checked-in') statusColor = Colors.red; // Match Web Admin Occupied Red
    if (room.status.toLowerCase() == 'maintenance') statusColor = Colors.yellow[800]!; // Darker yellow for text
    
    bool isDirty = room.housekeepingStatus.toLowerCase() == 'dirty';
    
    String? statusInfo;
    if (isDirty && room.housekeepingUpdatedAt != null) {
       try {
         final diff = DateTime.now().difference(DateTime.parse(room.housekeepingUpdatedAt!));
         statusInfo = "Dirty for ${diff.inHours}h ${diff.inMinutes % 60}m";
       } catch (e) {}
    } else if (room.status == 'Maintenance' && room.lastMaintenanceDate != null) {
       statusInfo = "Last Service: ${room.lastMaintenanceDate}";
    }
    
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isDirty ? const BorderSide(color: Colors.orange, width: 2) : BorderSide.none,
      ),
      child: InkWell(
        onTap: () {
           Navigator.push(context, MaterialPageRoute(builder: (_) => RoomHistoryScreen(room: room)));
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Section
            Stack(
              children: [
                Container(
                  height: 100,
                  width: double.infinity,
                  color: Colors.grey[200],
                  child: Image.network(
                    _getImageUrl(room.imageUrl),
                    fit: BoxFit.cover,
                    errorBuilder: (c, o, s) => const Icon(Icons.image_not_supported, size: 40, color: Colors.grey),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                     padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                     decoration: BoxDecoration(
                       color: statusColor,
                       borderRadius: BorderRadius.circular(12),
                     ),
                     child: Text(
                       room.status,
                       style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                     ),
                  ),
                )
              ],
            ),
            
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          room.roomNumber,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '\$${room.price.toStringAsFixed(0)}',
                           style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.blueGrey),
                        ),
                      ],
                    ),
                    Text(room.type, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    const SizedBox(height: 6),
                    
                    // Capacity
                    Row(
                      children: [
                        const Icon(Icons.people_outline, size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text('${room.adults}A, ${room.children}C', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                    
                    const Spacer(),
                    
                    // Features
                     Wrap(
                       spacing: 4,
                       runSpacing: 4,
                       children: [
                         if (room.wifi) _buildFeatureIcon(Icons.wifi),
                         if (room.airConditioning) _buildFeatureIcon(Icons.ac_unit),
                         if (room.tv) _buildFeatureIcon(Icons.tv),
                       ],
                     ),
                     
                     const SizedBox(height: 8),

                     // Dirty Status or Guest Name
                     if (booking != null) 
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(4)),
                          child: Row(
                            children: [
                               const Icon(Icons.person, size: 12, color: Colors.blue),
                               const SizedBox(width: 4),
                               Expanded(child: Text(booking.guestName, style: const TextStyle(fontSize: 10, color: Colors.blue), overflow: TextOverflow.ellipsis)),
                            ],
                          )
                        )
                     else if (statusInfo != null)
                       Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(color: isDirty ? Colors.orange[50] : Colors.grey[200], borderRadius: BorderRadius.circular(4)),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                               Icon(isDirty ? Icons.timer : Icons.build_circle, size: 12, color: isDirty ? Colors.orange : Colors.grey),
                               const SizedBox(width: 4),
                               Text(statusInfo!, style: TextStyle(fontSize: 10, color: isDirty ? Colors.orange : Colors.grey[700])),
                            ],
                          )
                        )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildFeatureIcon(IconData icon) {
     return Icon(icon, size: 14, color: Colors.grey[600]);
  }
}
