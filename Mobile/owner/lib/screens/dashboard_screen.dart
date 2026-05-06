import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'owner_dashboard_screen.dart';
import 'bookings_screen.dart';
import 'room_list_screen.dart';
import 'inventory_screen.dart';
import 'services_screen.dart';
import 'staff_screen.dart';
import 'expense_screen.dart';
import 'food_screen.dart';
import 'profile_screen.dart';
import '../providers/auth_provider.dart';
import 'login_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = <Widget>[
      const OwnerDashboardScreen(),
      const BookingsScreen(),
      const RoomListScreen(),
      const ExpenseScreen(),
      MoreMenuScreen(onNavigate: (index) {
        setState(() {
          _selectedIndex = index;
        });
      }),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, -2),
            )
          ]
        ),
        child: NavigationBar(
          onDestinationSelected: _onItemTapped,
          selectedIndex: _selectedIndex,
          backgroundColor: Colors.white,
          indicatorColor: const Color(0xFF15803D).withOpacity(0.1),
          height: 70,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: const <Widget>[
            NavigationDestination(
              icon: Icon(Icons.dashboard_outlined, color: Color(0xFF64748B)),
              selectedIcon: Icon(Icons.dashboard, color: Color(0xFF15803D)),
              label: 'Dashboard',
            ),
            NavigationDestination(
              icon: Icon(Icons.calendar_month_outlined, color: Color(0xFF64748B)),
              selectedIcon: Icon(Icons.calendar_month, color: Color(0xFF15803D)),
              label: 'Bookings',
            ),
            NavigationDestination(
              icon: Icon(Icons.bed_outlined, color: Color(0xFF64748B)),
              selectedIcon: Icon(Icons.bed, color: Color(0xFF15803D)),
              label: 'Rooms',
            ),
            NavigationDestination(
              icon: Icon(Icons.account_balance_wallet_outlined, color: Color(0xFF64748B)),
              selectedIcon: Icon(Icons.account_balance_wallet, color: Color(0xFF15803D)),
              label: 'Finance',
            ),
            NavigationDestination(
              icon: Icon(Icons.grid_view_outlined, color: Color(0xFF64748B)),
              selectedIcon: Icon(Icons.grid_view_rounded, color: Color(0xFF15803D)),
              label: 'More',
            ),
          ],
        ),
      ),
    );
  }
}

class MoreMenuScreen extends StatelessWidget {
  final Function(int) onNavigate;
  const MoreMenuScreen({super.key, required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('More Modules', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: const Color(0xFF1E293B),
      ),
      backgroundColor: const Color(0xFFF8FAFC),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Management & Operations",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
            ),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 3,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                _buildMenuGridItem(
                  context,
                  title: "Inventory",
                  icon: Icons.inventory_2_rounded,
                  color: Colors.teal,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const InventoryScreen())),
                ),
                _buildMenuGridItem(
                  context,
                  title: "Services",
                  icon: Icons.cleaning_services_rounded,
                  color: Colors.blue,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ServicesScreen())),
                ),
                _buildMenuGridItem(
                  context,
                  title: "Staff List",
                  icon: Icons.people_rounded,
                  color: Colors.indigo,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const StaffScreen())),
                ),
                _buildMenuGridItem(
                  context,
                  title: "Food & Bev",
                  icon: Icons.restaurant_rounded,
                  color: Colors.orange,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FoodScreen())),
                ),
                _buildMenuGridItem(
                  context,
                  title: "Profile",
                  icon: Icons.person_rounded,
                  color: Colors.purple,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen())),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuGridItem(BuildContext context, {required String title, required IconData icon, required Color color, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade100, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.015),
              blurRadius: 8,
              offset: const Offset(0, 2),
            )
          ]
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF475569)),
            ),
          ],
        ),
      ),
    );
  }
}

