import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:orchid_employee/presentation/widgets/responsive_container.dart';
import 'package:orchid_employee/presentation/providers/auth_provider.dart';
import 'package:orchid_employee/core/constants/app_colors.dart';
import 'package:orchid_employee/presentation/screens/housekeeping/room_list_screen.dart';
import 'package:orchid_employee/presentation/screens/housekeeping/housekeeping_dashboard.dart';
import 'package:orchid_employee/presentation/widgets/app_drawer.dart' show AppDrawer;
import 'package:orchid_employee/presentation/screens/waiter/waiter_dashboard.dart';
import 'package:orchid_employee/presentation/screens/kitchen/kitchen_dashboard.dart';
import 'package:orchid_employee/presentation/screens/maintenance/maintenance_dashboard.dart';
import 'package:orchid_employee/presentation/providers/notification_provider.dart';
import 'package:orchid_employee/presentation/screens/common/notifications_screen.dart';
import 'package:orchid_employee/presentation/screens/manager/manager_dashboard.dart';
import 'package:orchid_employee/presentation/screens/manager/manager_staff_screen.dart';
import 'package:orchid_employee/presentation/screens/manager/manager_inventory_screen.dart';
import 'package:orchid_employee/presentation/screens/manager/financial_reports_screen.dart';
import 'package:orchid_employee/presentation/screens/waiter/menu_order_screen.dart';
import 'package:orchid_employee/presentation/screens/waiter/waiter_service_screen.dart';


class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<NotificationProvider>(context, listen: false).fetchUnreadCount();
    });
  }

  @override
  Widget build(BuildContext context) {
    final userRole = Provider.of<AuthProvider>(context).role;
    final pages = _getPagesForRole(userRole);

    return ResponsiveContainer(
      child: Scaffold(
        drawer: const AppDrawer(),
      appBar: (userRole == UserRole.kitchen || 
               userRole == UserRole.manager || 
               userRole == UserRole.housekeeping || 
               userRole == UserRole.waiter)
          ? null
          : AppBar(
              flexibleSpace: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: AppColors.primaryGradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
              elevation: 0,
              title: Text(
                _getTitleForIndex(userRole, _currentIndex),
                style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
              ),
              centerTitle: true,
              actions: [
                _buildNotificationButton(),
                _buildLogoutButton(),
                const SizedBox(width: 8),
              ],
            ),
      body: Container(
        decoration: BoxDecoration(
          color: AppColors.onyx, // Changed to Onyx background
        ),
        child: IndexedStack(
          index: _currentIndex,
          children: pages,
        ),
      ),
      bottomNavigationBar: _shouldShowBottomBar(userRole)
          ? Container(
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: Colors.white.withOpacity(0.05), width: 0.5)),
              ),
              child: BottomNavigationBar(
                currentIndex: _currentIndex,
                onTap: (index) => setState(() => _currentIndex = index),
                type: BottomNavigationBarType.fixed,
                backgroundColor: AppColors.onyx,
                selectedItemColor: AppColors.accent,
                unselectedItemColor: Colors.white24,
                selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 0.5),
                unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10, letterSpacing: 0.5),
                elevation: 0,
                items: _getBottomBarItems(userRole),
              ),
            )
          : null,
      ),
    );
  }

  bool _shouldShowBottomBar(UserRole role) {
    return role == UserRole.manager || role == UserRole.housekeeping || role == UserRole.waiter || role == UserRole.maintenance || role == UserRole.kitchen || role == UserRole.frontOffice;
  }

  List<Widget> _getPagesForRole(UserRole role) {
    switch (role) {
      case UserRole.manager:
        return [
          const ManagerDashboardScreen(),
          const WaiterServiceScreen(), // Managers can see all services here
          ManagerStaffScreen(),
          ManagerInventoryScreen(),
          FinancialReportsScreen(),
        ];
      case UserRole.frontOffice:
        return [
          const HousekeepingDashboard(),
          const WaiterServiceScreen(),
          RoomListScreen(),
          NotificationsScreen(),
        ];
      case UserRole.housekeeping:
        return [
          const HousekeepingDashboard(),
          const WaiterServiceScreen(),
          RoomListScreen(),
          NotificationsScreen(),
        ];
      case UserRole.waiter:
        return [
          const WaiterDashboard(),
          const WaiterServiceScreen(),
          MenuOrderScreen(),
          NotificationsScreen(),
        ];
      case UserRole.kitchen:
        return [
          const KitchenDashboard(),
          const WaiterServiceScreen(),
          NotificationsScreen(),
        ];
      case UserRole.maintenance:
        return [
          const MaintenanceDashboard(),
          const WaiterServiceScreen(),
          NotificationsScreen(),
        ];
      default:
        return [const Center(child: Text("Welcome!"))];
    }
  }

  List<BottomNavigationBarItem> _getBottomBarItems(UserRole role) {
    if (role == UserRole.manager) {
      return const [
        BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: "Dash"),
        BottomNavigationBarItem(icon: Icon(Icons.room_service_rounded), label: "Tasks"),
        BottomNavigationBarItem(icon: Icon(Icons.people), label: "Staff"),
        BottomNavigationBarItem(icon: Icon(Icons.inventory), label: "Stock"),
        BottomNavigationBarItem(icon: Icon(Icons.analytics), label: "Finance"),
      ];
    } else if (role == UserRole.frontOffice) {
      return const [
        BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: "Home"),
        BottomNavigationBarItem(icon: Icon(Icons.room_service_rounded), label: "Tasks"),
        BottomNavigationBarItem(icon: Icon(Icons.bed), label: "Rooms"),
        BottomNavigationBarItem(icon: Icon(Icons.notifications), label: "Alerts"),
      ];
    } else if (role == UserRole.housekeeping) {
      return const [
        BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: "Home"),
        BottomNavigationBarItem(icon: Icon(Icons.room_service_rounded), label: "Tasks"),
        BottomNavigationBarItem(icon: Icon(Icons.bed), label: "Rooms"),
        BottomNavigationBarItem(icon: Icon(Icons.notifications), label: "Alerts"),
      ];
    } else if (role == UserRole.waiter) {
      return const [
        BottomNavigationBarItem(icon: Icon(Icons.table_bar), label: "Tables"),
        BottomNavigationBarItem(icon: Icon(Icons.room_service_rounded), label: "Services"),
        BottomNavigationBarItem(icon: Icon(Icons.add_shopping_cart), label: "Order"),
        BottomNavigationBarItem(icon: Icon(Icons.notifications), label: "Alerts"),
      ];
    } else if (role == UserRole.maintenance) {
      return const [
        BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: "Home"),
        BottomNavigationBarItem(icon: Icon(Icons.room_service_rounded), label: "Tasks"),
        BottomNavigationBarItem(icon: Icon(Icons.notifications), label: "Alerts"),
      ];
    } else if (role == UserRole.kitchen) {
      return const [
        BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: "Orders"),
        BottomNavigationBarItem(icon: Icon(Icons.room_service_rounded), label: "Tasks"),
        BottomNavigationBarItem(icon: Icon(Icons.notifications), label: "Alerts"),
      ];
    }
    return [];

  }

  String _getTitleForIndex(UserRole role, int index) {
    if (role == UserRole.manager) {
      return ["Dashboard", "Service Tasks", "Staff Management", "Inventory Control", "Financial Analytics"][index];
    }
    if (role == UserRole.frontOffice) {
      return ["Dashboard", "Assigned Tasks", "Room Management", "Notifications"][index];
    }
    if (role == UserRole.housekeeping) {
      return ["Dashboard", "Assigned Tasks", "Room Management", "Notifications"][index];
    }
    if (role == UserRole.maintenance) {
      return ["Dashboard", "Assigned Tasks", "Notifications"][index];
    }
    if (role == UserRole.kitchen) {
      return ["Dashboard", "Assigned Tasks", "Notifications"][index];
    }
    if (role == UserRole.waiter) {
      return ["Restaurant Status", "Assigned Services", "New Order", "Notifications"][index];
    }
    return "Dashboard";

  }

  Widget _buildNotificationButton() {
    return Consumer<NotificationProvider>(
      builder: (context, provider, child) => IconButton(
        icon: Badge(
          label: Text('${provider.unreadCount}'),
          isLabelVisible: provider.unreadCount > 0,
          child: const Icon(Icons.notifications_none),
        ),
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => NotificationsScreen())),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return IconButton(
      icon: const Icon(Icons.logout),
      onPressed: () async {
        await Provider.of<AuthProvider>(context, listen: false).logout();
        if (mounted) Navigator.pushReplacementNamed(context, '/login');
      },
    );
  }
}
