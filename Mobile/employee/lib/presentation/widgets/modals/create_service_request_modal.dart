import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:orchid_employee/presentation/providers/service_request_provider.dart';
import 'package:orchid_employee/presentation/providers/room_provider.dart';
import 'package:orchid_employee/presentation/providers/auth_provider.dart';
import 'package:orchid_employee/core/constants/app_colors.dart';
import 'dart:ui';

class CreateServiceRequestModal extends StatefulWidget {
  final int? initialRoomId;
  const CreateServiceRequestModal({super.key, this.initialRoomId});

  @override
  State<CreateServiceRequestModal> createState() => _CreateServiceRequestModalState();
}

class _CreateServiceRequestModalState extends State<CreateServiceRequestModal> {
  final _formKey = GlobalKey<FormState>();
  int? _selectedRoomId;
  String? _selectedType;
  String _selectedPriority = 'Medium';
  final _descController = TextEditingController();
  
  bool _isSubmitting = false;

  final List<String> _priorities = ['Low', 'Medium', 'High', 'Urgent'];

  @override
  void initState() {
    super.initState();
    _selectedRoomId = widget.initialRoomId;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ServiceRequestProvider>().fetchServiceDefinitions();
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedRoomId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a table/room")),
      );
      return;
    }
    
    setState(() => _isSubmitting = true);
    
    try {
      final provider = context.read<ServiceRequestProvider>();
      final auth = context.read<AuthProvider>();
      
      final success = await provider.createServiceRequest(
        roomId: _selectedRoomId!,
        type: _selectedType ?? 'Other',
        description: _descController.text,
        priority: _selectedPriority,
        employeeId: auth.employeeId, // Assign to self by default as waiter creating it
      );
      
      if (mounted) {
        if (success) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Service request created successfully")),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Failed to create service request")),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final roomProvider = context.watch<RoomProvider>();
    final requestProvider = context.watch<ServiceRequestProvider>();
    final rooms = roomProvider.rooms.where((r) {
      final s = r.status.toLowerCase();
      return s == 'occupied' || s == 'checked_in' || s == 'booked';
    }).toList();

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: BoxDecoration(
        color: AppColors.onyx.withOpacity(0.95),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        border: Border.all(color: Colors.white10),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40, height: 4,
                    margin: const EdgeInsets.only(bottom: 24),
                    decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(2)),
                  ),
                ),
                const Text(
                  "CREATE SERVICE REQUEST",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 2),
                ),
                const SizedBox(height: 8),
                Text(
                  "Assign a new task for a specific table or room.",
                  style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 11),
                ),
                const SizedBox(height: 24),

                // Room Selection
                _buildDropdown<int>(
                  label: "SELECT TABLE / ROOM",
                  value: _selectedRoomId,
                  items: rooms.map((r) => DropdownMenuItem<int>(
                    value: r.id,
                    child: Text(r.roomNumber),
                  )).toList(),
                  onChanged: (val) => setState(() => _selectedRoomId = val),
                  icon: Icons.meeting_room_rounded,
                ),
                const SizedBox(height: 16),

                // Service Type
                _buildDropdown<String>(
                  label: "SERVICE TYPE",
                  value: _selectedType,
                  items: requestProvider.serviceDefinitions.map((s) => DropdownMenuItem<String>(
                    value: s['name'].toString(),
                    child: Text(s['name'].toString().toUpperCase()),
                  )).toList(),
                  onChanged: (val) => setState(() => _selectedType = val!),
                  icon: Icons.room_service_rounded,
                ),
                const SizedBox(height: 16),

                // Priority
                _buildDropdown<String>(
                  label: "PRIORITY",
                  value: _selectedPriority,
                  items: _priorities.map((p) => DropdownMenuItem<String>(
                    value: p,
                    child: Text(p.toUpperCase()),
                  )).toList(),
                  onChanged: (val) => setState(() => _selectedPriority = val!),
                  icon: Icons.priority_high_rounded,
                ),
                const SizedBox(height: 16),

                // Description
                TextFormField(
                  controller: _descController,
                  maxLines: 3,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  decoration: InputDecoration(
                    labelText: "DESCRIPTION",
                    labelStyle: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 13),
                    prefixIcon: Icon(Icons.description_outlined, color: AppColors.accent.withOpacity(0.7), size: 20),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.05),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.white.withOpacity(0.05))),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.accent)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  ),
                ),
                
                const SizedBox(height: 32),
                
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      foregroundColor: AppColors.onyx,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    child: _isSubmitting
                        ? const CircularProgressIndicator(color: AppColors.onyx)
                        : const Text("CREATE REQUEST", style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5)),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown<T>({
    required String label,
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButtonFormField<T>(
          value: value,
          items: items,
          onChanged: onChanged,
          validator: (val) => val == null ? "Required" : null,
          dropdownColor: AppColors.onyx,
          icon: Icon(Icons.arrow_drop_down_rounded, color: AppColors.accent.withOpacity(0.5)),
          decoration: InputDecoration(
            labelText: label,
            labelStyle: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1),
            prefixIcon: Icon(icon, color: AppColors.accent.withOpacity(0.7), size: 20),
            border: InputBorder.none,
          ),
          style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
