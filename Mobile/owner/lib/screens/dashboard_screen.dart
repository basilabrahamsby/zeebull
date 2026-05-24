import 'package:flutter/material.dart';
import 'dart:ui' show ImageFilter;
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
      backgroundColor: const Color(0xFFF1F5F9), // Background color outside the device frame on Web
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 24,
                  offset: const Offset(0, 4),
                )
              ]
            ),
            child: Scaffold(
              extendBody: true, // Let content flow underneath the floating bar
              body: _pages[_selectedIndex],
              bottomNavigationBar: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                      child: Container(
                        height: 70,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.85),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.4),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildNavItem(0, Icons.dashboard_outlined, Icons.dashboard_rounded, 'Dashboard'),
                            _buildNavItem(1, Icons.calendar_month_outlined, Icons.calendar_month_rounded, 'Bookings'),
                            _buildNavItem(2, Icons.bed_outlined, Icons.bed_rounded, 'Rooms'),
                            _buildNavItem(3, Icons.account_balance_wallet_outlined, Icons.account_balance_wallet_rounded, 'Finance'),
                            _buildNavItem(4, Icons.grid_view_outlined, Icons.grid_view_rounded, 'More'),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, IconData selectedIcon, String label) {
    final isSelected = _selectedIndex == index;
    final activeColor = const Color(0xFF064E3B); // Luxe deep emerald
    final inactiveColor = const Color(0xFF64748B); // Slate 500
    
    return InkWell(
      onTap: () => _onItemTapped(index),
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: isSelected ? activeColor.withOpacity(0.08) : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              isSelected ? selectedIcon : icon,
              color: isSelected ? activeColor : inactiveColor,
              size: 22,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
              color: isSelected ? activeColor : inactiveColor,
              letterSpacing: 0.1,
            ),
          ),
        ],
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
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8FAFC),
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          'More Modules',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Color(0xFF064E3B),
            letterSpacing: -0.5,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 110),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                children: [
                  Container(
                    width: 3.5,
                    height: 14,
                    decoration: BoxDecoration(
                      color: const Color(0xFF064E3B),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    "Management & Operations",
                    style: TextStyle(
                      fontSize: 14.5, 
                      fontWeight: FontWeight.w800, 
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
            ),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 3,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              children: [
                _buildMenuGridItem(
                  context,
                  title: "Inventory",
                  icon: Icons.inventory_2_rounded,
                  color: const Color(0xFF064E3B),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const InventoryScreen())),
                ),
                _buildMenuGridItem(
                  context,
                  title: "Services",
                  icon: Icons.cleaning_services_rounded,
                  color: const Color(0xFF10B981),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ServicesScreen())),
                ),
                _buildMenuGridItem(
                  context,
                  title: "Staff List",
                  icon: Icons.people_rounded,
                  color: const Color(0xFF0D9488),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const StaffScreen())),
                ),
                _buildMenuGridItem(
                  context,
                  title: "Food & Bev",
                  icon: Icons.restaurant_rounded,
                  color: const Color(0xFFD97706),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FoodScreen())),
                ),
                _buildMenuGridItem(
                  context,
                  title: "Profile",
                  icon: Icons.person_rounded,
                  color: const Color(0xFFC5A880),
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
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.01),
              blurRadius: 8,
              offset: const Offset(0, 3),
            )
          ]
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 11, 
                fontWeight: FontWeight.bold, 
                color: Color(0xFF475569),
                letterSpacing: 0.1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

