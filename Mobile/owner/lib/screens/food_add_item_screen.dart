import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/food_provider.dart';
import '../models/food_item.dart';

class FoodAddItemScreen extends StatefulWidget {
  final FoodItem? item;
  const FoodAddItemScreen({super.key, this.item});

  @override
  State<FoodAddItemScreen> createState() => _FoodAddItemScreenState();
}

class _FoodAddItemScreenState extends State<FoodAddItemScreen> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  String _description = '';
  double _price = 0;
  int? _selectedCategoryId;
  bool _isLoading = false;
  bool _isInit = false;

  @override
  void initState() {
    super.initState();
    if (widget.item != null) {
      _name = widget.item!.name;
      _description = widget.item!.description;
      _price = widget.item!.price;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInit && widget.item != null) {
      final provider = Provider.of<FoodProvider>(context, listen: false);
      // Try to match category name to ID
      try {
        final cat = provider.categories.firstWhere(
          (c) => c['name'] == widget.item!.category,
          orElse: () => null,
        );
        if (cat != null) {
          _selectedCategoryId = cat['id'];
        }
      } catch (e) {
        // ignore
      }
      _isInit = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<FoodProvider>(context);
    final categories = provider.categories;
    final isEditing = widget.item != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? "Edit Menu Item" : "Add New Menu Item")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  initialValue: _name,
                  decoration: const InputDecoration(
                    labelText: "Item Name",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.fastfood),
                  ),
                  validator: (val) => val == null || val.isEmpty ? "Required" : null,
                  onSaved: (val) => _name = val!,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  initialValue: _price > 0 ? _price.toString() : '',
                  decoration: const InputDecoration(
                    labelText: "Price (₹)",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.currency_rupee),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (val) => val == null || double.tryParse(val) == null ? "Invalid price" : null,
                  onSaved: (val) => _price = double.parse(val!),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<int>(
                  decoration: const InputDecoration(
                    labelText: "Category",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.category),
                  ),
                  value: _selectedCategoryId,
                  items: categories.map<DropdownMenuItem<int>>((c) {
                    return DropdownMenuItem<int>(
                      value: c['id'],
                      child: Text(c['name'] ?? 'Unknown'),
                    );
                  }).toList(),
                  onChanged: (val) {
                     setState(() => _selectedCategoryId = val);
                  },
                  validator: (val) => val == null ? "Required" : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  initialValue: _description,
                  decoration: const InputDecoration(
                    labelText: "Description",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.description),
                  ),
                  maxLines: 3,
                  onSaved: (val) => _description = val ?? '',
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      foregroundColor: Colors.white
                    ),
                    onPressed: _isLoading ? null : _submit,
                    child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : Text(isEditing ? "Update Item" : "Create Item"),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() => _isLoading = true);
    try {
      final data = {
        'name': _name,
        'description': _description,
        'price': _price,
        'category_id': _selectedCategoryId,
        'available': widget.item != null ? widget.item!.isAvailable : true,
      };

      if (widget.item != null) {
        await Provider.of<FoodProvider>(context, listen: false).updateFoodItem(widget.item!.id, data);
      } else {
        await Provider.of<FoodProvider>(context, listen: false).addFoodItem(data);
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(widget.item != null ? "Item updated" : "Item created")));
      }

    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
