import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/item.dart';

class FirestoreService {
  final CollectionReference itemsCollection =
      FirebaseFirestore.instance.collection('items');

  // CREATE
  Future<void> addItem(Item item) async {
    try {
      await itemsCollection.add(item.toMap());
    } catch (e) {
      throw Exception('Failed to add item: $e');
    }
  }

  // READ - Real-time stream
  Stream<List<Item>> getItemsStream() {
    return itemsCollection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Item.fromMap(doc.id, doc.data() as Map<String, dynamic>))
            .toList());
  }

  // UPDATE
  Future<void> updateItem(Item item) async {
    try {
      if (item.id == null) throw Exception('Item ID is null');
      await itemsCollection.doc(item.id).update(item.toMap());
    } catch (e) {
      throw Exception('Failed to update item: $e');
    }
  }

  // DELETE
  Future<void> deleteItem(String itemId) async {
    try {
      await itemsCollection.doc(itemId).delete();
    } catch (e) {
      throw Exception('Failed to delete item: $e');
    }
  }

  // Enhanced Feature 1: Search
  Stream<List<Item>> searchItems(String query) {
    return itemsCollection
        .orderBy('name')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Item.fromMap(doc.id, doc.data() as Map<String, dynamic>))
            .where((item) => item.name.toLowerCase().contains(query.toLowerCase()))
            .toList());
  }

  // Enhanced Feature 1: Filter by category
  Stream<List<Item>> getItemsByCategory(String category) {
    if (category == 'All') {
      return getItemsStream();
    }
    return itemsCollection
        .where('category', isEqualTo: category)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Item.fromMap(doc.id, doc.data() as Map<String, dynamic>))
            .toList());
  }

  // Enhanced Feature 2: Get dashboard statistics
  Stream<Map<String, dynamic>> getDashboardStats() {
    return itemsCollection.snapshots().map((snapshot) {
      final items = snapshot.docs
          .map((doc) => Item.fromMap(doc.id, doc.data() as Map<String, dynamic>))
          .toList();

      final totalItems = items.length;
      final totalValue = items.fold(0.0, (sum, item) => sum + item.totalValue);
      final outOfStockItems = items.where((item) => item.isOutOfStock).toList();
      final lowStockItems = items.where((item) => item.isLowStock && !item.isOutOfStock).toList();
      final categories = items.map((item) => item.category).toSet().toList();

      return {
        'totalItems': totalItems,
        'totalValue': totalValue,
        'outOfStockItems': outOfStockItems,
        'lowStockItems': lowStockItems,
        'categories': categories,
      };
    });
  }
}

