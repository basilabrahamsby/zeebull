import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/service_provider.dart';
import '../models/service.dart';
import '../models/service_request.dart';

class ServicesScreen extends StatefulWidget {
  const ServicesScreen({super.key});

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    Future.microtask(() {
      final provider = Provider.of<ServiceProvider>(context, listen: false);
      provider.fetchServices();
      provider.fetchAssignedServices();
      provider.fetchRequests();
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
      appBar: AppBar(
        title: const Text('Services'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Catalog'),
            Tab(text: 'Activity'),
            Tab(text: 'Requests'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          ServiceCatalogTab(),
          ServiceActivityTab(),
          ServiceRequestsTab(),
        ],
      ),
    );
  }
}

class ServiceCatalogTab extends StatelessWidget {
  const ServiceCatalogTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ServiceProvider>(
      builder: (context, provider, child) {
        final services = provider.services;
        
        // KPIs
        final totalServices = services.length;
        final guestVisible = services.where((s) => s.isVisibleToGuest).length;
        final avgPrice = services.isEmpty 
            ? 0.0 
            : services.fold(0.0, (sum, s) => sum + s.charges) / services.length;

        return Column(
          children: [
            // KPI Dashboard
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  _KpiCard(
                    title: 'Total Services',
                    value: '$totalServices',
                    icon: Icons.spa,
                    color: Colors.blue,
                  ),
                  const SizedBox(width: 12),
                  _KpiCard(
                    title: 'Guest Visible',
                    value: '$guestVisible',
                    icon: Icons.visibility,
                    color: Colors.green,
                  ),
                  const SizedBox(width: 12),
                  _KpiCard(
                    title: 'Avg Price',
                    value: '\$${avgPrice.toStringAsFixed(0)}',
                    icon: Icons.attach_money,
                    color: Colors.orange,
                  ),
                ],
              ),
            ),
            
            // List
            Expanded(
              child: provider.isLoading && services.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : services.isEmpty
                      ? const Center(child: Text('No services defined.'))
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          itemCount: services.length,
                          itemBuilder: (context, index) {
                            final service = services[index];
                            return Card(
                              elevation: 2,
                              margin: const EdgeInsets.only(bottom: 12),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Colors.blue.withOpacity(0.1),
                                  child: const Icon(Icons.spa, color: Colors.blue),
                                ),
                                title: Text(service.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                                subtitle: Text(service.description, maxLines: 2, overflow: TextOverflow.ellipsis),
                                trailing: Text('\$${service.charges.toStringAsFixed(2)}', 
                                   style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                onTap: () {
                                  final history = provider.assignedServices
                                      .where((a) => a.serviceId == service.id)
                                      .toList()
                                      ..sort((a, b) => b.assignedAt.compareTo(a.assignedAt));
                                  
                                  final totalRevenue = history.where((h) => h.status.toLowerCase() == 'completed').length * service.charges;

                                  showModalBottomSheet(
                                    context: context,
                                    isScrollControlled: true,
                                    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
                                    builder: (context) => DraggableScrollableSheet(
                                      initialChildSize: 0.6,
                                      minChildSize: 0.4,
                                      maxChildSize: 0.9,
                                      expand: false,
                                      builder: (context, scrollController) => Padding(
                                        padding: const EdgeInsets.all(24),
                                        child: ListView(
                                          controller: scrollController,
                                          children: [
                                            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                                              Expanded(child: Text(service.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold))),
                                              Text('\$${service.charges.toStringAsFixed(2)}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue)),
                                            ]),
                                            const SizedBox(height: 16),
                                            const Text("Description", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                                            const SizedBox(height: 8),
                                            Text(service.description, style: const TextStyle(fontSize: 16)),
                                            const SizedBox(height: 16),
                                            Row(children: [
                                              Icon(service.isVisibleToGuest ? Icons.visibility : Icons.visibility_off, color: Colors.grey),
                                              const SizedBox(width: 8),
                                              Text(service.isVisibleToGuest ? "Visible to Guests" : "Hidden from Guests", style: const TextStyle(color: Colors.grey)),
                                            ]),
                                            const Divider(height: 32),
                                            const Text("Service History", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                            const SizedBox(height: 8),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                                              children: [
                                                _StatBadge("Total Requests", "${history.length}", Colors.blue),
                                                _StatBadge("Revenue", "\$${totalRevenue.toStringAsFixed(0)}", Colors.green),
                                              ],
                                            ),
                                            const SizedBox(height: 16),
                                            if (history.isEmpty)
                                              const Center(child: Text("No history found for this service", style: TextStyle(color: Colors.grey)))
                                            else
                                              ...history.take(10).map((h) => ListTile(
                                                contentPadding: EdgeInsets.zero,
                                                leading: const Icon(Icons.history, size: 20, color: Colors.grey),
                                                title: Text("Room ${h.roomNumber} - ${h.status.toUpperCase()}", style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                                                subtitle: Text("${h.assignedAt.split('T').first} • ${h.employeeName}", style: const TextStyle(fontSize: 12)),
                                                trailing: Text(h.status == 'completed' ? '+\$${service.charges.toInt()}' : '-', style: TextStyle(color: h.status == 'completed' ? Colors.green : Colors.grey, fontWeight: FontWeight.bold)),
                                              )),
                                            const SizedBox(height: 24),
                                            SizedBox(width: double.infinity, child: ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text("Close"))),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),
            ),
          ],
        );
      },
    );
  }
}

class ServiceActivityTab extends StatelessWidget {
  const ServiceActivityTab({super.key});

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed': return Colors.green;
      case 'pending': return Colors.orange;
      case 'cancelled': return Colors.red;
      case 'in_progress': return Colors.blue;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ServiceProvider>(
      builder: (context, provider, child) {
        final assigned = provider.assignedServices;

        // KPIs
        final totalAssigned = assigned.length;
        final pending = assigned.where((s) => s.status.toLowerCase() == 'pending').length;
        
        // Calculate Revenue (Approximate based on service charges)
        // Need to lookup service charge from services list
        double revenue = 0.0;
        for (var a in assigned) {
             if (a.status.toLowerCase() == 'completed') {
               // Find service in catalog
               final service = provider.services.firstWhere(
                 (s) => s.id == a.serviceId, 
                 orElse: () => ServiceModel(id: 0, name: '', description: '', charges: 0, isVisibleToGuest: false));
               revenue += service.charges;
             }
        }

        return Column(
          children: [
            // KPI Dashboard
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                   _KpiCard(
                    title: 'Requests',
                    value: '$totalAssigned',
                    icon: Icons.assignment,
                    color: Colors.blue,
                  ),
                  const SizedBox(width: 12),
                  _KpiCard(
                    title: 'Pending',
                    value: '$pending',
                    icon: Icons.pending_actions,
                    color: Colors.orange,
                  ),
                   const SizedBox(width: 12),
                  _KpiCard(
                    title: 'Revenue',
                    value: '\$${revenue.toStringAsFixed(0)}',
                    icon: Icons.attach_money,
                    color: Colors.green,
                  ),
                ],
              ),
            ),

            Expanded(
              child: provider.isLoading && assigned.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : assigned.isEmpty
                      ? const Center(child: Text('No assigned services found.'))
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          itemCount: assigned.length,
                          itemBuilder: (context, index) {
                            final item = assigned[index];
                            return Card(
                              elevation: 2,
                              margin: const EdgeInsets.only(bottom: 12),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: _getStatusColor(item.status).withOpacity(0.1),
                                  child: Icon(Icons.room_service, color: _getStatusColor(item.status)),
                                ),
                                title: Text('${item.serviceName} (Room ${item.roomNumber})'),
                                subtitle: Text('Assigned to: ${item.employeeName}\nAt: ${item.assignedAt.split("T").first}'),
                                trailing: Text(item.status.toUpperCase(), 
                                  style: TextStyle(fontWeight: FontWeight.bold, color: _getStatusColor(item.status))),
                              ),
                            );
                          },
                        ),
            ),
          ],
        );
      },
    );
  }
}

class ServiceRequestsTab extends StatelessWidget {
  const ServiceRequestsTab({super.key});

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed': return Colors.green;
      case 'pending': return Colors.orange;
      case 'cancelled': return Colors.red;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ServiceProvider>(
      builder: (context, provider, child) {
        final requests = provider.requests;

        // KPIs
        final totalRequests = requests.length;
        final pendingRequests = requests.where((r) => r.status.toLowerCase() == 'pending').length;
        final checkoutRequests = requests.where((r) => r.isCheckoutRequest).length;

        return Column(
          children: [
            // KPI Dashboard
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  _KpiCard(
                    title: 'Total',
                    value: '$totalRequests',
                    icon: Icons.inbox,
                    color: Colors.blue,
                  ),
                  const SizedBox(width: 12),
                  _KpiCard(
                    title: 'Pending',
                    value: '$pendingRequests',
                    icon: Icons.pending,
                    color: Colors.orange,
                  ),
                  const SizedBox(width: 12),
                  _KpiCard(
                    title: 'Checkouts',
                    value: '$checkoutRequests',
                    icon: Icons.playlist_add_check,
                    color: Colors.purple,
                  ),
                ],
              ),
            ),
            
            Expanded(
              child: provider.isLoading && requests.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : requests.isEmpty
                      ? const Center(child: Text('No service requests found.'))
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          itemCount: requests.length,
                          itemBuilder: (context, index) {
                            final request = requests[index];
                            final isCheckout = request.isCheckoutRequest;
                            
                            return Card(
                              elevation: 2,
                              margin: const EdgeInsets.only(bottom: 12),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: isCheckout ? Colors.purple.withOpacity(0.1) : Colors.blue.withOpacity(0.1),
                                  child: Icon(
                                    isCheckout ? Icons.playlist_add_check : Icons.room_service, 
                                    color: isCheckout ? Colors.purple : Colors.blue
                                  ),
                                ),
                                title: Text(isCheckout 
                                  ? 'Checkout Verify (Room ${request.roomNumber})' 
                                  : 'Service Request (Room ${request.roomNumber})'
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (request.description.isNotEmpty)
                                      Text(request.description, maxLines: 2, overflow: TextOverflow.ellipsis),
                                    const SizedBox(height: 4),
                                    Text('Status: ${request.status} • ${request.createdAt.split("T").first}',
                                      style: TextStyle(color: Colors.grey[600], fontSize: 12)
                                    ),
                                  ],
                                ),
                                trailing: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: _getStatusColor(request.status).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: _getStatusColor(request.status).withOpacity(0.5))
                                  ),
                                  child: Text(
                                    request.status.toUpperCase(),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold, 
                                      fontSize: 10,
                                      color: _getStatusColor(request.status)
                                    ),
                                  ),
                                ),
                                onTap: () {
                                  showModalBottomSheet(
                                    context: context,
                                    isScrollControlled: true,
                                    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
                                    builder: (context) => DraggableScrollableSheet(
                                      initialChildSize: 0.7,
                                      minChildSize: 0.5,
                                      maxChildSize: 0.95,
                                      expand: false,
                                      builder: (context, scrollController) {
                                        // Calculate Inventory Items
                                        final inventory = request.inventoryData ?? [];
                                        final damages = request.assetDamages ?? [];
                                        
                                        return Padding(
                                          padding: const EdgeInsets.all(24),
                                          child: ListView(
                                            controller: scrollController,
                                            children: [
                                              Row(children: [
                                                Icon(isCheckout ? Icons.playlist_add_check : Icons.room_service, size: 32, color: isCheckout ? Colors.purple : Colors.blue),
                                                const SizedBox(width: 16),
                                                Expanded(child: Text(isCheckout ? 'Checkout Verify' : 'Service Request', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
                                                Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: _getStatusColor(request.status).withOpacity(0.1), borderRadius: BorderRadius.circular(20)), child: Text(request.status.toUpperCase(), style: TextStyle(color: _getStatusColor(request.status), fontWeight: FontWeight.bold))),
                                              ]),
                                              const Divider(height: 32),
                                              _buildDetailRow("Room", "${request.roomNumber}"),
                                              if (request.description.isNotEmpty)
                                                 _buildDetailRow("Description", request.description),
                                              _buildDetailRow("Created At", request.createdAt.replaceAll("T", " ").substring(0, 16)),
                                              if (request.completedAt != null)
                                                _buildDetailRow("Completed At", request.completedAt!),
                                              
                                              if (isCheckout) ...[
                                                const Divider(height: 32),
                                                const Text("Inventory Checked", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.purple)),
                                                const SizedBox(height: 12),
                                                if (inventory.isEmpty)
                                                  const Text("No inventory data recorded.", style: TextStyle(color: Colors.grey))
                                                else
                                                  ...inventory.map((item) => ListTile(
                                                    contentPadding: EdgeInsets.zero,
                                                    dense: true,
                                                    title: Text(item['item_name'] ?? 'Unknown Item', style: const TextStyle(fontWeight: FontWeight.w500)),
                                                    trailing: Text("Qty: ${item['quantity'] ?? 0}"),
                                                  )),
                                                  
                                                if (damages.isNotEmpty) ...[
                                                   const Divider(height: 32),
                                                   const Text("Damages / Missing Assets", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red)),
                                                   const SizedBox(height: 12),
                                                   ...damages.map((item) => Card(
                                                     color: Colors.red.withOpacity(0.05),
                                                     elevation: 0,
                                                     margin: const EdgeInsets.only(bottom: 8),
                                                     child: ListTile(
                                                       dense: true,
                                                       leading: const Icon(Icons.broken_image, color: Colors.red),
                                                       title: Text(item['item_name'] ?? 'Asset', style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                                                        subtitle: Text("Damage: ${item['description'] ?? 'Reported'}"),
                                                        trailing: Text("\$${item['cost'] ?? 0}", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
                                                     ),
                                                   )),
                                                ]
                                              ],

                                              const SizedBox(height: 24),
                                              if (request.status.toLowerCase() == 'pending' || request.status.toLowerCase() == 'assigned')
                                                Row(
                                                  children: [
                                                    Expanded(child: ElevatedButton(onPressed: () { provider.updateRequestStatus(request.id, 'completed'); Navigator.pop(context); }, style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white), child: const Text("Mark Complete"))),
                                                    const SizedBox(width: 16),
                                                    Expanded(child: OutlinedButton(onPressed: () { provider.updateRequestStatus(request.id, 'cancelled'); Navigator.pop(context); }, style: OutlinedButton.styleFrom(foregroundColor: Colors.red), child: const Text("Cancel"))),
                                                  ],
                                                ),
                                              const SizedBox(height: 16),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),
            ),
          ],
        );
      },
    );
  }
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          Text(value, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}

class _KpiCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _KpiCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatBadge extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatBadge(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
          child: Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}
