import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/inventory_provider.dart';

class RecipesScreen extends StatefulWidget {
  const RecipesScreen({super.key});

  @override
  State<RecipesScreen> createState() => _RecipesScreenState();
}

class _RecipesScreenState extends State<RecipesScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        Provider.of<InventoryProvider>(context, listen: false).fetchRecipes());
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<InventoryProvider>(context);
    final recipes = provider.recipes;
    
    // KPIs
    int totalRecipes = recipes.length;
    double avgCost = 0;
    int totalIngredients = 0;
    
    if (recipes.isNotEmpty) {
      double sumCost = 0;
      for (var r in recipes) {
        sumCost += (r['cost_per_serving'] ?? 0).toDouble();
        totalIngredients += ((r['ingredients'] as List?)?.length ?? 0);
      }
      avgCost = sumCost / recipes.length;
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Compositions / Recipes'), elevation: 0),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Dashboard (Always Visible)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  color: Theme.of(context).primaryColor.withOpacity(0.05),
                  child: Row(
                    children: [
                      Expanded(child: _kpi("Total Recipes", "$totalRecipes", Colors.deepPurple)),
                      const SizedBox(width: 12),
                      Expanded(child: _kpi("Avg Cost", "₹${avgCost.toStringAsFixed(0)}", Colors.green)),
                      const SizedBox(width: 12),
                      Expanded(child: _kpi("Ingredients", "$totalIngredients", Colors.orange)),
                    ],
                  ),
                ),

                Expanded(
                  child: recipes.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.restaurant_menu, size: 64, color: Colors.grey.shade300),
                              const SizedBox(height: 16),
                              const Text("No recipes found", style: TextStyle(color: Colors.grey)),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: provider.recipes.length,
                          itemBuilder: (context, index) {
                            final recipe = provider.recipes[index];
                            final ingredients = recipe['ingredients'] as List<dynamic>;

                            return Card(
                              elevation: 2,
                              margin: const EdgeInsets.only(bottom: 12),
                              child: ExpansionTile(
                                leading: CircleAvatar(
                                  backgroundColor: Colors.deepPurple.shade100,
                                  child: const Icon(Icons.restaurant_menu, color: Colors.deepPurple),
                                ),
                                title: Text(recipe['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                                subtitle: Text("Cost: ₹${(recipe['total_cost'] ?? 0).toStringAsFixed(2)} per serving"),
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.stretch,
                                      children: [
                                        const Divider(),
                                        Text("Ingredients:",
                                            style: TextStyle(color: Colors.grey.shade700, fontWeight: FontWeight.bold)),
                                        const SizedBox(height: 8),
                                        ...ingredients.map((ing) => Padding(
                                              padding: const EdgeInsets.only(bottom: 4),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Expanded(
                                                      child:
                                                          Text("• ${ing['inventory_item_name'] ?? 'Unknown'}")),
                                                  Text("${ing['quantity']} ${ing['unit']}"),
                                                ],
                                              ),
                                            )),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
  
  Widget _kpi(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(10), 
        border: Border.all(color: color.withOpacity(0.2))
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
           Text(title, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
           const SizedBox(height: 4),
           Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}
