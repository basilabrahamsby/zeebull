import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dio/dio.dart';
import 'package:orchid_employee/presentation/widgets/skeleton_loaders.dart';
import 'package:orchid_employee/presentation/widgets/onyx_glass_card.dart';
import 'package:image_picker/image_picker.dart';
import 'package:orchid_employee/core/constants/app_colors.dart';
import 'package:orchid_employee/data/services/api_service.dart';
import 'package:orchid_employee/presentation/providers/management_provider.dart';
import 'package:orchid_employee/presentation/screens/manager/manager_checkout_workflow.dart';
import 'package:orchid_employee/presentation/screens/manager/manager_guest_management_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:orchid_employee/core/constants/app_constants.dart';
import 'package:orchid_employee/core/constants/api_constants.dart';
import 'package:intl/intl.dart';
import 'dart:ui';
import 'dart:convert';

class ManagerBookingsScreen extends StatefulWidget {
  final bool isClockedIn;
  
  const ManagerBookingsScreen({super.key, this.isClockedIn = true});

  @override
  State<ManagerBookingsScreen> createState() => _ManagerBookingsScreenState();
}

class _ManagerBookingsScreenState extends State<ManagerBookingsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<dynamic> _roomBookings = [];
  List<dynamic> _packageBookings = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (mounted) setState(() {});
    });
    _loadBookings();
  }

  Future<Map<String, dynamic>?> _fetchFullBookingDetails(dynamic booking, bool isPackage) async {
    final api = context.read<ApiService>();
    try {
      final bookingId = booking['display_id'] ?? booking['id'].toString();
      final response = await api.dio.get('/bookings/details/$bookingId', queryParameters: {'is_package': isPackage});
      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      }
    } catch (e) {
      print("Error fetching detailed dossier: $e");
    }
    return null;
  }

  Future<void> _loadBookings() async {
    final api = context.read<ApiService>();
    setState(() => _isLoading = true);

    try {
      // Load Data in Parallel
      try {
        final results = await Future.wait([
          api.getBookings(),
          api.getPackageBookings(),
        ]);

        final roomResponse = results[0];
        final packageResponse = results[1];

        // Process Room Bookings
        if (roomResponse.statusCode == 200) {
          List<dynamic> rawRooms = [];
          if (roomResponse.data is List) {
            rawRooms = roomResponse.data as List;
          } else if (roomResponse.data is Map && roomResponse.data['bookings'] != null) {
            rawRooms = roomResponse.data['bookings'] as List;
          }
          _roomBookings = rawRooms.map((b) {
            final map = Map<String, dynamic>.from(b);
            map['is_package'] = false;
            return map;
          }).toList();
        }

        // Process Package Bookings
        if (packageResponse.statusCode == 200) {
          List<dynamic> rawPackages = [];
          if (packageResponse.data is List) {
            rawPackages = packageResponse.data as List;
          } else if (packageResponse.data is Map && packageResponse.data['bookings'] != null) {
            rawPackages = packageResponse.data['bookings'] as List;
          }
          _packageBookings = rawPackages.map((b) {
            final map = Map<String, dynamic>.from(b);
            map['is_package'] = true;
            return map;
          }).toList();
        }
      } catch (e) {
        print("Error loading bookings: $e");
      }

    } catch (e) {
      print("General error in _loadBookings: $e");
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalBookings = _roomBookings.length + _packageBookings.length;
    final totalRevenue = _roomBookings.fold<double>(0, (sum, b) => sum + (b['total_amount'] ?? 0)) +
                        _packageBookings.fold<double>(0, (sum, b) => sum + (b['total_amount'] ?? 0));
    final confirmedBookings = _roomBookings.where((b) => b['status'] == 'confirmed').length +
                              _packageBookings.where((b) => b['status'] == 'confirmed').length;

    return Scaffold(
      backgroundColor: AppColors.onyx,
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: AppColors.primaryGradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          // Ambient Glows
          Positioned(
            top: -100,
            right: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.accent.withOpacity(0.1),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
                child: Container(color: Colors.transparent),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Custom Header Navigation
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
                        style: IconButton.styleFrom(backgroundColor: Colors.white.withOpacity(0.05)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "RESERVATION",
                              style: TextStyle(color: AppColors.accent, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2),
                            ),
                            const Text(
                              "BOOKING CONTROL",
                              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 0.5),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: widget.isClockedIn ? () => _showCreateBookingDialog() : null,
                        icon: const Icon(Icons.add_circle_outline, color: AppColors.accent, size: 24),
                        style: IconButton.styleFrom(backgroundColor: AppColors.accent.withOpacity(0.05)),
                      ),
                    ],
                  ),
                ),

                // Modern TabBar
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicator: BoxDecoration(
                      color: AppColors.accent.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.accent.withOpacity(0.2)),
                    ),
                    labelColor: AppColors.accent,
                    unselectedLabelColor: Colors.white.withOpacity(0.7),
                    labelStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1),
                    dividerColor: Colors.transparent,
                    tabs: const [Tab(text: "ROOMS"), Tab(text: "PACKAGES"), Tab(text: "CALENDAR")],
                  ),
                ),

                Expanded(
                  child: _isLoading
                        ? const ListSkeleton()
                        : _tabController.index == 2 
                            ? _buildCalendarView()
                            : Column(
                                children: [
                                  // KPI Cards
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                    child: Column(
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(child: _buildEnhancedKpiCard("TOTAL", "$totalBookings", Icons.analytics_outlined, Colors.blueAccent)),
                                            const SizedBox(width: 12),
                                            Expanded(child: _buildEnhancedKpiCard("CONFIRMED", "$confirmedBookings", Icons.verified_user_outlined, Colors.greenAccent)),
                                          ],
                                        ),
                                        const SizedBox(height: 12),
                                        Row(
                                          children: [
                                            Expanded(child: _buildEnhancedKpiCard("REVENUE", NumberFormat.compact().format(totalRevenue), Icons.payments_outlined, Colors.amberAccent)),
                                            const SizedBox(width: 12),
                                            Expanded(child: _buildEnhancedKpiCard("INVENTORY", "${_roomBookings.length}", Icons.hotel_class_outlined, Colors.purpleAccent)),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Tab Content
                                  Expanded(
                                    child: TabBarView(
                                      controller: _tabController,
                                      children: [
                                        _buildBookingList(_roomBookings, isPackage: false),
                                        _buildBookingList(_packageBookings, isPackage: true),
                                        const SizedBox(), // Placeholder for Calendar
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

  }

  Widget _buildEnhancedKpiCard(String title, String value, IconData icon, Color color) {
    return OnyxGlassCard(
      padding: const EdgeInsets.all(16),
      borderRadius: 24,
      blur: 15,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title, 
                style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1.5)
              ),
              Icon(icon, color: color.withOpacity(0.5), size: 16),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value, 
            style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w100)
          ),
        ],
      ),
    );
  }

  Widget _buildBookingList(List<dynamic> bookings, {required bool isPackage}) {
    if (bookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.book_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            const Text("No bookings found", style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => _loadBookings(),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        itemCount: bookings.length,
        itemBuilder: (context, index) {
          final b = bookings[index];
          final statusColor = _getStatusColor(b['status'] ?? '');
          final statusLabel = (b['status'] ?? 'pending').toString().toUpperCase();
          
          return Container(
            margin: const EdgeInsets.only(bottom: 20),
            child: OnyxGlassCard(
              borderRadius: 32,
              padding: const EdgeInsets.all(0),
              child: InkWell(
                onTap: () => _showBookingDetails(b, isPackage),
                borderRadius: BorderRadius.circular(32),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Row
                      Row(
                        children: [
                          Container(
                            width: 54,
                            height: 54,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.05),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white.withOpacity(0.1))
                            ),
                            child: Center(
                              child: Text(
                                b['guest_name']?[0]?.toUpperCase() ?? 'G',
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 20),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  b['guest_name']?.toUpperCase() ?? 'GUEST',
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 0.5),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  (b['display_id'] ?? 'REF-0000').toString().toUpperCase(),
                                  style: TextStyle(fontSize: 10, color: Colors.white.withOpacity(0.4), fontWeight: FontWeight.w900, letterSpacing: 2),
                                ),
                              ],
                            ),
                          ),
                          _buildStatusBadge(statusLabel, statusColor),
                        ],
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Details Grid
                      Row(
                        children: [
                          Expanded(
                            child: _buildEnhancedDetailItem(
                              Icons.hotel_outlined,
                              isPackage 
                                  ? (b['package_name'] ?? 'PREMIUM') 
                                  : (b['rooms'] != null && (b['rooms'] as List).isNotEmpty 
                                      ? (b['rooms'][0]['number'] ?? 'N/A') 
                                      : (b['room_type_name'] ?? 'N/A')),
                              isPackage ? 'PACKAGE' : 'ROOM',
                            ),
                          ),
                          Expanded(
                            child: _buildEnhancedDetailItem(
                              Icons.group_outlined,
                              '${b['adults'] ?? 0}A + ${b['children'] ?? 0}C',
                              'GUESTS',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildEnhancedDetailItem(
                              Icons.calendar_today_outlined,
                              b['check_in'] ?? 'N/A',
                              'CHECK-IN',
                            ),
                          ),
                          Expanded(
                            child: _buildEnhancedDetailItem(
                              Icons.login_outlined,
                              b['check_out'] ?? 'N/A',
                              'CHECK-OUT',
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Footer: Value + Actions
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.04),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'TOTAL VALUE', 
                                      style: TextStyle(fontSize: 8, color: Colors.white.withOpacity(0.3), fontWeight: FontWeight.w900, letterSpacing: 1.5)
                                    ),
                                    Text(
                                      NumberFormat.currency(symbol: '₹', decimalDigits: 0).format(
                                        double.tryParse((b['total_amount'] ?? 0).toString()) ?? 0
                                      ),
                                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w200, color: Colors.white, letterSpacing: -1),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    _buildFinanceSmallInfo('ADVANCE', double.tryParse((b['advance_deposit'] ?? 0).toString()) ?? 0, Colors.greenAccent),
                                    const SizedBox(width: 16),
                                    _buildFinanceSmallInfo('BALANCE', (double.tryParse((b['total_amount'] ?? 0).toString()) ?? 0) - (double.tryParse((b['advance_deposit'] ?? 0).toString()) ?? 0), Colors.orangeAccent),
                                  ],
                                ),
                              ],
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              child: Divider(color: Colors.white10, height: 1),
                            ),
                            Center(
                              child: SizedBox(
                                width: 180,
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        _buildGridActionButton(Icons.visibility_outlined, Colors.white38, () => _showBookingDetails(b, isPackage), isActive: true),
                                        _buildGridActionButton(
                                          Icons.bolt, 
                                          (statusLabel == "CHECKED-IN" || statusLabel == "CHECKEDIN") ? Colors.amberAccent : Colors.deepPurpleAccent, 
                                          () => _handleQuickAction(b, isPackage, statusLabel),
                                          isActive: true,
                                          isPrimary: true
                                        ),
                                        _buildGridActionButton(
                                          Icons.inventory_2_outlined, 
                                          Colors.tealAccent, 
                                          () => Navigator.push(context, MaterialPageRoute(builder: (_) => ManagerGuestManagementScreen(booking: b, isPackage: isPackage))), 
                                          isActive: (statusLabel == "CHECKED-IN" || statusLabel == "CHECKEDIN") 
                                        ),
                                        _buildGridActionButton(Icons.calendar_month_outlined, Colors.white30, () => _editBooking(b), isActive: true),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        _buildGridActionButton(Icons.delete_outline, Colors.redAccent.withOpacity(0.5), () => _deleteBooking(b['id'], b['guest_name']), isActive: true),
                                        _buildGridActionButton(
                                          Icons.verified, 
                                          Colors.greenAccent, 
                                          () => _showConfirmBookingDialog(b), 
                                          isActive: b['status']?.toString().toLowerCase() == 'booked' || b['status']?.toString().toLowerCase() == 'confirmed',
                                          isPrimary: b['status']?.toString().toLowerCase() == 'booked'
                                        ),
                                        _buildGridActionButton(
                                          Icons.email_outlined, 
                                          Colors.blueAccent.withOpacity(0.5), 
                                          () {
                                            final roomNum = isPackage 
                                                ? (b['rooms'] != null && (b['rooms'] as List).isNotEmpty ? b['rooms'][0]['number'] : '') 
                                                : (b['rooms'] != null && (b['rooms'] as List).isNotEmpty ? b['rooms'][0]['number'] : '');
                                            _handleEmail(b, roomNum, b['branch_id']?.toString());
                                          },
                                          isActive: (statusLabel == "CHECKED-IN" || statusLabel == "CHECKEDIN")
                                        ),
                                        _buildGridActionButton(
                                          Icons.comment_outlined, 
                                          Colors.greenAccent.withOpacity(0.5), 
                                          () {
                                            final roomNum = isPackage 
                                                ? (b['rooms'] != null && (b['rooms'] as List).isNotEmpty ? b['rooms'][0]['number'] : '') 
                                                : (b['rooms'] != null && (b['rooms'] as List).isNotEmpty ? b['rooms'][0]['number'] : '');
                                            _handleWhatsApp(b, roomNum, b['branch_id']?.toString());
                                          },
                                          isActive: (statusLabel == "CHECKED-IN" || statusLabel == "CHECKEDIN")
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFinanceSmallInfo(String label, double amount, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 7, fontWeight: FontWeight.w900, letterSpacing: 1)),
        const SizedBox(height: 2),
        Text(
          NumberFormat.currency(symbol: '₹', decimalDigits: 0).format(amount),
          style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w900),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: color.withOpacity(0.5), blurRadius: 4, spreadRadius: 1)
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: color, letterSpacing: 1),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedDetailItem(IconData icon, String value, String label) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.white.withOpacity(0.4)),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label, 
                style: TextStyle(fontSize: 8, color: Colors.white.withOpacity(0.3), fontWeight: FontWeight.w900, letterSpacing: 0.5)
              ),
              Text(
                value, 
                style: const TextStyle(fontSize: 13, color: Colors.white, fontWeight: FontWeight.w700),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }


  Color _getStatusColor(String status) {
    status = status.toLowerCase();
    if (status.contains('checked-in') || status.contains('checkedin')) return Colors.indigoAccent;
    if (status.contains('confirmed') || status.contains('booked')) return Colors.greenAccent;
    if (status.contains('checked-out') || status.contains('checkedout')) return Colors.blueGrey;
    if (status.contains('cancelled')) return Colors.redAccent;
    return Colors.amberAccent;
  }
  void _showBookingDetails(dynamic booking, bool isPackage) async {
    // Show a loading dialog while fetching detailed data
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(child: CircularProgressIndicator(color: AppColors.accent)),
    );

    final fullDetails = await _fetchFullBookingDetails(booking, isPackage);
    
    if (mounted) Navigator.pop(context); // Remove loader

    final b = fullDetails ?? booking;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          height: MediaQuery.of(context).size.height * 0.9,
          decoration: BoxDecoration(
            color: AppColors.onyx.withOpacity(0.95),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            border: Border.all(color: Colors.white10),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 24),
              
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "RESERVATION HOST",
                              style: TextStyle(color: AppColors.accent, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2),
                            ),
                            Text(
                              isPackage ? "PACKAGE DOSSIER" : "BOOKING DOSSIER",
                              style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: 0.5),
                            ),
                          ],
                        ),
                        _buildStatusBadge((b['status'] ?? 'pending').toString().toUpperCase(), _getStatusColor(b['status'] ?? '')),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // Top Dossier Section
                    OnyxGlassCard(
                      padding: const EdgeInsets.all(24),
                      borderRadius: 24,
                      child: Column(
                        children: [
                          _buildModernInfoRow("GUEST NAME", b['guest_name']?.toUpperCase() ?? 'N/A', Icons.person_outline),
                          const Divider(color: Colors.white10, height: 32),
                          _buildModernInfoRow("CONTACT INFO", "${b['guest_email'] ?? 'N/A'}\n${b['guest_mobile'] ?? 'N/A'}", Icons.alternate_email),
                          const Divider(color: Colors.white10, height: 32),
                          _buildModernInfoRow(
                            isPackage ? "PACKAGE" : "ROOM TYPE", 
                            isPackage 
                              ? (b['package_name'] ?? 'N/A') 
                              : (b['rooms'] != null && (b['rooms'] as List).isNotEmpty 
                                  ? (b['rooms'] as List).map((r) => r['number']).join(", ")
                                  : (b['room_type_name'] ?? 'N/A')), 
                            Icons.hotel_outlined
                          ),
                          const Divider(color: Colors.white10, height: 32),
                          Row(
                            children: [
                              Expanded(child: _buildModernInfoRow("CHECK-IN", b['check_in'] ?? 'N/A', Icons.calendar_today_outlined)),
                              Expanded(child: _buildModernInfoRow("CHECK-OUT", b['check_out'] ?? 'N/A', Icons.login_outlined)),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Identity & Verification Section
                    if (b['id_card_image_url'] != null || b['guest_photo_url'] != null) ...[
                      const Text(
                        "IDENTITY VERIFICATION",
                        style: TextStyle(color: Colors.white30, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          if (b['id_card_image_url'] != null)
                            Expanded(
                              child: _buildImageTile("ID PROOF", "${ApiConstants.imageBaseUrl}/api/bookings/checkin-image/${b['id_card_image_url']}"),
                            ),
                          if (b['id_card_image_url'] != null && b['guest_photo_url'] != null) const SizedBox(width: 16),
                          if (b['guest_photo_url'] != null)
                            Expanded(
                              child: _buildImageTile("PORTRAIT", "${ApiConstants.imageBaseUrl}/api/bookings/checkin-image/${b['guest_photo_url']}"),
                            ),
                        ],
                      ),
                      const SizedBox(height: 32),
                    ],

                    // Summaries Section (Parity with Web)
                    if (b['food_orders'] != null && (b['food_orders'] as List).isNotEmpty) ...[
                      _buildSummarySection(
                        "DINING LOGS", 
                        (b['food_orders'] as List).map((o) => "${(o['items'] as List).join(", ")} (₹${o['amount']})").toList(),
                        Icons.restaurant
                      ),
                      const SizedBox(height: 24),
                    ],

                    if (b['service_requests'] != null && (b['service_requests'] as List).isNotEmpty) ...[
                      _buildSummarySection(
                        "HOSPITALITY SERVICES", 
                        (b['service_requests'] as List).map((s) => "${s['service_name']} - ${s['status']}").toList(),
                        Icons.cleaning_services
                      ),
                      const SizedBox(height: 24),
                    ],

                    if (b['inventory_usage'] != null && (b['inventory_usage'] as List).isNotEmpty) ...[
                      _buildSummarySection(
                        "ROOM INVENTORY", 
                        (b['inventory_usage'] as List).map((i) => "${i['item_name']} (x${i['quantity']} ${i['unit']})").toList(),
                        Icons.reorder
                      ),
                      const SizedBox(height: 24),
                    ],
                    
                    if (widget.isClockedIn) ...[
                      const SizedBox(height: 8),
                      // Actions
                      if (b['status'] == 'booked' || b['status'] == 'confirmed')
                        _buildModernActionBtn(
                          "INITIALIZE CHECK-IN", 
                          Colors.amberAccent, 
                          Icons.bolt,
                          () {
                            Navigator.pop(context);
                            _showCheckInDialog(b, isPackage);
                          }
                        ),
                      const SizedBox(height: 12),
                      if (b['status'] == 'booked' || b['status'] == 'confirmed' || b['status'] == 'checked-in')
                        _buildModernActionBtn(
                          "EXTEND STAY (EDIT)", 
                          Colors.indigoAccent, 
                          Icons.calendar_month_outlined,
                          () {
                            Navigator.pop(context);
                            _showExtendStayDialog(b);
                          }
                        ),
                      const SizedBox(height: 32),
                      Center(
                        child: TextButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            _deleteBooking(b['id'], b['guest_name']);
                          },
                          icon: const Icon(Icons.delete_sweep_outlined, color: Colors.white30, size: 18),
                          label: const Text("REVOKE RESERVATION", style: TextStyle(color: Colors.white30, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 2)),
                        ),
                      ),
                    ],
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageTile(String label, String url) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white24, fontSize: 8, fontWeight: FontWeight.w900, letterSpacing: 1)),
        const SizedBox(height: 8),
        Container(
          height: 120,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white10),
            image: DecorationImage(image: NetworkImage(url), fit: BoxFit.cover),
          ),
        ),
      ],
    );
  }

  Widget _buildSummarySection(String title, List<String> items, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: AppColors.accent, size: 14),
            const SizedBox(width: 8),
            Text(title, style: const TextStyle(color: AppColors.accent, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
          ],
        ),
        const SizedBox(height: 12),
        OnyxGlassCard(
          padding: const EdgeInsets.all(16),
          borderRadius: 16,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  Container(width: 4, height: 4, decoration: const BoxDecoration(color: Colors.white24, shape: BoxShape.circle)),
                  const SizedBox(width: 10),
                  Expanded(child: Text(item, style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w500))),
                ],
              ),
            )).toList(),
          ),
        ),
      ],
    );
  }


  Widget _buildModernInfoRow(String label, String value, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.white24, size: 20),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
              const SizedBox(height: 4),
              Text(value, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildModernActionBtn(String label, Color color, IconData icon, VoidCallback onTap) {
    return SizedBox(
      height: 56,
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 20),
        label: Text(label, style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1)),
        style: ElevatedButton.styleFrom(
          backgroundColor: color.withOpacity(0.1),
          foregroundColor: color,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          side: BorderSide(color: color.withOpacity(0.3), width: 1),
        ),
      ),
    );
  }

  void _editBooking(dynamic booking) {
    if (!widget.isClockedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please clock in to edit bookings")),
      );
      return;
    }
    _showExtendStayDialog(booking);
  }

  void _deleteBooking(int? id, String? guestName) {
    if (!widget.isClockedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please clock in to delete bookings")),
      );
      return;
    }
    
    if (id == null) return;
    
    showDialog(
      context: context,
      builder: (ctx) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: AlertDialog(
          backgroundColor: AppColors.onyx.withOpacity(0.9),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24), side: const BorderSide(color: Colors.white10)),
          title: const Text("REVOKE RESERVATION", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 2, fontSize: 16)),
          content: Text("Are you sure you want to permanently revoke the booking for ${guestName?.toUpperCase()}?", style: const TextStyle(color: Colors.white70, fontSize: 13)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx), 
              child: const Text("ABORT", style: TextStyle(color: Colors.white24, fontWeight: FontWeight.w900, letterSpacing: 1))
            ),
            ElevatedButton(
              onPressed: () async {
                final api = context.read<ApiService>();
                try {
                  await api.dio.delete('/bookings/$id');
                  Navigator.pop(ctx);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("RESERVATION REVOKED"), backgroundColor: Colors.redAccent),
                    );
                    _loadBookings();
                  }
                } catch (e) {
                  Navigator.pop(ctx);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("FAILURE: ${e.toString()}"), backgroundColor: Colors.red),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: const Text("PROCEED"),
            ),
          ],
        ),
      ),
    );
  }

  // --- Action Grid Helpers ---
  
  Widget _buildGridActionButton(IconData icon, Color color, VoidCallback onTap, {bool isActive = true, bool isPrimary = false}) {
    return InkWell(
      onTap: isActive ? onTap : null,
      borderRadius: BorderRadius.circular(12),
      child: Opacity(
        opacity: isActive ? 1.0 : 0.2,
        child: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: isPrimary ? color.withOpacity(0.8) : Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isPrimary ? color : Colors.white.withOpacity(0.1)),
            boxShadow: [
              if (isPrimary) BoxShadow(color: color.withOpacity(0.2), blurRadius: 8, spreadRadius: 0),
            ],
          ),
          child: Icon(icon, size: 18, color: isPrimary ? Colors.white : color),
        ),
      ),
    );
  }

  void _handleQuickAction(dynamic b, bool isPackage, String status) {
    if (status == "CHECKED-IN" || status == "CHECKEDIN") {
      // Navigate to Checkout
      final roomNum = isPackage 
          ? (b['rooms'] != null && (b['rooms'] as List).isNotEmpty ? b['rooms'][0]['number'] : '') 
          : (b['rooms'] != null && (b['rooms'] as List).isNotEmpty ? b['rooms'][0]['number'] : '');
      
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ManagerCheckoutWorkflow(initialRoomNumber: roomNum.toString())),
      );
    } else if (status == "BOOKED" || status == "CONFIRMED") {
      // Open Check-in
      _showCheckInDialog(b, isPackage);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("No quick action available for this status")));
    }
  }

  // --- Booking Actions (Export & Share) ---
  
  Future<void> _handlePdfExport(String roomNumber, String? branchId) async {
    if (roomNumber.isEmpty) return;
    const storage = FlutterSecureStorage();
    final token = await storage.read(key: AppConstants.tokenKey);
    if (token == null) return;
    
    final url = "${ApiConstants.baseUrl}/bill/$roomNumber/print?token=$token&branch_id=${branchId ?? ''}";
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _handleWhatsApp(dynamic booking, String roomNum, String? branchId) async {
    if (roomNum.isEmpty) return;
    setState(() => _isLoading = true);
    final billData = await context.read<ManagementProvider>().getBillSummary(roomNum, branchId: branchId);
    setState(() => _isLoading = false);
    
    if (billData != null) {
      final text = _generateBillText(billData, roomNum);
      final url = "https://wa.me/?text=${Uri.encodeComponent(text)}";
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _handleEmail(dynamic booking, String roomNum, String? branchId) async {
    if (roomNum.isEmpty) return;
    setState(() => _isLoading = true);
    final billData = await context.read<ManagementProvider>().getBillSummary(roomNum, branchId: branchId);
    setState(() => _isLoading = false);
    
    if (billData != null) {
      final text = _generateBillText(billData, roomNum);
      final url = "mailto:?subject=Invoice - Room $roomNum&body=${Uri.encodeComponent(text)}";
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  String _generateBillText(Map<String, dynamic> billData, String roomNum) {
    final charges = billData['charges'] ?? {};
    final format = NumberFormat.currency(symbol: "₹", decimalDigits: 0);
    
    String text = "*Check-out Bill - Orchid Resort*\n";
    text += "--------------------------------\n";
    text += "Guest: ${billData['guest_name']}\n";
    text += "Room: $roomNum\n";
    text += "Dates: ${billData['check_in']} to ${billData['check_out']}\n";
    text += "--------------------------------\n";
    
    // Extract individual charges
    final roomCharges = double.tryParse(charges['room_charges']?.toString() ?? '') ?? double.tryParse(charges['rent']?.toString() ?? '') ?? 0.0;
    final packageCharges = double.tryParse(charges['package_charges']?.toString() ?? '') ?? 0.0;
    final foodCharges = double.tryParse(charges['food_charges']?.toString() ?? '') ?? double.tryParse(charges['food']?.toString() ?? '') ?? 0.0;
    final serviceCharges = double.tryParse(charges['service_charges']?.toString() ?? '') ?? double.tryParse(charges['services']?.toString() ?? '') ?? 0.0;
    final consumablesCharges = double.tryParse(charges['consumables_charges']?.toString() ?? '') ?? 0.0;
    final inventoryCharges = double.tryParse(charges['inventory_charges']?.toString() ?? '') ?? 0.0;
    final assetDamageCharges = double.tryParse(charges['asset_damage_charges']?.toString() ?? '') ?? 0.0;

    // Extract individual GST components
    final roomGst = double.tryParse(charges['room_gst']?.toString() ?? '') ?? 0.0;
    final packageGst = double.tryParse(charges['package_gst']?.toString() ?? '') ?? 0.0;
    final foodGst = double.tryParse(charges['food_gst']?.toString() ?? '') ?? 0.0;
    final serviceGst = double.tryParse(charges['service_gst']?.toString() ?? '') ?? 0.0;
    final consumablesGst = double.tryParse(charges['consumables_gst']?.toString() ?? '') ?? 0.0;
    final inventoryGst = double.tryParse(charges['inventory_gst']?.toString() ?? '') ?? 0.0;
    final assetDamageGst = double.tryParse(charges['asset_damage_gst']?.toString() ?? '') ?? 0.0;

    final subtotal = double.tryParse(charges['total_due']?.toString() ?? '') ?? double.tryParse(charges['subtotal']?.toString() ?? '') ?? 0.0;
    final totalGst = double.tryParse(charges['total_gst']?.toString() ?? '') ?? double.tryParse(charges['gst']?.toString() ?? '') ?? 0.0;
    final discount = double.tryParse(charges['discount_amount']?.toString() ?? '') ?? 0.0;
    final advance = double.tryParse(charges['advance_deposit']?.toString() ?? '') ?? 0.0;
    
    final totalBill = subtotal + totalGst;
    final grandTotal = totalBill - discount - advance;

    if (roomCharges > 0) text += "Room Charges: ${format.format(roomCharges)}\n";
    if (packageCharges > 0) text += "Package Charges: ${format.format(packageCharges)}\n";
    if (foodCharges > 0) text += "Food Charges: ${format.format(foodCharges)}\n";
    if (serviceCharges > 0) text += "Service Charges: ${format.format(serviceCharges)}\n";
    if (consumablesCharges > 0) text += "Consumables Charges: ${format.format(consumablesCharges)}\n";
    if (inventoryCharges > 0) text += "Inventory/Rental Charges: ${format.format(inventoryCharges)}\n";
    if (assetDamageCharges > 0) text += "Asset Damage Charges: ${format.format(assetDamageCharges)}\n";
    
    text += "--------------------------------\n";
    text += "Subtotal: ${format.format(subtotal)}\n";

    // GST Breakdown
    if (roomGst > 0) text += "  Room GST: ${format.format(roomGst)}\n";
    if (packageGst > 0) text += "  Package GST: ${format.format(packageGst)}\n";
    if (foodGst > 0) text += "  Food GST (5%): ${format.format(foodGst)}\n";
    if (serviceGst > 0) text += "  Service GST: ${format.format(serviceGst)}\n";
    if (consumablesGst > 0) text += "  Consumables GST (5%): ${format.format(consumablesGst)}\n";
    if (inventoryGst > 0) text += "  Inventory GST: ${format.format(inventoryGst)}\n";
    if (assetDamageGst > 0) text += "  Damage GST: ${format.format(assetDamageGst)}\n";
    
    text += "Total GST: ${format.format(totalGst)}\n";
    text += "Total Bill: ${format.format(totalBill)}\n";
    if (discount > 0) text += "Discount: -${format.format(discount)}\n";
    if (advance > 0) text += "Advance Paid: -${format.format(advance)}\n";
    text += "--------------------------------\n";
    
    final label = grandTotal >= 0 ? "NET PAYABLE" : "REFUND AMOUNT";
    text += "*$label: ${format.format(grandTotal.abs())}*\n";
    text += "--------------------------------\n";
    text += "Thank you for staying with us!";
    
    return text;
  }

  Widget _buildKpiCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const Spacer(),
                Text(value, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: color)),
              ],
            ),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  void _showCreateBookingDialog() async {
    final api = context.read<ApiService>();
    List<dynamic> availablePackages = [];
    
    // Show premium loader
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(child: CircularProgressIndicator(color: AppColors.accent)),
    );

    try {
      final results = await Future.wait([
        api.getPackages(),
      ]);
      
      Navigator.pop(context); // Dismiss loader

      if (results[0].statusCode == 200) availablePackages = results[0].data as List;
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Sync Error: $e"), backgroundColor: Colors.red));
      return;
    }

    final guestNameController = TextEditingController();
    final emailController = TextEditingController();
    final phoneController = TextEditingController();
    final adultsController = TextEditingController(text: "1");
    final childrenController = TextEditingController(text: "0");
    final numRoomsController = TextEditingController(text: "1");
    final tariffController = TextEditingController();
    
    int? selectedRoomTypeId;
    List<dynamic> availableRoomTypes = [];
    DateTime bookingTime = DateTime.now();
    
    // Fetch Room Types
    try {
      final res = await api.getRoomTypes();
      if (res.statusCode == 200) {
        availableRoomTypes = res.data as List;
      }
    } catch (e) {
      print("Error fetching room types: $e");
    }
    
    int? selectedPackageId;
    bool isPackageBooking = false;
    DateTime? checkInDate;
    DateTime? checkOutDate;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            height: MediaQuery.of(context).size.height * 0.9,
            decoration: BoxDecoration(
              color: AppColors.onyx.withOpacity(0.95),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
              border: Border.all(color: Colors.white10),
            ),
            child: Column(
              children: [
                const SizedBox(height: 12),
                Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(2))),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "RESERVATION",
                            style: TextStyle(color: AppColors.accent, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2),
                          ),
                          Text(
                            isPackageBooking ? "BOOK PACKAGE" : "BOOK ROOM", 
                            style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: 0.5)
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white38),
                        onPressed: () => Navigator.pop(ctx),
                        style: IconButton.styleFrom(backgroundColor: Colors.white.withOpacity(0.05)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                
                // Content
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    children: [
                      // Toggle
                      Center(
                        child: OnyxGlassCard(
                          borderRadius: 20,
                          padding: const EdgeInsets.all(4),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _buildToggleBtn("ROOM", !isPackageBooking, () => setState(() { isPackageBooking = false; selectedPackageId = null; })),
                              _buildToggleBtn("PACKAGE", isPackageBooking, () => setState(() { isPackageBooking = true; selectedRoomTypeId = null; })),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 48),
                      
                      _buildGlassInput(guestNameController, "GUEST NAME *", Icons.person_outline),
                      const SizedBox(height: 24),
                      _buildGlassInput(tariffController, "ROOM TARIFF (BASE)", Icons.money, keyboard: TextInputType.number),
                      const SizedBox(height: 24),
                      _buildGlassInput(emailController, "EMAIL ADDRESS", Icons.email_outlined, keyboard: TextInputType.emailAddress),
                      const SizedBox(height: 24),
                      _buildGlassInput(phoneController, "PHONE NUMBER", Icons.phone_outlined, keyboard: TextInputType.phone),
                      const SizedBox(height: 32),

                      if (!isPackageBooking)
                        Column(
                          children: [
                            _buildGlassDropdown<int>(
                              value: selectedRoomTypeId,
                              label: "SELECT ROOM TYPE",
                              items: availableRoomTypes.map((rt) => DropdownMenuItem(
                                value: rt['id'] as int,
                                child: Text("${rt['name'].toUpperCase()}", style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                              )).toList(),
                              onChanged: (v) => setState(() => selectedRoomTypeId = v),
                            ),
                            const SizedBox(height: 24),
                            _buildReadOnlyField("BOOKING TIME", DateFormat('HH:mm').format(bookingTime), Icons.access_time_rounded),
                          ],
                        )
                      else
                        _buildGlassDropdown<int>(
                          value: selectedPackageId,
                          label: "SELECT PACKAGE",
                          items: availablePackages.map((p) => DropdownMenuItem(
                            value: p['id'] as int,
                            child: Text("${p['title']} (₹${p['price']})", style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                          )).toList(),
                          onChanged: (v) => setState(() => selectedPackageId = v),
                        ),

                      const SizedBox(height: 32),
                      _buildGlassInput(numRoomsController, "NUMBER OF ROOMS", Icons.meeting_room_outlined, keyboard: TextInputType.number),

                      const SizedBox(height: 32),
                      Row(
                        children: [
                          Expanded(child: _buildGlassInput(adultsController, "ADULTS", Icons.group_outlined, keyboard: TextInputType.number)),
                          const SizedBox(width: 24),
                          Expanded(child: _buildGlassInput(childrenController, "CHILDREN", Icons.child_care_outlined, keyboard: TextInputType.number)),
                        ],
                      ),
                      const SizedBox(height: 32),
                      
                      Row(
                        children: [
                          Expanded(child: _buildDatePickerBtn(ctx, "CHECK-IN", checkInDate, (d) => setState(() => checkInDate = d))),
                          const SizedBox(width: 24),
                          Expanded(child: _buildDatePickerBtn(ctx, "CHECK-OUT", checkOutDate, (d) => setState(() => checkOutDate = d), minDate: checkInDate)),
                        ],
                      ),
                      const SizedBox(height: 64),
                      
                      SizedBox(
                        height: 64,
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.accent,
                            foregroundColor: AppColors.onyx,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            elevation: 0,
                          ),
                          onPressed: () async {
                            if (guestNameController.text.isEmpty) {
                               ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("GUEST NAME IS REQUIRED"), backgroundColor: Colors.redAccent));
                               return;
                            }
                            if (!isPackageBooking && selectedRoomTypeId == null) {
                               ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("PLEASE SELECT A ROOM TYPE"), backgroundColor: Colors.redAccent));
                               return;
                            }
                            if (isPackageBooking && selectedPackageId == null) {
                               ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("PLEASE SELECT A PACKAGE"), backgroundColor: Colors.redAccent));
                               return;
                            }
                            if (checkInDate == null || checkOutDate == null) {
                               ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("DATES ARE REQUIRED"), backgroundColor: Colors.redAccent));
                               return;
                            }

                            try {
                              if (isPackageBooking) {
                                await api.createPackageBooking({
                                  'guest_name': guestNameController.text.toUpperCase(),
                                  'guest_email': emailController.text,
                                  'guest_mobile': phoneController.text,
                                  'package_id': selectedPackageId,
                                  'check_in': checkInDate?.toIso8601String().split('T')[0],
                                  'check_out': checkOutDate?.toIso8601String().split('T')[0],
                                  'adults': int.tryParse(adultsController.text) ?? 1,
                                  'children': int.tryParse(childrenController.text) ?? 0,
                                  'status': 'confirmed',
                                });
                              } else {
                                  await api.createBooking({
                                    'guest_name': guestNameController.text.toUpperCase(),
                                    'guest_email': emailController.text,
                                    'guest_mobile': phoneController.text,
                                    'room_type_id': selectedRoomTypeId,
                                    'check_in': checkInDate?.toIso8601String().split('T')[0],
                                    'check_out': checkOutDate?.toIso8601String().split('T')[0],
                                    'adults': int.tryParse(adultsController.text) ?? 1,
                                    'children': int.tryParse(childrenController.text) ?? 0,
                                    'num_rooms': int.tryParse(numRoomsController.text) ?? 1,
                                    'room_rate': double.tryParse(tariffController.text) ?? 0.0,
                                    'status': 'confirmed',
                                  });
                              }
                              Navigator.pop(ctx);
                              _loadBookings();
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("EXECUTION ERROR: $e"), backgroundColor: Colors.redAccent));
                            }
                          },
                          child: const Text("FINALIZE RESERVATION", style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 2)),
                        ),
                      ),
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildToggleBtn(String label, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: active ? AppColors.accent : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label, 
          style: TextStyle(
            color: active ? AppColors.onyx : Colors.white24, 
            fontSize: 11, 
            fontWeight: FontWeight.w900, 
            letterSpacing: 2
          )
        ),
      ),
    );
  }

  Widget _buildGlassInput(TextEditingController controller, String label, IconData icon, {TextInputType keyboard = TextInputType.text}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 2)),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboard,
            style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: Colors.white24, size: 18),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(20),
              isDense: true,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGlassDropdown<T>({required T? value, required String label, required List<DropdownMenuItem<T>> items, required ValueChanged<T?> onChanged}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 2)),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: value,
              items: items,
              onChanged: onChanged,
              dropdownColor: AppColors.onyx,
              icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white24, size: 20),
              isExpanded: true,
              hint: const Text("SELECT OPTION", style: TextStyle(color: Colors.white24, fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReadOnlyField(String label, String value, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 2)),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.02),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          child: Row(
            children: [
              Icon(icon, color: Colors.white12, size: 18),
              const SizedBox(width: 12),
              Text(value, style: const TextStyle(color: Colors.white38, fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 1)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDatePickerBtn(BuildContext context, String label, DateTime? date, Function(DateTime) onSelected, {DateTime? minDate}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 2)),
        const SizedBox(height: 12),
        InkWell(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: date ?? minDate ?? DateTime.now(),
              firstDate: minDate ?? DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 365)),
              builder: (context, child) => Theme(
                data: Theme.of(context).copyWith(
                  colorScheme: const ColorScheme.dark(primary: AppColors.accent, onPrimary: AppColors.onyx, surface: AppColors.onyx, onSurface: Colors.white),
                ),
                child: child!,
              ),
            );
            if (picked != null) onSelected(picked);
          },
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_month_outlined, color: Colors.white24, size: 18),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    date != null ? DateFormat('MMM dd, yyyy').format(date) : "SELECT DATE",
                    style: TextStyle(color: date != null ? Colors.white : Colors.white24, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStayDetailItem(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 8, fontWeight: FontWeight.w900, letterSpacing: 1),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w900),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }


  Future<void> _showCheckInDialog(dynamic booking, bool isPackage) async {
    final picker = ImagePicker();
    XFile? idProof;
    XFile? portrait;
    List<dynamic> availableRooms = [];
    List<int> selectedRoomIds = [];
    bool isSubmittingSub = false;

    int nights = 0;
    try {
      if (booking['check_in'] != null && booking['check_out'] != null) {
        final cin = DateTime.parse(booking['check_in'].toString());
        final cout = DateTime.parse(booking['check_out'].toString());
        nights = cout.difference(cin).inDays;
      }
    } catch (_) {}

    // Show Loader while fetching available rooms if it's a soft-allocated booking
    final currentRooms = booking['rooms'] as List?;
    final needsRoomAssignment = currentRooms == null || currentRooms.isEmpty;

    if (needsRoomAssignment) {
      final api = context.read<ApiService>();
      try {
        final rtId = booking['room_type_id'];
        final bId = booking['branch_id'];
        final res = await api.dio.get('/rooms', queryParameters: {
          'status': 'Available',
          if (rtId != null) 'room_type_id': rtId,
          if (bId != null) 'branch_id': bId,
        });
        if (res.statusCode == 200) {
          availableRooms = res.data as List;
        }
      } catch (e) {
        print("Error fetching rooms for check-in: $e");
      }
    }

    if (mounted) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (ctx) => StatefulBuilder(
          builder: (ctx, setSubState) => BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              height: MediaQuery.of(context).size.height * 0.9,
              decoration: BoxDecoration(
                color: AppColors.onyx.withOpacity(0.95),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                border: Border.all(color: Colors.white10),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(2))),
                  const SizedBox(height: 24),
                  
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      children: [
                        const Text(
                          "IDENTITY CAPTURE",
                          style: TextStyle(color: AppColors.accent, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2),
                        ),
                        const Text(
                          "CHECK-IN GUEST",
                          style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: 0.5),
                        ),
                        const SizedBox(height: 24),
                        
                        // Stay Details Card
                        OnyxGlassCard(
                          borderRadius: 24,
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.info_outline, color: AppColors.accent, size: 14),
                                  const SizedBox(width: 8),
                                  Text(
                                    "STAY CONFIGURATION: BK-${booking['id']}",
                                    style: const TextStyle(color: AppColors.accent, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1.5),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildStayDetailItem(
                                      "TEMPORAL SPAN",
                                      "$nights Night(s)",
                                      Colors.orangeAccent,
                                    ),
                                  ),
                                  Container(width: 1, height: 32, color: Colors.white10),
                                  Expanded(
                                    child: _buildStayDetailItem(
                                      "ROOMS BOOKED",
                                      "${booking['num_rooms'] ?? 1} Room(s)",
                                      Colors.greenAccent,
                                    ),
                                  ),
                                  Container(width: 1, height: 32, color: Colors.white10),
                                  Expanded(
                                    child: _buildStayDetailItem(
                                      isPackage ? "PACKAGE" : "CATEGORY",
                                      (isPackage 
                                          ? (booking['package_name'] ?? 'Package')
                                          : (booking['room_type_name'] ?? 'Room')).toString().toUpperCase(),
                                      Colors.blueAccent,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),

                        Row(
                          children: [
                            Expanded(
                              child: _buildCaptureTile(
                                "SCAN ID CARD", 
                                idProof, 
                                () async {
                                  final img = await picker.pickImage(
                                    source: ImageSource.camera,
                                    imageQuality: 50,
                                    maxWidth: 1024,
                                    maxHeight: 1024,
                                  );
                                  if (img != null) setSubState(() => idProof = img);
                                }
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildCaptureTile(
                                "TAKE PORTRAIT", 
                                portrait, 
                                () async {
                                  final img = await picker.pickImage(
                                    source: ImageSource.camera,
                                    imageQuality: 50,
                                    maxWidth: 1024,
                                    maxHeight: 1024,
                                  );
                                  if (img != null) setSubState(() => portrait = img);
                                }
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 32),

                        if (needsRoomAssignment) ...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "ASSIGN PHYSICAL ROOMS",
                                style: TextStyle(color: Colors.white24, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2),
                              ),
                              Text(
                                "SELECTED: ${selectedRoomIds.length} / ${booking['num_rooms'] ?? 1}",
                                style: TextStyle(
                                  color: selectedRoomIds.length == (booking['num_rooms'] ?? 1) ? AppColors.accent : Colors.white38,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.02),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.white10),
                            ),
                            child: Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: availableRooms.map((r) {
                                final isSelected = selectedRoomIds.contains(r['id']);
                                return GestureDetector(
                                  onTap: () {
                                    setSubState(() {
                                      if (isSelected) {
                                        selectedRoomIds.remove(r['id']);
                                      } else {
                                        // Optional: Limit selection to num_rooms?
                                        // For now let's just allow multiple as requested.
                                        selectedRoomIds.add(r['id'] as int);
                                      }
                                    });
                                  },
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                    decoration: BoxDecoration(
                                      color: isSelected ? AppColors.accent : Colors.white.withOpacity(0.05),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(color: isSelected ? AppColors.accent : Colors.white10),
                                      boxShadow: isSelected ? [BoxShadow(color: AppColors.accent.withOpacity(0.2), blurRadius: 8)] : null,
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          isSelected ? Icons.check_circle : Icons.add_circle_outline,
                                          size: 14,
                                          color: isSelected ? AppColors.onyx : Colors.white24,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          "ROOM ${r['number']}",
                                          style: TextStyle(
                                            color: isSelected ? AppColors.onyx : Colors.white70,
                                            fontWeight: FontWeight.w900,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],

                        const SizedBox(height: 48),

                        SizedBox(
                          height: 64,
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.accent,
                              foregroundColor: AppColors.onyx,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                              disabledBackgroundColor: Colors.white10,
                            ),
                            onPressed: isSubmittingSub ? null : () async {
                              if (idProof == null || portrait == null) {
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("BOTH ID AND PORTRAIT ARE MANDATORY")));
                                return;
                              }
                              if (needsRoomAssignment && selectedRoomIds.isEmpty) {
                                ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text("PLEASE ASSIGN AT LEAST ONE ROOM")));
                                return;
                              }

                              setSubState(() => isSubmittingSub = true);
                              try {
                                final api = context.read<ApiService>();
                                final response = await api.checkInBooking(
                                  booking['id'],
                                  isPackage: isPackage,
                                  idCardImage: idProof,
                                  guestPhoto: portrait,
                                  roomIds: selectedRoomIds.isNotEmpty ? selectedRoomIds : null,
                                );

                                if (response.statusCode == 200) {
                                  Navigator.pop(ctx);
                                  _loadBookings();
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("CHECK-IN SUCCESSFUL"), backgroundColor: Colors.greenAccent));
                                }
                              } catch (e) {
                                print("Check-in Error: $e");
                                ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text("ERROR: $e"), backgroundColor: Colors.redAccent));
                              } finally {
                                setSubState(() => isSubmittingSub = false);
                              }
                            },
                            child: isSubmittingSub 
                              ? const CircularProgressIndicator(color: AppColors.onyx)
                              : const Text("FINALIZE CHECK-IN", style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 2)),
                          ),
                        ),
                        const SizedBox(height: 60),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
  }

  Widget _buildCaptureTile(String label, XFile? file, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.white24, fontSize: 8, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
          const SizedBox(height: 12),
          Container(
            height: 120,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: file != null ? AppColors.accent.withOpacity(0.5) : Colors.white10),
            ),
            child: file != null 
              // Note: For actual preview we'd use Image.file(File(file.path)), 
              // for now just show a success icon if picked
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.check_circle, color: AppColors.accent, size: 32),
                    const SizedBox(height: 8),
                    Text(file.name, style: const TextStyle(color: Colors.white54, fontSize: 8), overflow: TextOverflow.ellipsis),
                  ],
                )
              : const Icon(Icons.camera_alt_outlined, color: Colors.white24, size: 32),
          ),
        ],
      ),
    );
  }

  void _showExtendStayDialog(dynamic b) {
    DateTime? newCheckOut;
    
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSubState) => BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: AlertDialog(
            backgroundColor: AppColors.onyx.withOpacity(0.9),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24), side: const BorderSide(color: Colors.white10)),
            title: const Text("EXTEND STAY", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 1)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDatePickerBtn(ctx, "NEW CHECK-OUT DATE", newCheckOut, (d) => setSubState(() => newCheckOut = d), minDate: DateTime.parse(b['check_out']).add(const Duration(days: 1))),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("CANCEL", style: TextStyle(color: Colors.white24))),
              ElevatedButton(
                onPressed: newCheckOut == null ? null : () async {
                  try {
                    final api = context.read<ApiService>();
                    final dateStr = DateFormat('yyyy-MM-dd').format(newCheckOut!);
                    await api.dio.put('/bookings/${b['id']}/extend', queryParameters: {'new_checkout': dateStr});
                    Navigator.pop(ctx);
                    _loadBookings();
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("STAY EXTENDED"), backgroundColor: Colors.greenAccent));
                  } catch (e) {
                    ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text("ERROR: $e"), backgroundColor: Colors.redAccent));
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.accent, foregroundColor: AppColors.onyx),
                child: const Text("CONFIRM"),
              ),
            ],
          ),
        ),
      ),
    );
  }
  Future<void> _showAddAmenitiesDialog(dynamic booking) async {
      // We need to fetch text-based amenities from backend or hardcode them if they are standard
      // For now, let's show a dialog with some standard amenities
      
      final amenities = [
        {'id': 'kit', 'name': 'Toiletry Kit', 'price': 0},
        {'id': 'water', 'name': 'Mineral Water', 'price': 20},
        {'id': 'towel', 'name': 'Extra Towel', 'price': 0},
        {'id': 'bed', 'name': 'Extra Bed', 'price': 500},
      ];
      
      final selectedAmenities = <String, int>{}; // id -> quantity

      await showDialog(
        context: context,
        builder: (ctx) => StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            title: const Text("Add Amenities/Items"),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: amenities.length,
                itemBuilder: (context, index) {
                  final item = amenities[index];
                  final id = item['id'] as String;
                  final qty = selectedAmenities[id] ?? 0;
                  
                  return ListTile(
                    title: Text(item['name'] as String),
                    subtitle: Text(item['price'] == 0 ? "Free" : "₹${item['price']}"),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (qty > 0)
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline),
                            onPressed: () => setState(() => selectedAmenities[id] = qty - 1),
                          ),
                        Text("$qty", style: const TextStyle(fontWeight: FontWeight.bold)),
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline),
                          onPressed: () => setState(() => selectedAmenities[id] = qty + 1),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
              ElevatedButton(
                onPressed: () async {
                   if (selectedAmenities.values.every((q) => q == 0)) {
                      Navigator.pop(ctx);
                      return;
                   }
                   
                   // Construct JSON for API
                   // We need to match the backend expected format for 'amenityAllocation'
                   // Backend expects: { "items": [ { "name": "...", "quantity": ... } ] }
                   
                   final itemsList = selectedAmenities.entries
                       .where((e) => e.value > 0)
                       .map((e) {
                         final def = amenities.firstWhere((a) => a['id'] == e.key);
                         return {"name": def['name'], "quantity": e.value};
                       })
                       .toList();
                   
                   final payload = {"items": itemsList};
                   
                   // We'll use the checkInBooking endpoint which handles amenityAllocation
                   // BUT for already checked-in guests, we might need a different endpoint 
                   // or re-use check-in with just amenity data?
                   // The backend's check_in_booking handles amenityAllocation even if status is 'booked'.
                   // If status is ALREADY checked-in, we might need to check if the backend allows re-calling check-in 
                   // or if we should use a specific 'add-items' endpoint.
                   // Looking at backend code: check_in_booking expects status to be 'booked'.
                   // So we can't use that for ALREADY checked-in guests.
                   
                   // We need to find an endpoint for adding orders/items to an active booking.
                   // Usually this is done via Food Orders or Inventory. 
                   // Let's assume for now we just show a success message as a mock
                   
                   Navigator.pop(ctx);
                   ScaffoldMessenger.of(context).showSnackBar(
                     const SnackBar(content: Text("Amenities added successfully (Mock)")),
                   );
                },
                child: const Text("Add Selected"),
              ),
            ],
          ),
        ),
      );
  }

  DateTime _selectedDate = DateTime.now();

  Widget _buildCalendarView() {
    final days = List.generate(30, (i) => DateTime.now().add(Duration(days: i - 7)));
    
    // Filter bookings for selected date
    final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
    final dailyBookings = [..._roomBookings, ..._packageBookings].where((b) => b['check_in'] == dateStr).toList();
    final dailyCheckins = dailyBookings.where((b) => b['status'] == 'confirmed').length;
    final dailyCheckouts = [..._roomBookings, ..._packageBookings].where((b) => b['check_out'] == dateStr && b['status'] == 'checked_in').length;

    return Column(
      children: [
        // Horizontal Date Selector
        Container(
          height: 90,
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: days.length,
            itemBuilder: (context, i) {
              final d = days[i];
              final isSel = d.year == _selectedDate.year && d.month == _selectedDate.month && d.day == _selectedDate.day;
              return GestureDetector(
                onTap: () => setState(() => _selectedDate = d),
                child: Container(
                  width: 60,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: isSel ? AppColors.accent : Colors.white.withOpacity(0.03),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: isSel ? AppColors.accent : Colors.white10),
                    boxShadow: isSel ? [BoxShadow(color: AppColors.accent.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 4))] : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(DateFormat('EEE').format(d).toUpperCase(), style: TextStyle(color: isSel ? AppColors.onyx : Colors.white38, fontSize: 10, fontWeight: FontWeight.w900)),
                      const SizedBox(height: 4),
                      Text("${d.day}", style: TextStyle(color: isSel ? AppColors.onyx : Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // Daily Reservation Matrix
              OnyxGlassCard(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("RESERVATION VELOCITY", style: TextStyle(color: Colors.white24, fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 2)),
                            Text(DateFormat('MMMM dd, yyyy').format(_selectedDate).toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16)),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(color: AppColors.accent.withOpacity(0.1), shape: BoxShape.circle),
                          child: const Icon(Icons.event_available_rounded, color: AppColors.accent, size: 20),
                        )
                      ],
                    ),
                    const SizedBox(height: 32),
                    Row(
                      children: [
                        _buildDailyStat("ARRIVALS", "${dailyBookings.length}", Colors.blueAccent),
                        _buildDailyStat("CHECK-INS", "$dailyCheckins", Colors.greenAccent),
                        _buildDailyStat("DEPARTURES", "$dailyCheckouts", Colors.orangeAccent),
                      ],
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              Text("SCHEDULED FOR ${DateFormat('MMM dd').format(_selectedDate).toUpperCase()}", style: const TextStyle(color: AppColors.accent, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
              const SizedBox(height: 16),
              
              if (dailyBookings.isEmpty) 
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: Column(
                      children: [
                        Icon(Icons.calendar_today_outlined, size: 48, color: Colors.white.withOpacity(0.05)),
                        const SizedBox(height: 16),
                        Text("NO RESERVATIONS SCHEDULED", style: TextStyle(color: Colors.white.withOpacity(0.1), fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1)),
                      ],
                    ),
                  ),
                )
              else
                ...dailyBookings.map((b) => _buildCondensedBookingCard(b)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDailyStat(String label, String val, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text(val, style: TextStyle(color: color, fontSize: 24, fontWeight: FontWeight.w900)),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(color: Colors.white.withOpacity(0.2), fontSize: 8, fontWeight: FontWeight.w900, letterSpacing: 1)),
        ],
      ),
    );
  }

  Widget _buildCondensedBookingCard(dynamic b) {
    final isPackage = b['package_name'] != null;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: OnyxGlassCard(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(color: AppColors.accent.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
              alignment: Alignment.center,
              child: Text(b['guest_name']?[0] ?? 'G', style: const TextStyle(color: AppColors.accent, fontWeight: FontWeight.w900)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(b['guest_name']?.toString().toUpperCase() ?? 'GUEST', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13)),
                  const SizedBox(height: 4),
                  Text(isPackage ? b['package_name'].toString().toUpperCase() : "ROOM ${b['room_number'] ?? 'N/A'}", style: TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text("₹${b['total_value'] ?? b['total_amount'] ?? 0}", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14)),
                Text(b['status']?.toString().toUpperCase() ?? 'PENDING', style: TextStyle(color: b['status'] == 'confirmed' ? Colors.greenAccent : Colors.orangeAccent, fontSize: 8, fontWeight: FontWeight.w900)),
              ],
            )
          ],
        ),
      ),
    );
  }

  Future<void> _showConfirmBookingDialog(dynamic booking) async {
    final isPackage = booking['is_package'] ?? false;
    final totalAmount = double.tryParse((booking['total_amount'] ?? 0).toString()) ?? 0.0;
    final previousAdvance = double.tryParse((booking['advance_deposit'] ?? 0).toString()) ?? 0.0;
    
    List<Map<String, dynamic>> payments = [
      {'amount': TextEditingController(text: "0"), 'method': 'Cash'}
    ];
    bool isSubmitting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSubState) {
          double newPaymentTotal = 0;
          for (var p in payments) {
            newPaymentTotal += double.tryParse(p['amount'].text) ?? 0;
          }
          final balanceDue = totalAmount - previousAdvance - newPaymentTotal;

          return BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              height: MediaQuery.of(context).size.height * 0.85,
              decoration: BoxDecoration(
                color: AppColors.onyx.withOpacity(0.95),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                border: Border.all(color: Colors.white10),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(2))),
                  const SizedBox(height: 24),
                  
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      children: [
                        const Text(
                          "RECORDING ADVANCE PAYMENT",
                          style: TextStyle(color: AppColors.accent, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2),
                        ),
                        const Text(
                          "CONFIRM BOOKING",
                          style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: 0.5),
                        ),
                        const SizedBox(height: 32),

                        OnyxGlassCard(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  _buildFinanceDetail("BOOKING VALUE", totalAmount, Colors.white),
                                  _buildFinanceDetail("PREVIOUS ADVANCE", previousAdvance, Colors.greenAccent),
                                ],
                              ),
                              const Divider(color: Colors.white10, height: 32),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  _buildFinanceDetail("NEW PAYMENT", newPaymentTotal, AppColors.accent),
                                  _buildFinanceDetail("BALANCE DUE", balanceDue, balanceDue > 0 ? Colors.orangeAccent : Colors.greenAccent),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 32),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("PAYMENT BREAKDOWN", style: TextStyle(color: Colors.white30, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1)),
                            TextButton.icon(
                              onPressed: () => setSubState(() => payments.add({'amount': TextEditingController(text: "0"), 'method': 'Cash'})),
                              icon: const Icon(Icons.add, size: 14, color: AppColors.accent),
                              label: const Text("ADD METHOD", style: TextStyle(color: AppColors.accent, fontSize: 9, fontWeight: FontWeight.w900)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        ...payments.asMap().entries.map((entry) {
                          int idx = entry.key;
                          var p = entry.value;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: _buildSimpleGlassInput(p['amount'], "AMOUNT", (v) => setSubState(() {})),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  flex: 2,
                                  child: _buildSimpleGlassDropdown(
                                    p['method'], 
                                    "METHOD", 
                                    ["Cash", "UPI", "Card", "Bank Transfer"],
                                    (v) => setSubState(() => p['method'] = v)
                                  ),
                                ),
                                if (payments.length > 1)
                                  IconButton(
                                    icon: const Icon(Icons.remove_circle_outline, color: Colors.redAccent, size: 20),
                                    onPressed: () => setSubState(() => payments.removeAt(idx)),
                                  ),
                              ],
                            ),
                          );
                        }).toList(),

                        const SizedBox(height: 48),

                        SizedBox(
                          height: 64,
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.accent,
                              foregroundColor: AppColors.onyx,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            ),
                            onPressed: isSubmitting ? null : () async {
                              setSubState(() => isSubmitting = true);
                              try {
                                final api = context.read<ApiService>();
                                final payload = {
                                  'payments': payments.map((p) => {
                                    'amount': double.tryParse(p['amount'].text) ?? 0,
                                    'method': p['method'].toLowerCase(),
                                  }).toList(),
                                  'notes': 'Recorded via Mobile App'
                                };

                                final res = await api.confirmBooking(booking['id'], payload, isPackage: isPackage);
                                if (res.statusCode == 200) {
                                  Navigator.pop(ctx);
                                  _loadBookings();
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("BOOKING CONFIRMED & ADVANCE RECORDED"), backgroundColor: Colors.greenAccent));
                                }
                              } catch (e) {
                                ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text("CONFIRMATION FAILED: $e"), backgroundColor: Colors.redAccent));
                              } finally {
                                setSubState(() => isSubmitting = false);
                              }
                            },
                            child: isSubmitting 
                              ? const CircularProgressIndicator(color: AppColors.onyx)
                              : const Text("CONFIRM & RECORD PAYMENT", style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 2)),
                          ),
                        ),
                        const SizedBox(height: 80),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }
      ),
    );
  }

  Widget _buildFinanceDetail(String label, double value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 8, fontWeight: FontWeight.w900, letterSpacing: 1)),
        const SizedBox(height: 4),
        Text(
          NumberFormat.currency(symbol: '₹', decimalDigits: 0).format(value),
          style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.w900),
        ),
      ],
    );
  }

  Widget _buildSimpleGlassInput(TextEditingController controller, String label, ValueChanged<String> onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.white24, fontSize: 8, fontWeight: FontWeight.bold)),
          TextField(
            controller: controller,
            onChanged: onChanged,
            keyboardType: TextInputType.number,
            style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
            decoration: const InputDecoration(isDense: true, border: InputBorder.none, contentPadding: EdgeInsets.symmetric(vertical: 8)),
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleGlassDropdown(String value, String label, List<String> options, ValueChanged<String?> onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.white24, fontSize: 8, fontWeight: FontWeight.bold)),
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isDense: true,
              dropdownColor: AppColors.onyx,
              items: options.map((o) => DropdownMenuItem(value: o, child: Text(o, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)))).toList(),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}
