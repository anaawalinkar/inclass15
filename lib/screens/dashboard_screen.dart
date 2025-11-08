import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import '../models/item.dart';

class DashboardScreen extends StatelessWidget {
  final FirestoreService _firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Inventory Dashboard'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<Map<String, dynamic>>(
        stream: _firestoreService.getDashboardStats(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return Center(child: Text('Error loading dashboard data'));
          }

          final stats = snapshot.data!;
          final totalItems = stats['totalItems'] as int;
          final totalValue = stats['totalValue'] as double;
          final outOfStockItems = stats['outOfStockItems'] as List<Item>;
          final lowStockItems = stats['lowStockItems'] as List<Item>;

          return SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Inventory Overview',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20),

                // Statistics Cards
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        'Total Items',
                        totalItems.toString(),
                        Colors.blue,
                        Icons.inventory_2,
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: _buildStatCard(
                        'Total Value',
                        '\$${totalValue.toStringAsFixed(2)}',
                        Colors.green,
                        Icons.attach_money,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        'Out of Stock',
                        outOfStockItems.length.toString(),
                        Colors.red,
                        Icons.warning,
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: _buildStatCard(
                        'Low Stock',
                        lowStockItems.length.toString(),
                        Colors.orange,
                        Icons.warning_amber,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 30),

                // Out of Stock Items
                if (outOfStockItems.isNotEmpty) ...[
                  Text(
                    'Out of Stock Items',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  ...outOfStockItems.map((item) => Card(
                    color: Colors.red.shade50,
                    child: ListTile(
                      leading: Icon(Icons.warning, color: Colors.red),
                      title: Text(item.name),
                      subtitle: Text('Category: ${item.category} • Price: \$${item.price.toStringAsFixed(2)}'),
                      trailing: Text('Qty: ${item.quantity}'),
                    ),
                  )).toList(),
                  SizedBox(height: 20),
                ],

                // Low Stock Items
                if (lowStockItems.isNotEmpty) ...[
                  Text(
                    'Low Stock Items',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  ...lowStockItems.map((item) => Card(
                    color: Colors.orange.shade50,
                    child: ListTile(
                      leading: Icon(Icons.warning_amber, color: Colors.orange),
                      title: Text(item.name),
                      subtitle: Text('Category: ${item.category} • Price: \$${item.price.toStringAsFixed(2)}'),
                      trailing: Text('Qty: ${item.quantity}'),
                    ),
                  )).toList(),
                ],

                if (outOfStockItems.isEmpty && lowStockItems.isEmpty)
                  Center(
                    child: Column(
                      children: [
                        Icon(Icons.check_circle, size: 64, color: Colors.green),
                        SizedBox(height: 16),
                        Text(
                          'All items are well stocked!',
                          style: TextStyle(fontSize: 18, color: Colors.green),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color, IconData icon) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(icon, color: color, size: 40),
            SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              title,
              style: TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}