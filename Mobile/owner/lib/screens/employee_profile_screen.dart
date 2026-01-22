import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/staff_provider.dart';
import '../models/employee.dart';
import 'package:intl/intl.dart';

class EmployeeProfileScreen extends StatefulWidget {
  final int employeeId;

  const EmployeeProfileScreen({super.key, required this.employeeId});

  @override
  State<EmployeeProfileScreen> createState() => _EmployeeProfileScreenState();
}

class _EmployeeProfileScreenState extends State<EmployeeProfileScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    
    // Fetch employee data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<StaffProvider>();
      provider.fetchWorkLogs(widget.employeeId);
      provider.fetchEmployeeLeaves(widget.employeeId);
      
      final now = DateTime.now();
      provider.fetchMonthlyReport(widget.employeeId, now.year, now.month);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Consumer<StaffProvider>(
          builder: (context, provider, child) {
            final employee = provider.employees.firstWhere(
              (e) => e.id == widget.employeeId,
              orElse: () => Employee(
                id: 0,
                name: 'Unknown',
                role: '',
                status: '',
                isClockedIn: false,
              ),
            );

            // Calculate stats
            final totalDays = provider.workLogs.length;
            final totalHours = provider.workLogs.fold(
              0.0,
              (sum, log) => sum + (log.durationHours ?? 0.0),
            );
            final usedLeaves = provider.employeeLeaves
                .where((l) => l.status == 'approved')
                .length;
            final availableLeaves = 12 - usedLeaves;

            return Column(
              children: [
                // Header with gradient
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.indigo.shade600, Colors.purple.shade600],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: Icon(Icons.arrow_back, color: Colors.white),
                          ),
                          Expanded(
                            child: Text(
                              "Employee Profile",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              provider.fetchWorkLogs(widget.employeeId);
                              provider.fetchEmployeeLeaves(widget.employeeId);
                            },
                            icon: Icon(Icons.refresh, color: Colors.white),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      // Employee Info Card
                      Container(
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 70,
                              height: 70,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  employee.name.isNotEmpty
                                      ? employee.name[0].toUpperCase()
                                      : 'U',
                                  style: TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.indigo.shade600,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    employee.name,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'ID: ${employee.id} • ${employee.role}',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.9),
                                      fontSize: 14,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: employee.isClockedIn
                                          ? Colors.green.withOpacity(0.3)
                                          : Colors.red.withOpacity(0.3),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: employee.isClockedIn
                                            ? Colors.green.shade200
                                            : Colors.red.shade200,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          employee.isClockedIn
                                              ? Icons.check_circle
                                              : Icons.cancel,
                                          size: 14,
                                          color: Colors.white,
                                        ),
                                        SizedBox(width: 6),
                                        Text(
                                          employee.isClockedIn
                                              ? 'On Duty'
                                              : 'Off Duty',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
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
                      ),
                      SizedBox(height: 20),
                      // Quick Stats
                      Row(
                        children: [
                          Expanded(
                            child: _buildStatCard(
                              icon: Icons.calendar_today,
                              label: 'Days',
                              value: '$totalDays',
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: _buildStatCard(
                              icon: Icons.access_time,
                              label: 'Hours',
                              value: '${totalHours.toFixed(1)}h',
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: _buildStatCard(
                              icon: Icons.beach_access,
                              label: 'Leaves',
                              value: '$usedLeaves',
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Tabs
                Container(
                  color: Colors.white,
                  child: TabBar(
                    controller: _tabController,
                    labelColor: Colors.indigo.shade600,
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: Colors.indigo.shade600,
                    indicatorWeight: 3,
                    tabs: [
                      Tab(
                        icon: Icon(Icons.access_time, size: 20),
                        text: 'Attendance',
                      ),
                      Tab(
                        icon: Icon(Icons.beach_access, size: 20),
                        text: 'Leaves',
                      ),
                      Tab(
                        icon: Icon(Icons.payments, size: 20),
                        text: 'Payments',
                      ),
                      Tab(
                        icon: Icon(Icons.info_outline, size: 20),
                        text: 'Details',
                      ),
                    ],
                  ),
                ),

                // Tab Content
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _AttendanceTab(provider: provider),
                      _LeavesTab(provider: provider, availableLeaves: availableLeaves, usedLeaves: usedLeaves),
                      _PaymentsTab(employee: employee),
                      _DetailsTab(employee: employee),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color.withOpacity(0.8), size: 20),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: color.withOpacity(0.9),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

// Attendance Tab
class _AttendanceTab extends StatelessWidget {
  final StaffProvider provider;

  const _AttendanceTab({required this.provider});

  @override
  Widget build(BuildContext context) {
    final workLogs = provider.workLogs;

    return ListView(
      padding: EdgeInsets.all(16),
      children: [
        if (workLogs.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(40.0),
              child: Column(
                children: [
                  Icon(Icons.event_busy, size: 64, color: Colors.grey[300]),
                  SizedBox(height: 16),
                  Text(
                    'No attendance records found',
                    style: TextStyle(color: Colors.grey[500], fontSize: 16),
                  ),
                ],
              ),
            ),
          )
        else
          ...workLogs.map((log) {
            final duration = log.durationHours ?? 0.0;
            final isActive = log.checkOutTime == null;

            return Container(
              margin: EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: ListTile(
                contentPadding: EdgeInsets.all(16),
                leading: Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isActive
                        ? Colors.green.withOpacity(0.1)
                        : Colors.indigo.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.event,
                    color: isActive ? Colors.green : Colors.indigo,
                    size: 24,
                  ),
                ),
                title: Text(
                  log.date ?? 'Unknown Date',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.login, size: 14, color: Colors.green),
                        SizedBox(width: 6),
                        Text(
                          log.checkInTime ?? 'N/A',
                          style: TextStyle(fontSize: 13),
                        ),
                        SizedBox(width: 16),
                        Icon(Icons.logout, size: 14, color: Colors.red),
                        SizedBox(width: 6),
                        Text(
                          log.checkOutTime ?? 'Still working',
                          style: TextStyle(fontSize: 13),
                        ),
                      ],
                    ),
                    if (!isActive && duration > 0) ...[
                      SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(Icons.timer, size: 14, color: Colors.blue),
                          SizedBox(width: 6),
                          Text(
                            '${duration.toStringAsFixed(1)}h',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
                trailing: isActive
                    ? Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.shade100,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Active',
                          style: TextStyle(
                            color: Colors.green.shade700,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    : null,
              ),
            );
          }).toList(),
      ],
    );
  }
}

// Leaves Tab
class _LeavesTab extends StatelessWidget {
  final StaffProvider provider;
  final int availableLeaves;
  final int usedLeaves;

  const _LeavesTab({
    required this.provider,
    required this.availableLeaves,
    required this.usedLeaves,
  });

  @override
  Widget build(BuildContext context) {
    final leaves = provider.employeeLeaves;

    return ListView(
      padding: EdgeInsets.all(16),
      children: [
        // Leave Balance Card
        Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.purple.shade400, Colors.purple.shade600],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.purple.withOpacity(0.3),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Available',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '$availableLeaves',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Used',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '$usedLeaves',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: 24),

        if (leaves.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(40.0),
              child: Column(
                children: [
                  Icon(Icons.beach_access_outlined,
                      size: 64, color: Colors.grey[300]),
                  SizedBox(height: 16),
                  Text(
                    'No leave records found',
                    style: TextStyle(color: Colors.grey[500], fontSize: 16),
                  ),
                ],
              ),
            ),
          )
        else
          ...leaves.map((leave) {
            final fromDate = DateTime.parse(leave.fromDate);
            final toDate = DateTime.parse(leave.toDate);
            final days = toDate.difference(fromDate).inDays + 1;

            Color statusColor = Colors.orange;
            if (leave.status == 'approved') statusColor = Colors.green;
            if (leave.status == 'rejected') statusColor = Colors.red;

            return Container(
              margin: EdgeInsets.only(bottom: 12),
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          leave.type ?? 'Leave',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          leave.status[0].toUpperCase() +
                              leave.status.substring(1),
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.calendar_today,
                          size: 14, color: Colors.grey[600]),
                      SizedBox(width: 6),
                      Text(
                        '${DateFormat('yyyy-MM-dd').format(fromDate)} to ${DateFormat('yyyy-MM-dd').format(toDate)} ($days ${days > 1 ? 'days' : 'day'})',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    leave.reason ?? 'No reason provided',
                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }).toList(),
      ],
    );
  }
}

// Payments Tab
class _PaymentsTab extends StatelessWidget {
  final Employee employee;

  const _PaymentsTab({required this.employee});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.all(16),
      children: [
        // Current Month Salary
        Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.green.shade400, Colors.green.shade600],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.green.withOpacity(0.3),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.account_balance_wallet,
                      color: Colors.white, size: 28),
                  SizedBox(width: 12),
                  Text(
                    'Current Month',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Text(
                'Estimated Salary',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 14,
                ),
              ),
              SizedBox(height: 8),
              Text(
                '₹ ${employee.salary?.toStringAsFixed(0) ?? '0'}',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: 24),

        // Payment History Placeholder
        Container(
          padding: EdgeInsets.all(40),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200, width: 2),
          ),
          child: Column(
            children: [
              Icon(Icons.payments, size: 64, color: Colors.grey[300]),
              SizedBox(height: 16),
              Text(
                'Payment history coming soon',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Detailed salary slips will be available here',
                style: TextStyle(color: Colors.grey[500], fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// Details Tab
class _DetailsTab extends StatelessWidget {
  final Employee employee;

  const _DetailsTab({required this.employee});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.all(16),
      children: [
        _buildDetailSection(
          title: 'Personal Information',
          icon: Icons.person,
          items: [
            _DetailItem(label: 'Name', value: employee.name),
            _DetailItem(label: 'Employee ID', value: '${employee.id}'),
            _DetailItem(label: 'Department', value: employee.role),
            _DetailItem(label: 'Status', value: employee.status),
          ],
        ),

        SizedBox(height: 20),

        _buildDetailSection(
          title: 'Work Information',
          icon: Icons.work,
          items: [
            _DetailItem(label: 'Position', value: employee.role),
            _DetailItem(
              label: 'Salary',
              value: '₹ ${employee.salary?.toStringAsFixed(0) ?? 'N/A'}',
            ),
            _DetailItem(
              label: 'Join Date',
              value: employee.joinDate ?? 'N/A',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDetailSection({
    required String title,
    required IconData icon,
    required List<_DetailItem> items,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Icon(icon, color: Colors.indigo.shade600, size: 24),
                SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1),
          ...items,
        ],
      ),
    );
  }
}

class _DetailItem extends StatelessWidget {
  final String label;
  final String value;

  const _DetailItem({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade100),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }
}

extension on double {
  String toFixed(int decimals) {
    return toStringAsFixed(decimals);
  }
}
