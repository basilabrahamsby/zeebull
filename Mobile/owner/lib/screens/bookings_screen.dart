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
  String _formatDate(String dateStr) {
    try {
      if (dateStr.isEmpty) return '';
      final date = DateTime.parse(dateStr);
      return DateFormat('dd-MM-yyyy').format(date);
    } catch (e) {
      return dateStr;
    }
  }

  Color _getStatusColor(String status) {
    final statusLower = status.toLowerCase().replaceAll('_', '-');
    switch (statusLower) {
      case 'checked-in':
      case 'confirmed':
      case 'booked':
        return const Color(0xFF064E3B);
      case 'checked-out':
        return const Color(0xFF64748B);
      case 'cancelled':
        return const Color(0xFFEF4444);
      case 'pending':
        return const Color(0xFFF59E0B);
      default:
        return const Color(0xFF3B82F6);
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
      final statusLower = b.status.toLowerCase().replaceAll('_', '-');
      switch (_tabController.index) {
        case 0: // All
          matchesTab = true;
          break;
        case 1: // Confirmed
          matchesTab = statusLower == 'confirmed' || statusLower == 'booked';
          break;
        case 2: // Checked-in
          matchesTab = statusLower == 'checked-in';
          break;
        case 3: // Checked-out
          matchesTab = statusLower == 'checked-out';
          break;
        case 4: // Cancelled
          matchesTab = statusLower == 'cancelled';
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
      final statusLower = b.status.toLowerCase().replaceAll('_', '-');
      if (statusLower == 'cancelled') {
        cancelledCount++;
        continue; // Don't count revenue for cancelled? Or count assuming deposit? Assuming simplified revenue.
      }
      
      double amt = double.tryParse(b.amount) ?? 0.0;
      // Count revenue only for non-cancelled
      totalRevenue += amt;

      if (statusLower == 'checked-in') {
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

    final currency = NumberFormat.simpleCurrency(name: 'INR', locale: 'en_IN', decimalDigits: 0);
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
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8FAFC),
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          'Bookings',
          style: TextStyle(
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
                  Tab(text: 'All'),
                  Tab(text: 'Confirmed'),
                  Tab(text: 'Checked-In'),
                  Tab(text: 'Checked-Out'),
                  Tab(text: 'Cancelled'),
                ],
                onTap: (_) => setState(() {}),
              ),
            ),
          ),
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
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.01),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        )
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      style: const TextStyle(fontSize: 13, color: Color(0xFF1E293B)),
                      decoration: InputDecoration(
                        hintText: 'Search Guest, Ref, Room...',
                        hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                        prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF64748B), size: 18),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1.2),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1.2),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: Color(0xFF064E3B), width: 1.5),
                        ),
                      ),
                      onChanged: (val) {
                        setState(() {
                          _searchQuery = val;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
                  ),
                  child: IconButton(
                    icon: Icon(
                      Icons.calendar_month_rounded, 
                      color: _startDate != null ? const Color(0xFF064E3B) : const Color(0xFF64748B),
                      size: 20,
                    ),
                    onPressed: _selectDateRange,
                  ),
                ),
                if (_startDate != null) ...[
                  const SizedBox(width: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.clear_rounded, color: Color(0xFFEF4444), size: 20), 
                      onPressed: () => setState(() { _startDate = null; _endDate = null; })
                    ),
                  ),
                ],
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
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
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
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.015),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatCard('Occupancy', stats['occupancy']!, const Color(0xFF064E3B), Icons.percent),
          _buildStatCard('Revenue', stats['revenue']!, const Color(0xFF10B981), Icons.currency_rupee_rounded),
          _buildStatCard('Cancel Rate', stats['cancelRate']!, const Color(0xFFEF4444), Icons.cancel_outlined),
          _buildStatCard('ADR', stats['adr']!, const Color(0xFFC5A880), Icons.bed_outlined),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color, IconData icon) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.08),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 14, color: color),
        ),
        const SizedBox(height: 6),
        Text(
          value, 
          style: TextStyle(
            fontSize: 14, 
            fontWeight: FontWeight.w800, 
            color: color,
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label, 
          style: const TextStyle(
            fontSize: 9.5, 
            color: Color(0xFF64748B), 
            fontWeight: FontWeight.bold,
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }

  Widget _buildBookingCard(Booking booking) {
    final statusColor = _getStatusColor(booking.status);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.01),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
             context, 
             MaterialPageRoute(builder: (_) => BookingDetailScreen(bookingId: booking.id, isPackage: booking.isPackage))
           );
        },
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Row: Ref & Status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.confirmation_num_outlined, size: 14, color: Color(0xFF64748B)),
                      const SizedBox(width: 6),
                      Text(
                        booking.bookingReference, 
                        style: const TextStyle(
                          fontWeight: FontWeight.bold, 
                          color: Color(0xFF475569),
                          fontSize: 12.5,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: statusColor.withOpacity(0.2), width: 1),
                    ),
                    child: Text(
                      booking.status.toUpperCase().replaceAll('_', ' '),
                      style: TextStyle(
                        fontSize: 9.5, 
                        fontWeight: FontWeight.bold, 
                        color: statusColor,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(height: 1, color: const Color(0xFFF1F5F9)),
              const SizedBox(height: 12),
              // Main Info Row: Room, Guest, Price
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Room Box
                  Container(
                    width: 58,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF064E3B).withOpacity(0.06),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFF064E3B).withOpacity(0.12), width: 1),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          booking.roomNumber, 
                          style: const TextStyle(
                            fontSize: 18, 
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF064E3B),
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'ROOM', 
                          style: TextStyle(
                            fontSize: 8, 
                            color: Color(0xFFC5A880),
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          booking.guestName, 
                          style: const TextStyle(
                            fontSize: 15, 
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 12,
                          runSpacing: 4,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.king_bed_outlined, size: 14, color: Color(0xFF64748B)),
                                const SizedBox(width: 4),
                                Text(
                                  booking.roomType, 
                                  style: const TextStyle(fontSize: 12, color: Color(0xFF475569), fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.calendar_month_outlined, size: 13, color: Color(0xFF64748B)),
                                const SizedBox(width: 4),
                                Text(
                                  '${_formatDate(booking.checkInDate)} → ${_formatDate(booking.checkOutDate)}', 
                                  style: const TextStyle(fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 12,
                          runSpacing: 4,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.people_outline_rounded, size: 14, color: Color(0xFF64748B)),
                                const SizedBox(width: 4),
                                Text(
                                  '${booking.adults} Adt, ${booking.children} Chd', 
                                  style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                            if (booking.isPackage)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.purple.shade50,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: Colors.purple.shade100),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.redeem_rounded, size: 11, color: Colors.purple.shade700),
                                    const SizedBox(width: 3),
                                    Text(
                                      booking.packageName.isNotEmpty ? booking.packageName : 'Package',
                                      style: TextStyle(fontSize: 10, color: Colors.purple.shade700, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Price
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '₹${booking.amount}', 
                        style: const TextStyle(
                          fontSize: 16, 
                          fontWeight: FontWeight.w800, 
                          color: Color(0xFF064E3B),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE2E8F0),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          booking.source.toUpperCase(), 
                          style: const TextStyle(
                            fontSize: 8, 
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF64748B),
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
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
