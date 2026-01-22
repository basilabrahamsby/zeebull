import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../../data/services/api_service.dart';

class CheckoutVerificationDialog extends StatefulWidget {
  final String roomNumber;
  final Function() onSuccess;

  const CheckoutVerificationDialog({
    Key? key,
    required this.roomNumber,
    required this.onSuccess,
  }) : super(key: key);

  @override
  State<CheckoutVerificationDialog> createState() => _CheckoutVerificationDialogState();
}

class _CheckoutVerificationDialogState extends State<CheckoutVerificationDialog> {
  bool _isLoading = true;
  String? _errorMessage;
  int? _requestId;
  
  List<Map<String, dynamic>> _fixedAssets = [];
  List<Map<String, dynamic>> _consumables = [];
  String _notes = "";

  @override
  void initState() {
    super.initState();
    _fetchRequestIdAndData();
  }

  Future<void> _fetchRequestIdAndData() async {
    try {
      final dio = ApiService().dio;
      // Step 1: Get Checkout Request ID by Room Number
      final idRes = await dio.get('/bill/checkout-request/${widget.roomNumber}');
      
      if (idRes.statusCode == 200 && idRes.data != null && idRes.data['exists'] == true) {
         _requestId = idRes.data['request_id'];
         
         // Step 2: Get Inventory Details
         await _fetchInventoryDetails();
      } else {
         if (mounted) setState(() {
             _errorMessage = "No active checkout request found for Room ${widget.roomNumber}";
             _isLoading = false;
         });
      }
    } catch (e) {
      if (mounted) setState(() {
          _errorMessage = "Error finding checkout request: $e";
          _isLoading = false;
      });
    }
  }

  Future<void> _fetchInventoryDetails() async {
    try {
      final dio = ApiService().dio;
      final res = await dio.get('/bill/checkout-request/$_requestId/inventory-details');
      
      if (res.statusCode == 200 && res.data != null) {
        final data = res.data;
        final items = (data['items'] as List?) ?? [];
        
        final fixed = <Map<String, dynamic>>[];
        final cons = <Map<String, dynamic>>[];
        
        for (var i in items) {
           final m = Map<String, dynamic>.from(i);
           
           // Normalize keys based on backend response
           // Backend keys: current_stock, is_fixed_asset, replacement_cost, charge_per_unit, complimentary_limit
           
           if (m['is_fixed_asset'] == true) {
             m['damaged'] = false;
             m['notes'] = "";
             m['cost'] = m['replacement_cost']; // Map for display
             fixed.add(m);
           } else {
             m['available'] = m['current_stock']; // Default available to current
             cons.add(m);
           }
        }
        
        if (mounted) {
          setState(() {
            _fixedAssets = fixed;
            _consumables = cons;
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) setState(() => _errorMessage = "Failed to load inventory: $e");
    }
  }

  Future<void> _submit() async {
    setState(() => _isLoading = true);
    try {
      final dio = ApiService().dio;
      
      final assetDamages = _fixedAssets.where((a) => a['damaged'] == true).map((a) {
         return {
            'item_name': a['name'],
            'replacement_cost': double.tryParse(a['replacement_cost']?.toString() ?? '0') ?? 0.0,
            'notes': a['notes'],
            'item_id': a['item_id'],
         };
      }).toList();

      final items = _consumables.map((c) {
         double current = double.tryParse(c['current_stock']?.toString() ?? '0') ?? 0;
         double available = double.tryParse(c['available'].toString()) ?? 0;
         double used = current - available;
         if (used < 0) used = 0;
         
         return {
           'item_id': c['item_id'],
           'used_qty': used, 
           'missing_qty': 0,
           'damage_qty': 0,
         };
      }).toList();

      final payload = {
        'inventory_notes': _notes,
        'items': items,
        'asset_damages': assetDamages,
      };

      await dio.post('/bill/checkout-request/$_requestId/check-inventory', data: payload);
      
      if (mounted) {
         Navigator.pop(context);
         widget.onSuccess();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = "Submission Error: $e";
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Checkout Verification"),
          Text("Room ${widget.roomNumber}", style: const TextStyle(fontSize: 14, color: Colors.grey)),
        ],
      ),
      content: _isLoading 
          ? const SizedBox(height: 100, child: Center(child: CircularProgressIndicator())) 
          : SizedBox(
              width: double.maxFinite,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                     if (_errorMessage != null) 
                       Padding(
                         padding: const EdgeInsets.only(bottom: 8.0),
                         child: Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
                       ),
                     
                     if (_fixedAssets.isNotEmpty) ...[
                       _sectionHeader("Fixed Assets Check", Colors.red),
                       ..._fixedAssets.map(_buildFixedAssetRow),
                       const SizedBox(height: 16),
                     ],
                     
                     if (_consumables.isNotEmpty) ...[
                       _sectionHeader("Consumables Inventory Check", Colors.blue),
                       ..._consumables.map(_buildConsumableRow),
                       const SizedBox(height: 16),
                     ],

                     if (_fixedAssets.isEmpty && _consumables.isEmpty)
                        const Padding(padding: EdgeInsets.all(20), child: Text("No items to verify.")),
                     
                     TextField(
                        decoration: const InputDecoration(
                          labelText: "Inventory Notes (Optional)",
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (v) => _notes = v,
                        maxLines: 2,
                     ),
                  ],
                ),
              ),
            ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context), 
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: _isLoading || (_requestId == null) ? null : _submit,
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
          child: const Text("Complete"),
        ),
      ],
    );
  }

  Widget _sectionHeader(String title, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      width: double.infinity,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        "  $title", 
        style: TextStyle(color: color, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildFixedAssetRow(Map<String, dynamic> item) {
     return Card(
       margin: const EdgeInsets.symmetric(vertical: 4),
       child: Padding(
         padding: const EdgeInsets.all(8.0),
         child: Column(
           children: [
             Row(
               children: [
                 Expanded(child: Text(item['name'], style: const TextStyle(fontWeight: FontWeight.bold))),
                 if (item['replacement_cost'] != null) Text("Cost: ${item['replacement_cost']}", style: const TextStyle(fontSize: 12, color: Colors.grey)),
               ],
             ),
             if (item['serial_number'] != null)
                Row(children: [Text("Serial: ${item['serial_number']}", style: TextStyle(color: Colors.grey[600]))]),
             Row(
               children: [
                 const Text("Damaged?"),
                 Checkbox(
                   value: item['damaged'], 
                   onChanged: (v) => setState(() => item['damaged'] = v)
                 ),
               ],
             ),
             if (item['damaged'] == true)
                TextField(
                   decoration: const InputDecoration(labelText: "Damage Notes", isDense: true),
                   onChanged: (v) => item['notes'] = v,
                )
           ],
         ),
       ),
     );
  }

  Widget _buildConsumableRow(Map<String, dynamic> item) {
     double current = double.tryParse(item['current_stock']?.toString() ?? '0') ?? 0;
     double available = double.tryParse(item['available'].toString()) ?? current;
     double consumed = current - available;
     
     double rate = double.tryParse(item['charge_per_unit']?.toString() ?? '0') ?? 0;
     double freeLimit = double.tryParse(item['complimentary_limit']?.toString() ?? '0') ?? 0;
     
     double chargeable = consumed - freeLimit;
     if (chargeable < 0) chargeable = 0;
     
     double potentialCharge = chargeable * rate;

     return Card(
       margin: const EdgeInsets.symmetric(vertical: 4),
       child: Padding(
         padding: const EdgeInsets.all(8.0),
         child: Column(
           children: [
              Row(
                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
                 children: [
                    Expanded(child: Text(item['name'], style: const TextStyle(fontWeight: FontWeight.bold))),
                    Text("Stock: ${current.toInt()}"),
                 ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                   const Text("Available: "),
                   SizedBox(
                     width: 60, 
                     child: TextFormField(
                       initialValue: available.toString(),
                       keyboardType: TextInputType.number,
                       decoration: const InputDecoration(isDense: true, border: OutlineInputBorder(), contentPadding: EdgeInsets.all(8)),
                       onChanged: (v) {
                          setState(() {
                             item['available'] = double.tryParse(v) ?? 0;
                          });
                       },
                     )
                   ),
                   const SizedBox(width: 8),
                   Expanded(
                     child: Column(
                       crossAxisAlignment: CrossAxisAlignment.end,
                       children: [
                         Text("Used: ${consumed.toInt()}", style: const TextStyle(color: Colors.red)),
                         if (potentialCharge > 0)
                            Text("Charge: ₹${potentialCharge.toStringAsFixed(0)}", style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                         if (freeLimit > 0)
                            Text("Free: ${freeLimit.toInt()}", style: const TextStyle(color: Colors.green, fontSize: 10)),
                       ],
                     ),
                   )
                ],
              )
           ],
         ),
       ),
     );
  }
}
