import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import '../models/shopping_item.dart';
import '../models/shopping_list.dart';
import '../utils/constants.dart';
import '../utils/app_logger.dart';

class ShoppingListProvider with ChangeNotifier {
  // Alışveriş listeleri
  List<ShoppingList> _lists = [];
  String? _selectedListId;

  // Alışveriş ürünleri
  List<ShoppingItem> _items = [];
  
  // En son silinen ürün (geri alma için)
  ShoppingItem? _lastDeletedItem;

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

  // Arama işlevi
  List<ShoppingItem> searchItems(String query, {bool searchAllLists = false}) {
    if (query.isEmpty) {
      return searchAllLists ? allItems : currentItems;
    }
    
    final lowercaseQuery = query.toLowerCase();
    final itemsToSearch = searchAllLists ? allItems : currentItems;
    
    return itemsToSearch
        .where((item) => item.name.toLowerCase().contains(lowercaseQuery))
        .toList();
  }

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
    _logListOperation('Yeni liste ekleniyor', name: name, icon: icon, color: color);
    
    final newList = ShoppingList.create(name: name, icon: icon, color: color);
    
    _logListDetails('Oluşturulan liste', newList);

    await _saveListToDatabase(newList);
    _lists.add(newList);
    
    // Eğer ilk eklenen listeyse, onu seçili hale getir
    if (_lists.length == 1) {
      _selectedListId = newList.id;
    }
    
    notifyListeners();
  }
  
  /// Liste verilerini loglama
  void _logListDetails(String prefix, ShoppingList list) {
    AppLogger.log('ShoppingListProvider', '$prefix - id: ${list.id}, name: ${list.name}, icon: ${list.icon}, color: "${list.color}"');
  }
  
  /// Liste işlem bilgilerini loglama
  void _logListOperation(String operation, {String? id, String? name, String? icon, String? color}) {
    if (id != null) {
      AppLogger.log('ShoppingListProvider', '$operation - id: $id, name: $name, icon: $icon, color: "$color"');
    } else {
      AppLogger.log('ShoppingListProvider', '$operation - name: $name, icon: $icon, color: "$color"');
    }
  }
  
  /// Listeyi veritabanına kaydetme
  Future<void> _saveListToDatabase(ShoppingList list) async {
    final box = await Hive.openBox<ShoppingList>(Constants.listsBoxName);
    await box.put(list.id, list);
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

  /// Liste güncelleme
  Future<void> updateList(
    String id, {
    String? name,
    String? icon,
    String? color,
  }) async {
    _logListOperation('Liste güncelleniyor', id: id, name: name, icon: icon, color: color);
    
    final index = _lists.indexWhere((list) => list.id == id);
    if (index != -1) {
      if (name != null) _lists[index].name = name;
      if (icon != null) _lists[index].icon = icon;
      if (color != null) {
        AppLogger.log('ShoppingListProvider', 'Eski renk: "${_lists[index].color}", Yeni renk: "$color"');
        _lists[index].color = color;
      }

      await _saveListToDatabase(_lists[index]);
      _logListDetails('Güncelleme sonrası liste', _lists[index]);

      notifyListeners();
    }
  }

  // Ürün ekleme
  Future<void> addItem(String name, {String category = Constants.defaultCategory}) async {
    // Eğer seçili liste yoksa, ekleme yapma
    if (selectedList == null) return;

    final newItem = ShoppingItem.create(
      name: name, 
      listId: selectedList!.id, 
      category: category,
    );

    final itemsBox = await Hive.openBox<ShoppingItem>(Constants.itemsBoxName);
    await itemsBox.put(newItem.id, newItem);

    _items.add(newItem);
    _updateListItemCounts();

    notifyListeners();
  }

  // Belirli detaylarla ürün ekleme (geri alma işlemi için)
  Future<void> addItemWithDetails({
    required String name, 
    required String listId, 
    required bool isPurchased,
    String category = Constants.defaultCategory,
  }) async {
    // Yeni ürün oluştur
    final newItem = ShoppingItem(
      id: _uuid.v4(),
      name: name,
      isPurchased: isPurchased,
      createdAt: DateTime.now(),
      listId: listId,
      category: category,
    );

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
    // Silmeden önce ürünü saklayalım (geri alma için)
    final index = _items.indexWhere((item) => item.id == id);
    if (index != -1) {
      _lastDeletedItem = _items[index];
    }
    
    _items.removeWhere((item) => item.id == id);

    final box = await Hive.openBox<ShoppingItem>(Constants.itemsBoxName);
    await box.delete(id);

    _updateListItemCounts();
    notifyListeners();
  }
  
  // Son silinen ürünü geri yükleme
  Future<void> restoreLastDeletedItem() async {
    if (_lastDeletedItem == null) return;
    
    // Silinen ürünün bir kopyasını oluştur (yeni ID ile)
    final restoredItem = ShoppingItem(
      id: _uuid.v4(),
      name: _lastDeletedItem!.name,
      isPurchased: _lastDeletedItem!.isPurchased,
      createdAt: _lastDeletedItem!.createdAt, // Orijinal oluşturma zamanını koru
      listId: _lastDeletedItem!.listId,
      category: _lastDeletedItem!.category,
    );
    
    final itemsBox = await Hive.openBox<ShoppingItem>(Constants.itemsBoxName);
    await itemsBox.put(restoredItem.id, restoredItem);
    
    _items.add(restoredItem);
    _updateListItemCounts();
    
    // Geçici ürünü temizle
    _lastDeletedItem = null;
    
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
  Future<void> updateItem(String id, String newName, {String? category}) async {
    final index = _items.indexWhere((item) => item.id == id);
    if (index != -1) {
      _items[index].name = newName;
      
      if (category != null) {
        _items[index].category = category;
      }

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
