import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import '../models/shopping_item.dart';

class ShoppingListProvider with ChangeNotifier {
  List<ShoppingItem> _items = [];
  final String _boxName = 'shopping_items';
  final _uuid = Uuid();

  List<ShoppingItem> get items => _items;

  List<ShoppingItem> get purchasedItems => _items.where((item) => item.isPurchased).toList();

  List<ShoppingItem> get unpurchasedItems => _items.where((item) => !item.isPurchased).toList();

  ShoppingListProvider() {
    _loadItems();
  }

  Future<void> _loadItems() async {
    final box = await Hive.openBox<ShoppingItem>(_boxName);
    _items = box.values.toList();
    notifyListeners();
  }

  Future<void> addItem(String name) async {
    final newItem = ShoppingItem(
      id: _uuid.v4(),
      name: name,
      createdAt: DateTime.now(),
    );

    final box = await Hive.openBox<ShoppingItem>(_boxName);
    await box.put(newItem.id, newItem);
    
    _items.add(newItem);
    notifyListeners();
  }

  Future<void> togglePurchasedStatus(String id) async {
    final index = _items.indexWhere((item) => item.id == id);
    if (index != -1) {
      _items[index].isPurchased = !_items[index].isPurchased;
      
      final box = await Hive.openBox<ShoppingItem>(_boxName);
      await box.put(_items[index].id, _items[index]);
      
      notifyListeners();
    }
  }

  Future<void> removeItem(String id) async {
    _items.removeWhere((item) => item.id == id);
    
    final box = await Hive.openBox<ShoppingItem>(_boxName);
    await box.delete(id);
    
    notifyListeners();
  }
  
  Future<void> clearCompletedItems() async {
    final itemsToRemove = _items.where((item) => item.isPurchased).toList();
    _items.removeWhere((item) => item.isPurchased);
    
    final box = await Hive.openBox<ShoppingItem>(_boxName);
    for (var item in itemsToRemove) {
      await box.delete(item.id);
    }
    
    notifyListeners();
    return Future.value();
  }
  
  Future<void> updateItem(String id, String newName) async {
    final index = _items.indexWhere((item) => item.id == id);
    if (index != -1) {
      _items[index].name = newName;
      
      final box = await Hive.openBox<ShoppingItem>(_boxName);
      await box.put(_items[index].id, _items[index]);
      
      notifyListeners();
    }
  }
} 