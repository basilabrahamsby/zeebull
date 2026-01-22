import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/booking_provider.dart';
import '../providers/room_provider.dart';
import '../models/booking.dart';
import 'booking_detail_screen.dart';

class BookingsScreen extends StatefulWidget {
  const BookingsScreen({super.key});

  @override
  State<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    Future.microtask(() {
      Provider.of<BookingProvider>(context, listen: false).fetchBookings();
      Provider.of<RoomProvider>(context, listen: false).fetchRooms();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // --- Helpers ---
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'checked_in':
      case 'confirmed':
        return Colors.green;
      case 'checked_out':
        return Colors.grey;
      case 'cancelled':
        return Colors.red;
      case 'pending':
        return Colors.orange;
      default:
        return Colors.blueGrey;
    }
  }

  List<Booking> _filterBookings(List<Booking> allBookings) {
    return allBookings.where((b) {
      // 1. Search Filter
      final matchesSearch = _searchQuery.isEmpty ||
          b.guestName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          b.bookingReference.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          b.roomNumber.contains(_searchQuery);

      if (!matchesSearch) return false;

      // 2. Tab Filter
      bool matchesTab = true;
      switch (_tabController.index) {
        case 0: // All
          matchesTab = true;
          break;
        case 1: // Confirmed
          matchesTab = b.status.toLowerCase() == 'confirmed' || b.status.toLowerCase() == 'booked';
          break;
        case 2: // Checked-in
          matchesTab = b.status.toLowerCase() == 'checked_in';
          break;
        case 3: // Checked-out
          matchesTab = b.status.toLowerCase() == 'checked_out';
          break;
        case 4: // Cancelled
          matchesTab = b.status.toLowerCase() == 'cancelled';
          break;
      }
      if (!matchesTab) return false;

      // 3. Date Filter (Optional)
      if (_startDate != null && _endDate != null) {
        // Simple overlap check or check-in within range
        final checkIn = DateTime.tryParse(b.checkInDate);
        if (checkIn != null) {
           if (checkIn.isBefore(_startDate!) || checkIn.isAfter(_endDate!.add(const Duration(days: 1)))) {
             return false;
           }
        }
      }

      return true;
    }).toList();
  }

  // --- Statistic Calculations ---
  Map<String, String> _calculateStats(List<Booking> bookings, int totalRooms) {
    if (bookings.isEmpty) {
      return {'occupancy': '0%', 'revenue': '0', 'cancelRate': '0%', 'adr': '0'};
    }

    // Revenue
    double totalRevenue = 0;
    int cancelledCount = 0;
    int occupiedCount = 0;

    for (var b in bookings) {
      if (b.status.toLowerCase() == 'cancelled') {
        cancelledCount++;
        continue; // Don't count revenue for cancelled? Or count assuming deposit? Assuming simplified revenue.
      }
      
      double amt = double.tryParse(b.amount) ?? 0.0;
      // Count revenue only for non-cancelled
      totalRevenue += amt;

      if (b.status.toLowerCase() == 'checked_in') {
        occupiedCount++;
      }
    }

    // Occupancy Rate (Current Occupied / Total Rooms)
    // Note: totalRooms might be 0 if not fetched.
    double occupancyRate = (totalRooms > 0) ? (occupiedCount / totalRooms) * 100 : 0;

    // Cancellation Rate
    double cancelRate = (bookings.isNotEmpty) ? (cancelledCount / bookings.length) * 100 : 0;

    // ADR (Average Daily Rate) - Revenue / Total Confirmed Bookings (or Room Nights, simplified to Bookings)
    int revenueContributingBookings = bookings.length - cancelledCount;
    double adr = (revenueContributingBookings > 0) ? totalRevenue / revenueContributingBookings : 0;

    final currency = NumberFormat.simpleCurrency();
    return {
      'occupancy': '${occupancyRate.toStringAsFixed(1)}%',
      'revenue': currency.format(totalRevenue),
      'cancelRate': '${cancelRate.toStringAsFixed(1)}%',
      'adr': currency.format(adr),
    };
  }

  void _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2023),
      lastDate: DateTime(2030),
      initialDateRange: _startDate != null && _endDate != null 
          ? DateTimeRange(start: _startDate!, end: _endDate!) 
          : null,
    );
    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
    } else {
       // Clear filter if cancelled? No, allow clear explicitly.
    }
  }

  @override
  Widget build(BuildContext context) {
    final bookingProvider = Provider.of<BookingProvider>(context);
    final roomProvider = Provider.of<RoomProvider>(context);
    
    // Stats calculation based on ALL bookings (or should it respond to filters? Usually Dashboards show GLOBAL stats)
    // Let's show stats for the VIEWABLE set implies responsiveness, but user said "Big Picture".
    // I will use ALL fetched bookings for the stats to represent the "Big Picture" of fetched data.
    final stats = _calculateStats(bookingProvider.bookings, roomProvider.rooms.length);

    final filteredBookings = _filterBookings(bookingProvider.bookings);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bookings'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Confirmed'),
            Tab(text: 'Checked-In'),
            Tab(text: 'Checked-Out'),
            Tab(text: 'Cancelled'),
          ],
          onTap: (_) => setState(() {}),
        ),
      ),
      body: Column(
        children: [
          // 1. Stats Row
          _buildStatsRow(stats),

          // 2. Search & Filter Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search Guest, Ref, Room...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                    ),
                    onChanged: (val) {
                      setState(() {
                        _searchQuery = val;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: Icon(Icons.calendar_today, color: _startDate != null ? Theme.of(context).primaryColor : Colors.grey),
                  onPressed: _selectDateRange,
                ),
                if (_startDate != null)
                   IconButton(
                     icon: const Icon(Icons.clear), 
                     onPressed: () => setState(() { _startDate = null; _endDate = null; })
                   ),
              ],
            ),
          ),
          
          // 3. Booking List
          Expanded(
            child: bookingProvider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : filteredBookings.isEmpty
                  ? const Center(child: Text('No bookings found matching criteria.'))
                  : RefreshIndicator(
                      onRefresh: () async {
                        await bookingProvider.fetchBookings();
                        // ignore: use_build_context_synchronously
                        if (mounted) Provider.of<RoomProvider>(context, listen: false).fetchRooms();
                      },
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        itemCount: filteredBookings.length,
                        itemBuilder: (context, index) {
                          return _buildBookingCard(filteredBookings[index]);
                        },
                      ),
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(Map<String, String> stats) {
    return Container(
      padding: const EdgeInsets.all(12),
      color: Colors.grey[100],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatCard('Occupancy', stats['occupancy']!, Colors.blue),
          _buildStatCard('Revenue', stats['revenue']!, Colors.green),
          _buildStatCard('Cancel Rate', stats['cancelRate']!, Colors.red),
          _buildStatCard('ADR', stats['adr']!, Colors.orange),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  Widget _buildBookingCard(Booking booking) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.push(
             context, 
             MaterialPageRoute(builder: (_) => BookingDetailScreen(bookingId: booking.id, isPackage: booking.isPackage))
           );
        },
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              // Top Row: Ref & Status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(booking.bookingReference, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(booking.status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: _getStatusColor(booking.status).withOpacity(0.5)),
                    ),
                    child: Text(
                      booking.status.toUpperCase(),
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: _getStatusColor(booking.status)),
                    ),
                  ),
                ],
              ),
              const Divider(),
              // Main Info Row: Room, Guest, Price
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Room Box
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.blueGrey[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(booking.roomNumber, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        Text('Room', style: TextStyle(fontSize: 10, color: Colors.grey[600])),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(booking.guestName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                             Icon(Icons.king_bed, size: 14, color: Colors.grey[600]),
                             const SizedBox(width: 4),
                             Text(booking.roomType, style: TextStyle(fontSize: 13, color: Colors.grey[800])),
                             const SizedBox(width: 12),
                             Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
                             const SizedBox(width: 4),
                             Text('${booking.checkInDate} -> ${booking.checkOutDate}', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                          ],
                        ),
                        const SizedBox(height: 4),
                         Row(
                          children: [
                             Icon(Icons.person, size: 14, color: Colors.grey[600]),
                             const SizedBox(width: 4),
                             Text('${booking.adults} Adt, ${booking.children} Chd', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                             const SizedBox(width: 12),
                             if (booking.isPackage) ...[
                                const Icon(Icons.redeem, size: 14, color: Colors.purple),
                                const SizedBox(width: 4),
                                Text(booking.packageName.isNotEmpty ? booking.packageName : 'Package', 
                                    style: const TextStyle(fontSize: 12, color: Colors.purple, fontWeight: FontWeight.bold)
                                ),
                             ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Price
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('\$${booking.amount}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green)),
                      Text(booking.source, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
