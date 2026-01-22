import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:orchid_employee/presentation/providers/auth_provider.dart';
import 'package:orchid_employee/core/constants/app_colors.dart';
import 'package:orchid_employee/presentation/screens/housekeeping/room_list_screen.dart';
import 'package:orchid_employee/presentation/screens/housekeeping/housekeeping_dashboard.dart';
import 'package:orchid_employee/presentation/widgets/app_drawer.dart';
import 'package:orchid_employee/presentation/screens/waiter/waiter_dashboard.dart';
import 'package:orchid_employee/presentation/screens/kitchen/kitchen_dashboard.dart';
import 'package:orchid_employee/presentation/screens/maintenance/maintenance_dashboard.dart';
import 'package:orchid_employee/presentation/screens/common/notifications_screen.dart';
import 'package:orchid_employee/presentation/providers/notification_provider.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
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

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: userRole == UserRole.kitchen 
        ? null 
        : AppBar(
            title: const Text('Dashboard'),
            backgroundColor: AppColors.primary,
            actions: [
              Consumer<NotificationProvider>(
                builder: (context, provider, child) => IconButton(
                  icon: Badge(
                    label: Text('${provider.unreadCount}'),
                    isLabelVisible: provider.unreadCount > 0,
                    child: const Icon(Icons.notifications_none),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const NotificationsScreen()),
                    ).then((_) => provider.fetchUnreadCount());
                  },
                ),
              ),
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () async {
                  final auth = Provider.of<AuthProvider>(context, listen: false);
                  await auth.logout();
                  if (context.mounted) {
                    Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
                  }
                },
              ),
            ],
          ),
      body: _buildBodyForRole(userRole, context),
    );
  }

  Widget _buildBodyForRole(UserRole role, BuildContext context) {
    switch (role) {
      case UserRole.housekeeping:
        return const _HousekeepingDashboard();
      case UserRole.kitchen:
        return const _KitchenDashboard();
      case UserRole.waiter:
        return const WaiterDashboard();
      case UserRole.maintenance:
        return const MaintenanceDashboard();
      case UserRole.manager:
        return _ManagerDashboard();
      default:
        return const Center(child: Text("Welcome! Please select a module from the menu."));
    }
  }
}

class _HousekeepingDashboard extends StatelessWidget {
  const _HousekeepingDashboard({super.key});
  @override
  Widget build(BuildContext context) {
    return const HousekeepingDashboard();
  }
}

class _KitchenDashboard extends StatelessWidget {
  const _KitchenDashboard({super.key});
  @override
  Widget build(BuildContext context) {
    return const KitchenDashboard();
  }
}

class _ManagerDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
          _DashboardCard(
            title: "Staff Active", 
            icon: Icons.people, 
            count: "12 Online",
            onTap: () {},
          ),
          _DashboardCard(
            title: "Occupancy", 
            icon: Icons.hotel, 
            count: "85%",
            onTap: () {},
          ),
          _DashboardCard(
            title: "Revenue Today", 
            icon: Icons.payments, 
            count: "₹45,200",
            color: Colors.green,
            onTap: () {},
          ),
          _DashboardCard(
            title: "Pending Checkouts", 
            icon: Icons.outbox, 
            count: "4 Rooms",
            color: Colors.orange,
            onTap: () {},
          ),
      ],
    );
  }
}

class _DashboardCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final String? count;
  final Color? color;
  final VoidCallback? onTap;

  const _DashboardCard({required this.title, required this.icon, this.count, this.color, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, size: 40, color: color ?? AppColors.primary),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: count != null ? Text(count!, style: const TextStyle(color: AppColors.secondary, fontWeight: FontWeight.bold)) : null,
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      ),
    );
  }
}
