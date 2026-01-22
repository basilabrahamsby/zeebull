import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/inventory_provider.dart';
import '../models/inventory_item.dart';
import 'package:intl/intl.dart';

class InventoryItemDetailScreen extends StatefulWidget {
  final InventoryItem item;
  const InventoryItemDetailScreen({super.key, required this.item});

  @override
  State<InventoryItemDetailScreen> createState() => _InventoryItemDetailScreenState();
}

class _InventoryItemDetailScreenState extends State<InventoryItemDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<dynamic> _stocks = [];
  List<dynamic> _transactions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  void _loadData() async {
    final provider = Provider.of<InventoryProvider>(context, listen: false);
    final stocks = await provider.fetchItemStocks(widget.item.id);
    final transactions = await provider.fetchItemTransactions(widget.item.id);
    
    if (mounted) {
      setState(() {
        _stocks = stocks;
        _transactions = transactions;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.item.name), elevation: 0),
      body: Column(
        children: [
          _buildHeader(),
          TabBar(
            controller: _tabController,
            labelColor: Colors.blue,
            unselectedLabelColor: Colors.grey,
            tabs: const [Tab(text: "Stock Locations"), Tab(text: "History")],
          ),
          Expanded(
            child: _isLoading 
              ? const Center(child: CircularProgressIndicator())
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildStockList(),
                    _buildTransactionList(),
                  ],
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final item = widget.item;
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(item.category, style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: item.isLowStock ? Colors.red.shade50 : Colors.green.shade50, borderRadius: BorderRadius.circular(4)),
                child: Text(item.isLowStock ? "Low Stock" : "In Stock", style: TextStyle(color: item.isLowStock ? Colors.red : Colors.green, fontWeight: FontWeight.bold, fontSize: 12)),
              )
            ],
          ),
          const SizedBox(height: 8),
          Text("Min: ${item.minQuantity} ${item.unit} | Current: ${item.quantity} ${item.unit}", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(
             children: [
                Expanded(child: _infoItem("Price", "₹${item.price}")),
                Expanded(child: _infoItem("Vendor", item.lastVendor ?? "-")),
                Expanded(child: _infoItem("SKU", item.itemCode ?? "-")),
             ],
          )
        ],
      ),
    );
  }

  Widget _infoItem(String label, String val) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
         Text(label, style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
         Text(val, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis),
      ],
    );
  }

  Widget _buildStockList() {
    if (_stocks.isEmpty) return const Center(child: Text("No specific location data"));
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _stocks.length,
      itemBuilder: (context, index) {
         final stock = _stocks[index];
         return Card(
           child: ListTile(
             leading: const Icon(Icons.warehouse, color: Colors.indigo),
             title: Text(stock['location_name'] ?? 'Unknown Location'),
             trailing: Text("${stock['quantity']} ${widget.item.unit}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
           ),
         );
      },
    );
  }

  Widget _buildTransactionList() {
    if (_transactions.isEmpty) return const Center(child: Text("No transaction history"));

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _transactions.length,
      itemBuilder: (context, index) {
        final txn = _transactions[index];
        bool isIn = txn['transaction_type'] == 'in' || (txn['transaction_type'] == 'adjustment' && (txn['quantity'] ?? 0) > 0);
        final date = DateTime.tryParse(txn['created_at']) ?? DateTime.now();
        
        return ListTile(
           dense: true,
           leading: Icon(isIn ? Icons.arrow_downward : Icons.arrow_upward, color: isIn ? Colors.green : Colors.red, size: 16),
           title: Text("${txn['transaction_type'].toUpperCase()} - ${DateFormat('MMM d').format(date)}"),
           subtitle: Text(txn['notes'] ?? ''),
           trailing: Text(
             "${isIn ? '+' : ''}${txn['quantity']}",
             style: TextStyle(color: isIn ? Colors.green : Colors.red, fontWeight: FontWeight.bold),
           ),
        );
      },
    );
  }
}
