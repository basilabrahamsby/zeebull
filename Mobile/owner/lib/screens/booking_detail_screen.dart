import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/booking_provider.dart';
import '../models/booking_details.dart';
import '../models/guest_history.dart';
import 'package:intl/intl.dart';
import '../config/constants.dart';

class BookingDetailScreen extends StatefulWidget {
  final int bookingId;
  final bool isPackage;

  const BookingDetailScreen({super.key, required this.bookingId, required this.isPackage});

  @override
  State<BookingDetailScreen> createState() => _BookingDetailScreenState();
}

class _BookingDetailScreenState extends State<BookingDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  GuestProfile? _guestProfile;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this); // Increased to 6 for Folio
    Future.microtask(() async {
        final provider = Provider.of<BookingProvider>(context, listen: false);
        await provider.fetchBookingDetails(widget.bookingId, widget.isPackage);
        
        final details = provider.selectedBookingDetails;
        if (details != null) {
          final profile = await provider.fetchGuestProfile(
            mobile: details.guestMobile,
            email: details.guestEmail,
            name: details.guestName
          );
          if (mounted) {
            setState(() {
              _guestProfile = profile;
            });
          }
        }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<BookingProvider>(context);
    final details = provider.selectedBookingDetails;
    final currency = NumberFormat.currency(locale: 'en_IN', symbol: '₹');

    if (provider.isLoading && details == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Booking Details')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (details == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Booking Details')),
        body: const Center(child: Text("Booking not found.")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(details.guestName, style: const TextStyle(fontSize: 16)),
            Text('Room ${details.roomNumber} • ${details.status}', style: const TextStyle(fontSize: 12, color: Colors.white70)),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: "Overview"),
            Tab(text: "Folio (Money)"),
            Tab(text: "Food"),
            Tab(text: "Services"),
            Tab(text: "Inventory"),
            Tab(text: "History"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(details, currency),
          _buildFolioTab(details, currency),
          _buildFoodOrdersTab(details, currency),
          _buildServicesTab(details),
          _buildInventoryTab(details),
          _buildGuestHistoryTab(_guestProfile),
        ],
      ),
      bottomNavigationBar: _buildBottomActions(details),
    );
  }

  Widget _buildBottomActions(BookingDetails details) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(blurRadius: 5, color: Colors.grey.withOpacity(0.3))]),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
           ElevatedButton.icon(
             onPressed: () {}, // TODO: Generate Reg Card
             icon: const Icon(Icons.print),
             label: const Text("Reg Card"),
           ),
        ],
      ),
    );
  }

  Widget _buildOverviewTab(BookingDetails details, NumberFormat currency) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Basic Info
          _buildCard("Booking Summary", [
            _row("Confirmation #", "BK-${details.id.toString().padLeft(6, '0')}"),
            _row("Status", details.status),
            _row("Check-in", details.checkIn),
            _row("Check-out", details.checkOut),
             _row("Source", details.source),
             if (details.packageName != null) _row("Package", details.packageName!),
          ]),
          const SizedBox(height: 16),
          
          // Identity & Verification
          _buildCard("Identity & Verification", [
             Row(
               children: [
                 Expanded(child: _buildPhoto("Guest Photo", details.guestPhotoUrl)),
                 const SizedBox(width: 16),
                 Expanded(child: _buildPhoto("ID Proof", details.idCardImageUrl)),
               ],
             ),
             const Divider(),
             const SizedBox(height: 8),
             const Text("Digital Signature", style: TextStyle(color: Colors.grey)),
             if (details.digitalSignatureUrl != null)
                Image.network(_getFullUrl(details.digitalSignatureUrl!), height: 60)
             else
                TextButton.icon(onPressed: () {}, icon: const Icon(Icons.draw), label: const Text("Capture Signature"))
          ]),

          const SizedBox(height: 16),
          
          // Guest Info & Prefs
          _buildCard("Guest Profile", [
            _row("Name", details.guestName),
            _row("Mobile", details.guestMobile ?? "-"),
            _row("Email", details.guestEmail ?? "-"),
            if (details.preferences != null) ...[
                const Divider(),
                const Text("Preferences & Tags", style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Wrap(spacing: 8, children: details.preferences!.split(',').map((tag) => Chip(
                  label: Text(tag.trim(), style: const TextStyle(fontSize: 10)),
                  backgroundColor: Colors.purple.shade50,
                )).toList())
            ],
            if (details.specialRequests != null) ...[
                const SizedBox(height: 8),
                const Text("Special Requests", style: TextStyle(fontWeight: FontWeight.bold)),
                Text(details.specialRequests!, style: const TextStyle(color: Colors.red)),
            ]
          ]),
        ],
      ),
    );
  }

  Widget _buildFolioTab(BookingDetails details, NumberFormat currency) {
    // Calculate Financials
    double roomTotal = details.totalAmount; // Assuming base booking amount is room charges
    double foodTotal = details.foodOrdersTotal;
    double servicesTotal = details.serviceRequests.fold(0, (sum, item) => sum + item.charges);
    double inventoryTotal = details.inventoryUsage.where((i) => i.isPayable).fold(0, (sum, i) => sum + (i.unitPrice * i.quantity));
    
    double grandTotal = roomTotal + foodTotal + servicesTotal + inventoryTotal;
    double paidTotal = details.advanceDeposit + details.payments.fold(0, (sum, p) => sum + p.amount);
    double balance = grandTotal - paidTotal;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Balance Card
          Card(
            color: balance > 0 ? Colors.red.shade50 : Colors.green.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Text("Outstanding Balance", style: TextStyle(fontSize: 16, color: Colors.grey)),
                  const SizedBox(height: 4),
                  Text(currency.format(balance), style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: balance > 0 ? Colors.red : Colors.green)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Charges Breakdown
          _buildCard("Charges Details", [
            _row("Room Charges", currency.format(roomTotal)),
            _row("Taxes & Fees", currency.format(roomTotal * 0.12)), // Estimated 12% GST
            _row("Food & Beverage", currency.format(foodTotal)),
            _row("Services", currency.format(servicesTotal)),
            _row("Inventory/Minibar", currency.format(inventoryTotal)),
            const Divider(),
            _row("Grand Total", currency.format(grandTotal + (roomTotal * 0.12)), isBold: true),
          ]),
          
          const SizedBox(height: 16),
          
          // Payments List
          _buildCard("Payments & Adjustments", [
             if (details.advanceDeposit > 0) 
                _paymentRow("Advance Deposit", details.advanceDeposit, "Pre-booking", currency),
             ...details.payments.map((p) => _paymentRow("Payment #${p.id}", p.amount, p.method, currency)).toList(),
             const Divider(),
             _row("Total Paid", currency.format(paidTotal), isBold: true, color: Colors.green),
          ]),

          const SizedBox(height: 16),
          
          // Profit Analysis (Owner View)
          Card(
            color: Colors.blue.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   const Row(children: [Icon(Icons.analytics, color: Colors.blue), SizedBox(width: 8), Text("Profit Analysis (Est.)", style: TextStyle(fontWeight: FontWeight.bold))]),
                   const Divider(),
                   _row("Net Revenue", currency.format(roomTotal + foodTotal + servicesTotal + inventoryTotal)),
                   _row("Est. Cost (Food)", "-${currency.format(foodTotal * 0.35)}", color: Colors.red),
                   _row("Est. Cost (Labor)", "-${currency.format(roomTotal * 0.20)}", color: Colors.red),
                   _row("Inventory Cost", "-${currency.format(details.inventoryUsage.where((i) => !i.isPayable).fold(0.0, (sum, i) => sum + (i.unitPrice * i.quantity)))}", color: Colors.red),
                   const Divider(),
                   _row("Net Profit", currency.format(
                      (roomTotal + foodTotal + servicesTotal + inventoryTotal) - 
                      (foodTotal * 0.35) - 
                      (roomTotal * 0.20) - 
                      (details.inventoryUsage.where((i) => !i.isPayable).fold(0.0, (sum, i) => sum + (i.unitPrice * i.quantity)))
                   ), isBold: true, color: Colors.blue),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
  
  Widget _paymentRow(String title, double amount, String subtitle, NumberFormat currency) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      dense: true,
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: Text(currency.format(amount), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
    );
  }

  // ... Reuse existing code for Food, Services, Inventory, History tabs ...
  Widget _buildFoodOrdersTab(BookingDetails details, NumberFormat currency) {
    if (details.foodOrders.isEmpty) return const Center(child: Text("No food orders."));
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: details.foodOrders.length,
      itemBuilder: (context, index) {
        final order = details.foodOrders[index];
        return Card(
           child: ExpansionTile(
             title: Text("Order #${order.id} - ${currency.format(order.amount)}"),
             subtitle: Text(order.status),
             children: order.items.map((i) => ListTile(title: Text(i))).toList(),
           )
        );
      },
    );
  }
  
  Widget _buildServicesTab(BookingDetails details) {
    if (details.serviceRequests.isEmpty) return const Center(child: Text("No service requests."));
     return ListView.separated(
       padding: const EdgeInsets.all(16),
       itemCount: details.serviceRequests.length,
       separatorBuilder: (_,__) => const SizedBox(height: 8),
       itemBuilder: (ctx, i) {
          final s = details.serviceRequests[i];
          return ListTile(
             tileColor: Colors.white,
             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
             leading: const Icon(Icons.room_service),
             title: Text(s.serviceName),
             trailing: Text("₹${s.charges}"),
             subtitle: Text(s.status),
          );
       },
     );
  }

  Widget _buildInventoryTab(BookingDetails details) {
    if (details.inventoryUsage.isEmpty) return const Center(child: Text("No inventory usage."));
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: details.inventoryUsage.length,
      itemBuilder: (ctx, i) {
        final item = details.inventoryUsage[i];
        return ListTile(
           title: Text(item.itemName),
           trailing: Text("${item.quantity} ${item.unit}"),
           subtitle: item.isDamaged ? const Text("DAMAGED", style: TextStyle(color: Colors.red)) : null,
        );
      }
    );
  }

  Widget _buildGuestHistoryTab(GuestProfile? profile) {
      if (profile == null) return const Center(child: CircularProgressIndicator());
      if (profile.bookings.isEmpty) return const Center(child: Text("No history."));
      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: profile.bookings.length,
        itemBuilder: (ctx, i) {
           final b = profile.bookings[i];
           return Card(
             child: ListTile(
               title: Text(b.type),
               subtitle: Text("${b.checkIn} - ${b.checkOut}"),
               trailing: Text(b.status),
             ),
           );
        }
      );
  }

  Widget _buildCard(String title, List<Widget> children) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Divider(),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value, {bool isBold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey.shade600)),
          Text(value, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.w500, color: color)),
        ],
      ),
    );
  }
  
  Widget _buildPhoto(String label, String? url) {
     return Column(
       children: [
         Container(
           height: 100,
           width: double.infinity,
           decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(8)),
           child: url != null 
             ? Image.network(_getFullUrl(url), fit: BoxFit.cover, errorBuilder: (_,__,___) => const Icon(Icons.broken_image))
             : const Icon(Icons.camera_alt, color: Colors.grey),
         ),
         const SizedBox(height: 4),
         Text(label, style: const TextStyle(fontSize: 12)),
       ],
     );
  }
  
  String _getFullUrl(String path) {
    if (path.startsWith('http')) return path;
    String baseUrl = AppConstants.baseUrl;
    if (baseUrl.endsWith('/api')) baseUrl = baseUrl.replaceAll('/api', '');
    if (path.startsWith('/')) return '$baseUrl$path';
    return '$baseUrl/$path';
  }
}
