import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:orchid_employee/core/constants/app_colors.dart';
import 'package:orchid_employee/presentation/providers/auth_provider.dart';
import 'package:orchid_employee/presentation/providers/attendance_provider.dart';
import 'package:intl/intl.dart';

class EmployeeProfileScreen extends StatefulWidget {
  const EmployeeProfileScreen({super.key});

  @override
  State<EmployeeProfileScreen> createState() => _EmployeeProfileScreenState();
}

class _EmployeeProfileScreenState extends State<EmployeeProfileScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    
    // Fetch data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = context.read<AuthProvider>();
      final attendanceProvider = context.read<AttendanceProvider>();
      
      if (authProvider.employeeId != null) {
        attendanceProvider.fetchWorkLogs(authProvider.employeeId!);
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
    final authProvider = context.watch<AuthProvider>();
    final attendanceProvider = context.watch<AttendanceProvider>();

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Column(
          children: [
            // Header with gradient
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
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
                          "My Profile",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          // Refresh data
                          if (authProvider.employeeId != null) {
                            attendanceProvider.fetchWorkLogs(authProvider.employeeId!);
                          }
                        },
                        icon: Icon(Icons.refresh, color: Colors.white),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  // Profile Card
                  Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withOpacity(0.3)),
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
                          child: Icon(
                            Icons.person,
                            size: 40,
                            color: AppColors.primary,
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                authProvider.userName ?? 'Employee',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'ID: ${authProvider.employeeId ?? 'N/A'}',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 14,
                                ),
                              ),
                              SizedBox(height: 8),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: attendanceProvider.isOnDuty 
                                      ? Colors.green.withOpacity(0.3)
                                      : Colors.red.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: attendanceProvider.isOnDuty 
                                        ? Colors.green.shade200
                                        : Colors.red.shade200,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      attendanceProvider.isOnDuty 
                                          ? Icons.check_circle 
                                          : Icons.cancel,
                                      size: 14,
                                      color: Colors.white,
                                    ),
                                    SizedBox(width: 6),
                                    Text(
                                      attendanceProvider.isOnDuty ? 'On Duty' : 'Off Duty',
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
                ],
              ),
            ),
            
            // Tabs
            Container(
              color: Colors.white,
              child: TabBar(
                controller: _tabController,
                labelColor: AppColors.primary,
                unselectedLabelColor: Colors.grey,
                indicatorColor: AppColors.primary,
                indicatorWeight: 3,
                tabs: [
                  Tab(icon: Icon(Icons.access_time), text: 'Attendance'),
                  Tab(icon: Icon(Icons.beach_access), text: 'Leaves'),
                  Tab(icon: Icon(Icons.payments), text: 'Payments'),
                  Tab(icon: Icon(Icons.info_outline), text: 'Details'),
                ],
              ),
            ),
            
            // Tab Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _AttendanceTab(),
                  _LeavesTab(),
                  _PaymentsTab(),
                  _DetailsTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Attendance Tab
class _AttendanceTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final attendanceProvider = context.watch<AttendanceProvider>();
    final workLogs = attendanceProvider.workLogs;

    return RefreshIndicator(
      onRefresh: () async {
        final authProvider = context.read<AuthProvider>();
        if (authProvider.employeeId != null) {
          await attendanceProvider.fetchWorkLogs(authProvider.employeeId!);
        }
      },
      child: ListView(
        padding: EdgeInsets.all(16),
        children: [
          // Summary Card
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade400, Colors.blue.shade600],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.3),
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
                    Icon(Icons.calendar_month, color: Colors.white, size: 28),
                    SizedBox(width: 12),
                    Text(
                      'This Month',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: _SummaryItem(
                        icon: Icons.event_available,
                        label: 'Days Worked',
                        value: '${workLogs.length}',
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: _SummaryItem(
                        icon: Icons.access_time,
                        label: 'Total Hours',
                        value: _calculateTotalHours(workLogs),
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          SizedBox(height: 24),
          
          // History Header
          Row(
            children: [
              Icon(Icons.history, color: AppColors.primary, size: 24),
              SizedBox(width: 8),
              Text(
                'Attendance History',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          
          SizedBox(height: 16),
          
          // Work Logs List
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
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ...workLogs.map((log) {
              final clockIn = log['clock_in'] != null 
                  ? DateTime.parse(log['clock_in'])
                  : null;
              final clockOut = log['clock_out'] != null 
                  ? DateTime.parse(log['clock_out'])
                  : null;
              
              final duration = clockIn != null && clockOut != null
                  ? clockOut.difference(clockIn)
                  : null;
              
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
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.event,
                      color: AppColors.primary,
                      size: 24,
                    ),
                  ),
                  title: Text(
                    clockIn != null 
                        ? DateFormat('EEEE, MMM dd, yyyy').format(clockIn)
                        : 'Unknown Date',
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
                            clockIn != null 
                                ? DateFormat('HH:mm').format(clockIn)
                                : 'N/A',
                            style: TextStyle(fontSize: 13),
                          ),
                          SizedBox(width: 16),
                          Icon(Icons.logout, size: 14, color: Colors.red),
                          SizedBox(width: 6),
                          Text(
                            clockOut != null 
                                ? DateFormat('HH:mm').format(clockOut)
                                : 'Still working',
                            style: TextStyle(fontSize: 13),
                          ),
                        ],
                      ),
                      if (duration != null) ...[
                        SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(Icons.timer, size: 14, color: Colors.blue),
                            SizedBox(width: 6),
                            Text(
                              '${duration.inHours}h ${duration.inMinutes % 60}m',
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
                  trailing: clockOut == null
                      ? Container(
                          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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
      ),
    );
  }

  String _calculateTotalHours(List<dynamic> workLogs) {
    int totalMinutes = 0;
    
    for (var log in workLogs) {
      final clockIn = log['clock_in'] != null 
          ? DateTime.parse(log['clock_in'])
          : null;
      final clockOut = log['clock_out'] != null 
          ? DateTime.parse(log['clock_out'])
          : null;
      
      if (clockIn != null && clockOut != null) {
        totalMinutes += clockOut.difference(clockIn).inMinutes;
      }
    }
    
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;
    
    return '${hours}h ${minutes}m';
  }
}

// Leaves Tab
class _LeavesTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.beach_access, color: Colors.white, size: 28),
                  SizedBox(width: 12),
                  Text(
                    'Leave Balance',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _SummaryItem(
                      icon: Icons.event_available,
                      label: 'Available',
                      value: '12',
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: _SummaryItem(
                      icon: Icons.event_busy,
                      label: 'Used',
                      value: '3',
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        
        SizedBox(height: 24),
        
        // Apply Leave Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              _showApplyLeaveDialog(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: Icon(Icons.add_circle_outline),
            label: Text(
              'Apply for Leave',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        
        SizedBox(height: 24),
        
        // Leave History Header
        Row(
          children: [
            Icon(Icons.history, color: AppColors.primary, size: 24),
            SizedBox(width: 8),
            Text(
              'Leave History',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
          ],
        ),
        
        SizedBox(height: 16),
        
        // Sample Leave Records
        _LeaveCard(
          type: 'Sick Leave',
          startDate: '2026-01-10',
          endDate: '2026-01-11',
          days: 2,
          status: 'Approved',
          reason: 'Fever and cold',
        ),
        _LeaveCard(
          type: 'Casual Leave',
          startDate: '2026-01-05',
          endDate: '2026-01-05',
          days: 1,
          status: 'Approved',
          reason: 'Personal work',
        ),
        _LeaveCard(
          type: 'Annual Leave',
          startDate: '2025-12-25',
          endDate: '2025-12-27',
          days: 3,
          status: 'Approved',
          reason: 'Family vacation',
        ),
      ],
    );
  }

  void _showApplyLeaveDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Icon(Icons.beach_access, color: AppColors.primary, size: 28),
                  SizedBox(width: 12),
                  Text(
                    'Apply for Leave',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24),
              Text(
                'Leave application feature coming soon!',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text('Close'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Payments Tab
class _PaymentsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.all(16),
      children: [
        // Current Month Salary Card
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
                  Icon(Icons.account_balance_wallet, color: Colors.white, size: 28),
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
                '₹ 25,000',
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
        
        // Payment History Header
        Row(
          children: [
            Icon(Icons.history, color: AppColors.primary, size: 24),
            SizedBox(width: 8),
            Text(
              'Payment History',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
          ],
        ),
        
        SizedBox(height: 16),
        
        // Sample Payment Records
        _PaymentCard(
          month: 'December 2025',
          basicSalary: 25000,
          allowances: 2000,
          deductions: 1500,
          netSalary: 25500,
          paidOn: '2026-01-01',
        ),
        _PaymentCard(
          month: 'November 2025',
          basicSalary: 25000,
          allowances: 1500,
          deductions: 1200,
          netSalary: 25300,
          paidOn: '2025-12-01',
        ),
        _PaymentCard(
          month: 'October 2025',
          basicSalary: 25000,
          allowances: 1800,
          deductions: 1000,
          netSalary: 25800,
          paidOn: '2025-11-01',
        ),
      ],
    );
  }
}

// Details Tab
class _DetailsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    
    return ListView(
      padding: EdgeInsets.all(16),
      children: [
        _DetailSection(
          title: 'Personal Information',
          icon: Icons.person,
          items: [
            _DetailItem(label: 'Name', value: authProvider.userName ?? 'N/A'),
            _DetailItem(label: 'Employee ID', value: authProvider.employeeId?.toString() ?? 'N/A'),
            _DetailItem(label: 'Department', value: 'Housekeeping'),
            _DetailItem(label: 'Position', value: 'Staff'),
            _DetailItem(label: 'Join Date', value: 'Jan 01, 2025'),
          ],
        ),
        
        SizedBox(height: 20),
        
        _DetailSection(
          title: 'Contact Information',
          icon: Icons.contact_phone,
          items: [
            _DetailItem(label: 'Email', value: 'employee@orchid.com'),
            _DetailItem(label: 'Phone', value: '+91 98765 43210'),
            _DetailItem(label: 'Emergency Contact', value: '+91 98765 43211'),
          ],
        ),
        
        SizedBox(height: 20),
        
        _DetailSection(
          title: 'Work Information',
          icon: Icons.work,
          items: [
            _DetailItem(label: 'Shift', value: 'Day Shift (9 AM - 6 PM)'),
            _DetailItem(label: 'Working Days', value: 'Monday - Saturday'),
            _DetailItem(label: 'Reporting To', value: 'Manager Name'),
          ],
        ),
      ],
    );
  }
}

// Helper Widgets

class _SummaryItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _SummaryItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color.withOpacity(0.8), size: 20),
        SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: color.withOpacity(0.9),
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class _LeaveCard extends StatelessWidget {
  final String type;
  final String startDate;
  final String endDate;
  final int days;
  final String status;
  final String reason;

  const _LeaveCard({
    required this.type,
    required this.startDate,
    required this.endDate,
    required this.days,
    required this.status,
    required this.reason,
  });

  @override
  Widget build(BuildContext context) {
    final Color statusColor = status == 'Approved' 
        ? Colors.green 
        : status == 'Pending' 
            ? Colors.orange 
            : Colors.red;

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
                  type,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status,
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
              Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
              SizedBox(width: 6),
              Text(
                '$startDate to $endDate ($days ${days > 1 ? 'days' : 'day'})',
                style: TextStyle(fontSize: 13, color: Colors.grey[700]),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            reason,
            style: TextStyle(fontSize: 13, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}

class _PaymentCard extends StatelessWidget {
  final String month;
  final double basicSalary;
  final double allowances;
  final double deductions;
  final double netSalary;
  final String paidOn;

  const _PaymentCard({
    required this.month,
    required this.basicSalary,
    required this.allowances,
    required this.deductions,
    required this.netSalary,
    required this.paidOn,
  });

  @override
  Widget build(BuildContext context) {
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
      child: ExpansionTile(
        tilePadding: EdgeInsets.all(16),
        childrenPadding: EdgeInsets.fromLTRB(16, 0, 16, 16),
        leading: Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(Icons.account_balance_wallet, color: Colors.green),
        ),
        title: Text(
          month,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        subtitle: Text(
          'Paid on: $paidOn',
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
        trailing: Text(
          '₹ ${netSalary.toStringAsFixed(0)}',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
        children: [
          Divider(),
          _PaymentRow(label: 'Basic Salary', amount: basicSalary, isPositive: true),
          _PaymentRow(label: 'Allowances', amount: allowances, isPositive: true),
          _PaymentRow(label: 'Deductions', amount: deductions, isPositive: false),
          Divider(),
          _PaymentRow(label: 'Net Salary', amount: netSalary, isPositive: true, isBold: true),
        ],
      ),
    );
  }
}

class _PaymentRow extends StatelessWidget {
  final String label;
  final double amount;
  final bool isPositive;
  final bool isBold;

  const _PaymentRow({
    required this.label,
    required this.amount,
    required this.isPositive,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: Colors.grey[700],
            ),
          ),
          Text(
            '${isPositive ? '+' : '-'} ₹ ${amount.toStringAsFixed(0)}',
            style: TextStyle(
              fontSize: 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
              color: isPositive ? Colors.green : Colors.red,
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<_DetailItem> items;

  const _DetailSection({
    required this.title,
    required this.icon,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
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
                Icon(icon, color: AppColors.primary, size: 24),
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
