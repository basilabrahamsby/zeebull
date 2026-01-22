import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/service_provider.dart';
import '../models/service_request.dart';
import 'package:intl/intl.dart';

class ServiceListScreen extends StatefulWidget {
  const ServiceListScreen({super.key});

  @override
  State<ServiceListScreen> createState() => _ServiceListScreenState();
}

class _ServiceListScreenState extends State<ServiceListScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        Provider.of<ServiceProvider>(context, listen: false).fetchRequests());
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending': return Colors.orange;
      case 'in progress': return Colors.blue;
      case 'completed': return Colors.green;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final serviceProvider = Provider.of<ServiceProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('My Tasks')),
      body: serviceProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => serviceProvider.fetchRequests(),
              child: serviceProvider.requests.isEmpty 
                  ? const Center(child: Text("No active tasks"))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: serviceProvider.requests.length,
                      itemBuilder: (context, index) {
                        final req = serviceProvider.requests[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          elevation: 2,
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: _getStatusColor(req.status).withOpacity(0.2),
                              child: Icon(Icons.cleaning_services, color: _getStatusColor(req.status)),
                            ),
                            title: Text(req.serviceName, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Room: ${req.roomNumber}'),
                                if (req.notes != null) Text('Note: ${req.notes}', style: const TextStyle(fontStyle: FontStyle.italic)),
                                Text('Status: ${req.status}', style: TextStyle(color: _getStatusColor(req.status))),
                              ],
                            ),
                            trailing: req.status != 'Completed' ? PopupMenuButton<String>(
                              onSelected: (value) {
                                serviceProvider.updateStatus(req.id, value);
                              },
                              itemBuilder: (context) => [
                                if (req.status == 'Pending')
                                  const PopupMenuItem(value: 'In Progress', child: Text('Accept / Start')),
                                if (req.status == 'In Progress' || req.status == 'Pending')
                                  const PopupMenuItem(value: 'Completed', child: Text('Mark Complete')),
                              ],
                            ) : const Icon(Icons.check_circle, color: Colors.green),
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}
