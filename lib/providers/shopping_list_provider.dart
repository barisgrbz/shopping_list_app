import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import 'dart:developer' as developer;
import '../models/shopping_item.dart';
import '../models/shopping_list.dart';
import '../utils/constants.dart';

class ShoppingListProvider with ChangeNotifier {
  // Alışveriş listeleri
  List<ShoppingList> _lists = [];
  String? _selectedListId;

  // Alışveriş ürünleri
  List<ShoppingItem> _items = [];

  // UUID üreteci
  final _uuid = Uuid();

  // Getters
  List<ShoppingList> get lists => _lists;
  ShoppingList? get selectedList =>
      _selectedListId != null
          ? _lists.firstWhere(
            (list) => list.id == _selectedListId,
            orElse: () => _lists.first,
          )
          : _lists.isNotEmpty
          ? _lists.first
          : null;

  String? get selectedListId => _selectedListId;
  List<ShoppingItem> get allItems => _items;

  List<ShoppingItem> get currentItems =>
      _items.where((item) => item.listId == selectedList?.id).toList();

  List<ShoppingItem> get currentPurchasedItems =>
      currentItems.where((item) => item.isPurchased).toList();

  List<ShoppingItem> get currentUnpurchasedItems =>
      currentItems.where((item) => !item.isPurchased).toList();

  // Constructor
  ShoppingListProvider() {
    _loadLists();
    _loadItems();
  }

  // Liste yükleme
  Future<void> _loadLists() async {
    final box = await Hive.openBox<ShoppingList>(Constants.listsBoxName);

    if (box.isEmpty) {
      // Varsayılan liste oluştur
      final defaultList = ShoppingList(
        id: _uuid.v4(),
        name: Constants.defaultListName,
        createdAt: DateTime.now(),
        itemCount: 0,
      );

      await box.put(defaultList.id, defaultList);
      _lists = [defaultList];
      _selectedListId = defaultList.id;
    } else {
      _lists = box.values.toList();
      _selectedListId = box.values.first.id;
    }

    notifyListeners();
  }

  // Ürünleri yükleme
  Future<void> _loadItems() async {
    final box = await Hive.openBox<ShoppingItem>(Constants.itemsBoxName);
    _items = box.values.toList();

    // Liste ürün sayılarını güncelle
    _updateListItemCounts();

    notifyListeners();
  }

  // Liste seçme
  void selectList(String listId) {
    _selectedListId = listId;
    notifyListeners();
  }

  // Yeni liste ekleme
  Future<void> addList(String name, {String? icon, String? color}) async {
    developer.log('ShoppingListProvider: Yeni liste ekleniyor - name: $name, icon: $icon, color: "$color"');
    
    final newList = ShoppingList.create(name: name, icon: icon, color: color);
    
    // Kayıt öncesi değerleri kontrol et
    developer.log('ShoppingListProvider: Oluşturulan liste - id: ${newList.id}, name: ${newList.name}, icon: ${newList.icon}, color: "${newList.color}"');

    final box = await Hive.openBox<ShoppingList>(Constants.listsBoxName);
    await box.put(newList.id, newList);

    _lists.add(newList);

    // Yeni liste oluşturulduktan sonra onu seç
    _selectedListId = newList.id;

    notifyListeners();
  }

  // Liste silme
  Future<void> removeList(String listId) async {
    // Silinecek liste ile ilgili tüm ürünleri bul ve sil
    final itemsToRemove =
        _items.where((item) => item.listId == listId).toList();

    // Ürünleri bellekten ve veritabanından sil
    for (var item in itemsToRemove) {
      await removeItem(item.id);
    }

    // Listeyi bellekten kaldır
    _lists.removeWhere((list) => list.id == listId);

    // Veritabanından listeyi sil
    final listsBox = await Hive.openBox<ShoppingList>(Constants.listsBoxName);
    await listsBox.delete(listId);

    // Eğer silinen liste, seçili liste ise başka bir liste seç
    if (_selectedListId == listId && _lists.isNotEmpty) {
      _selectedListId = _lists.first.id;
    } else if (_lists.isEmpty) {
      _selectedListId = null;
    }

    notifyListeners();
  }

  // Liste güncelleme
  Future<void> updateList(
    String id, {
    String? name,
    String? icon,
    String? color,
  }) async {
    developer.log('ShoppingListProvider: Liste güncelleniyor - id: $id, name: $name, icon: $icon, color: "$color"');
    
    final index = _lists.indexWhere((list) => list.id == id);
    if (index != -1) {
      if (name != null) _lists[index].name = name;
      if (icon != null) _lists[index].icon = icon;
      if (color != null) {
        developer.log('ShoppingListProvider: Eski renk: "${_lists[index].color}", Yeni renk: "$color"');
        _lists[index].color = color;
      }

      final box = await Hive.openBox<ShoppingList>(Constants.listsBoxName);
      await box.put(_lists[index].id, _lists[index]);
      
      developer.log('ShoppingListProvider: Güncelleme sonrası liste - id: ${_lists[index].id}, name: ${_lists[index].name}, icon: ${_lists[index].icon}, color: "${_lists[index].color}"');

      notifyListeners();
    }
  }

  // Ürün ekleme
  Future<void> addItem(String name) async {
    // Eğer seçili liste yoksa, ekleme yapma
    if (selectedList == null) return;

    final newItem = ShoppingItem.create(name: name, listId: selectedList!.id);

    final itemsBox = await Hive.openBox<ShoppingItem>(Constants.itemsBoxName);
    await itemsBox.put(newItem.id, newItem);

    _items.add(newItem);
    _updateListItemCounts();

    notifyListeners();
  }

  // Ürün durumu değiştirme
  Future<void> togglePurchasedStatus(String id) async {
    final index = _items.indexWhere((item) => item.id == id);
    if (index != -1) {
      _items[index].isPurchased = !_items[index].isPurchased;

      final box = await Hive.openBox<ShoppingItem>(Constants.itemsBoxName);
      await box.put(_items[index].id, _items[index]);

      notifyListeners();
    }
  }

  // Ürün silme
  Future<void> removeItem(String id) async {
    _items.removeWhere((item) => item.id == id);

    final box = await Hive.openBox<ShoppingItem>(Constants.itemsBoxName);
    await box.delete(id);

    _updateListItemCounts();
    notifyListeners();
  }

  // Tamamlanan ürünleri temizleme (mevcut listede)
  Future<void> clearCompletedItems() async {
    if (selectedList == null) return;

    final itemsToRemove =
        _items
            .where(
              (item) => item.listId == selectedList!.id && item.isPurchased,
            )
            .toList();

    _items.removeWhere(
      (item) => item.listId == selectedList!.id && item.isPurchased,
    );

    final box = await Hive.openBox<ShoppingItem>(Constants.itemsBoxName);
    for (var item in itemsToRemove) {
      await box.delete(item.id);
    }

    _updateListItemCounts();
    notifyListeners();
  }

  // Ürün güncelleme
  Future<void> updateItem(String id, String newName) async {
    final index = _items.indexWhere((item) => item.id == id);
    if (index != -1) {
      _items[index].name = newName;

      final box = await Hive.openBox<ShoppingItem>(Constants.itemsBoxName);
      await box.put(_items[index].id, _items[index]);

      notifyListeners();
    }
  }

  // Ürün taşıma (bir listeden diğerine)
  Future<void> moveItem(String itemId, String targetListId) async {
    final index = _items.indexWhere((item) => item.id == itemId);
    if (index != -1) {
      _items[index].listId = targetListId;

      final box = await Hive.openBox<ShoppingItem>(Constants.itemsBoxName);
      await box.put(_items[index].id, _items[index]);

      _updateListItemCounts();
      notifyListeners();
    }
  }

  // Liste ürün sayılarını güncelleme
  void _updateListItemCounts() {
    // Her listenin ürün sayısını hesapla
    for (var list in _lists) {
      final count = _items.where((item) => item.listId == list.id).length;
      list.itemCount = count;
    }

    // Listeyi veritabanında güncelle
    _saveLists();
  }

  // Listeleri veritabanına kaydetme
  Future<void> _saveLists() async {
    final box = await Hive.openBox<ShoppingList>(Constants.listsBoxName);
    for (var list in _lists) {
      await box.put(list.id, list);
    }
  }
}
