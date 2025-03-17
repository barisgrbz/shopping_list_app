import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:developer' as developer;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/shopping_list_provider.dart';
import '../widgets/shopping_list_item.dart';
import '../widgets/add_item_dialog.dart';
import '../widgets/add_list_dialog.dart';
import '../widgets/edit_list_dialog.dart';
import '../models/shopping_list.dart';
import '../models/shopping_item.dart';
import '../utils/icon_utils.dart';
import '../utils/color_utils.dart';
import '../utils/constants.dart';
import '../screens/search_screen.dart';

// Sıralama seçenekleri için enum tanımlama
enum SortType {
  category,
  alphabetical,
  dateAdded,  // Eklenme tarihine göre
  priority,    // Önem derecesine göre
  custom,      // Özelleştirilmiş sıralama (kullanıcının düzenlediği)
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Aktif sıralama tipi
  SortType _sortType = SortType.category;
  
  // Özelleştirilmiş sıralama bilgisini saklamak için map
  // Key: Liste ID'si, Value: Öğe ID'lerinin özel sıralanmış listesi
  final Map<String, List<String>> _customSortOrders = {};
  
  @override
  void initState() {
    super.initState();
    _loadCustomSortOrders();
  }
  
  @override
  void dispose() {
    _saveCustomSortOrders();
    super.dispose();
  }
  
  // Özelleştirilmiş sıralamayı SharedPreferences'a kaydet
  Future<void> _saveCustomSortOrders() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Map'i JSON'a dönüştür
      final Map<String, String> jsonMap = {};
      _customSortOrders.forEach((key, value) {
        jsonMap[key] = jsonEncode(value);
      });
      
      // Dönüştürülen JSON'ı SharedPreferences'a kaydet
      await prefs.setString('customSortOrders', jsonEncode(jsonMap));
      developer.log('Özelleştirilmiş sıralama kaydedildi: ${jsonEncode(jsonMap)}');
    } catch (e) {
      developer.log('Özelleştirilmiş sıralama kaydedilirken hata oluştu: $e');
    }
  }
  
  // Özelleştirilmiş sıralamayı SharedPreferences'dan yükle
  Future<void> _loadCustomSortOrders() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? jsonString = prefs.getString('customSortOrders');
      
      if (jsonString != null && jsonString.isNotEmpty) {
        final Map<String, dynamic> jsonMap = jsonDecode(jsonString);
        
        jsonMap.forEach((key, value) {
          final List<dynamic> itemList = jsonDecode(value);
          _customSortOrders[key] = itemList.map((item) => item.toString()).toList();
        });
        
        developer.log('Özelleştirilmiş sıralama yüklendi: $_customSortOrders');
      }
    } catch (e) {
      developer.log('Özelleştirilmiş sıralama yüklenirken hata oluştu: $e');
    }
  }

  // Renk string'inden Color oluşturan yardımcı fonksiyon
  Color _getColorFromString(String? colorString, BuildContext context) {
    if (colorString == null || colorString.isEmpty) {
      return Theme.of(context).colorScheme.primary;
    }

    try {
      String hexColor =
          colorString.length == 6 ? colorString : colorString.substring(0, 6);
      return Color(int.parse('0xFF$hexColor'));
    } catch (e) {
      return Theme.of(
        context,
      ).colorScheme.primary; // Hata durumunda varsayılan renk
    }
  }

  // Kategori ikonlarını almak için yardımcı fonksiyon
  IconData getCategoryIcon(String category) {
    switch(category) {
      case 'Meyve & Sebze': return Icons.eco;
      case 'Et & Tavuk': return Icons.egg_alt;
      case 'Süt Ürünleri': return Icons.breakfast_dining;
      case 'İçecekler': return Icons.local_cafe;
      case 'Temizlik': return Icons.clean_hands;
      case 'Kişisel Bakım': return Icons.spa;
      case 'Atıştırmalık': return Icons.fastfood;
      case 'Ev Gereçleri': return Icons.cleaning_services;
      case 'Diğer': return Icons.more_horiz;
      default: return Icons.shopping_basket;
    }
  }
  
  // Kategori bazlı gruplama fonksiyonu
  Map<String, List<ShoppingItem>> groupItemsByCategory(List<ShoppingItem> items) {
    Map<String, List<ShoppingItem>> grouped = {};
    
    // Önce tüm kategorileri oluştur
    for (var category in Constants.defaultCategories) {
      grouped[category] = [];
    }
    
    // Her ürünü kendi kategorisine ekle
    for (var item in items) {
      if (!grouped.containsKey(item.category)) {
        grouped[item.category] = [];
      }
      grouped[item.category]!.add(item);
    }
    
    // Her kategoriyi kendi içinde alfabetik sırala
    grouped.forEach((category, categoryItems) {
      categoryItems.sort((a, b) => a.name.compareTo(b.name));
    });
    
    return grouped;
  }

  // Ürünleri sıralama tipine göre organize eder
  List<Widget> _getSortedItems(List<ShoppingItem> items, Color listColor, {bool isPurchased = false}) {
    switch (_sortType) {
      case SortType.category:
        // Kategori bazlı gruplandırma
        return groupItemsByCategory(items).entries
            .where((entry) => entry.value.isNotEmpty)
            .map((entry) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (entry.value.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.only(top: 8.0, bottom: 4.0),
                  child: Row(
                    children: [
                      Icon(
                        getCategoryIcon(entry.key),
                        size: 16,
                        color: isPurchased 
                          ? Theme.of(context).colorScheme.primary.withAlpha(179)
                          : Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${entry.key} (${entry.value.length})',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isPurchased
                            ? Theme.of(context).colorScheme.primary.withAlpha(179)
                            : Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                ...entry.value.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(
                      bottom: 4.0, 
                      left: 24.0
                    ),
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 500),
                      opacity: isPurchased ? 0.6 : 1.0,
                      child: ShoppingListItem(item: item),
                    ),
                  ),
                ),
              ],
            ],
          );
        }).toList();

      case SortType.alphabetical:
        // Alfabetik sıralama
        final sortedItems = List<ShoppingItem>.from(items);
        sortedItems.sort((a, b) => a.name.compareTo(b.name));
        
        return sortedItems.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 4.0),
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 500),
              opacity: isPurchased ? 0.6 : 1.0,
              child: ShoppingListItem(item: item),
            ),
          ),
        ).toList();
        
      case SortType.dateAdded:
        // Eklenme tarihine göre sıralama (en yeni üstte)
        final sortedItems = List<ShoppingItem>.from(items);
        // Eğer createdAt alanı varsa ona göre sırala, yoksa ID'ye göre sırala (ID UUID olarak üretildiyse tarih sırasını yansıtabilir)
        sortedItems.sort((a, b) => b.id.compareTo(a.id)); // Varsayılan olarak ID'yi ters sıralıyoruz
        
        return sortedItems.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 4.0),
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 500),
              opacity: isPurchased ? 0.6 : 1.0,
              child: ShoppingListItem(item: item),
            ),
          ),
        ).toList();
        
      case SortType.priority:
        // Önem derecesine göre sıralama
        // Not: Önem derecesi özelliği henüz modelde olmadığından, şu an kategori bazlı sıralama yapıyoruz
        // Gelecekte ShoppingItem modeline priority eklendiğinde bu kısım güncellenebilir
        return groupItemsByCategory(items).entries
            .where((entry) => entry.value.isNotEmpty)
            .map((entry) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (entry.value.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.only(top: 8.0, bottom: 4.0),
                  child: Row(
                    children: [
                      Icon(
                        getCategoryIcon(entry.key),
                        size: 16,
                        color: isPurchased 
                          ? Theme.of(context).colorScheme.primary.withAlpha(179)
                          : Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${entry.key} (${entry.value.length})',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isPurchased
                            ? Theme.of(context).colorScheme.primary.withAlpha(179)
                            : Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                ...entry.value.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(
                      bottom: 4.0, 
                      left: 24.0
                    ),
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 500),
                      opacity: isPurchased ? 0.6 : 1.0,
                      child: ShoppingListItem(item: item),
                    ),
                  ),
                ),
              ],
            ],
          );
        }).toList();
        
      case SortType.custom:
        // Özelleştirilmiş sıralama
        final provider = Provider.of<ShoppingListProvider>(context, listen: false);
        final currentListId = provider.selectedListId ?? '';
        
        // Eğer özelleştirilmiş sıralama yoksa, varsayılan olarak mevcut sırayı kullan
        if (!_customSortOrders.containsKey(currentListId)) {
          _customSortOrders[currentListId] = items.map((item) => item.id).toList();
        }
        
        // Yeni eklenen öğeleri sıralama listesine ekle
        final customOrder = _customSortOrders[currentListId]!;
        for (final item in items) {
          if (!customOrder.contains(item.id)) {
            customOrder.add(item.id);
          }
        }
        
        // Silinen öğeleri sıralama listesinden çıkar
        _customSortOrders[currentListId] = customOrder
            .where((id) => items.any((item) => item.id == id))
            .toList();
        
        // Özelleştirilmiş sıralamaya göre sırala
        final sortedItems = List<ShoppingItem>.from(items);
        sortedItems.sort((a, b) {
          final indexA = customOrder.indexOf(a.id);
          final indexB = customOrder.indexOf(b.id);
          
          // Eğer herhangi bir öğe listede yoksa (yeni eklenmiş olabilir), sona ekle
          if (indexA == -1) return 1;
          if (indexB == -1) return -1;
          
          return indexA.compareTo(indexB);
        });
        
        // ReorderableListView için bir şablon oluştur
        if (!isPurchased) {
          // Sadece henüz alınmamış ürünler için düzenleme yap
          return [
            if (sortedItems.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  children: [
                    const Icon(Icons.drag_handle, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      'Öğeleri sürükleyip bırakarak sıralayabilirsiniz',
                      style: TextStyle(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ReorderableListView.builder(
              key: const Key('reorderable_list'),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: sortedItems.length,
              itemBuilder: (context, index) {
                final item = sortedItems[index];
                return Padding(
                  key: Key(item.id),
                  padding: const EdgeInsets.only(bottom: 4.0),
                  child: Row(
                    children: [
                      const Icon(Icons.drag_handle, size: 18, color: Colors.grey),
                      const SizedBox(width: 4),
                      Expanded(child: ShoppingListItem(item: item)),
                    ],
                  ),
                );
              },
              onReorder: (oldIndex, newIndex) {
                setState(() {
                  // Flutter'ın ReorderableListView'ı, eğer bir öğe aşağı taşınıyorsa,
                  // öğeyi kaldırmadan önce hedef indeksi bir azaltmamız gerekiyor
                  if (oldIndex < newIndex) {
                    newIndex -= 1;
                  }
                  
                  // Öğeyi eski pozisyondan kaldır
                  final itemId = _customSortOrders[currentListId]!.removeAt(oldIndex);
                  // Yeni pozisyona ekle
                  _customSortOrders[currentListId]!.insert(newIndex, itemId);
                  
                  // Değişiklikleri kalıcı olarak kaydet
                  _saveCustomSortOrders();
                });
                
                // Sıralama değiştiğinde bir bildirim göster
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Liste sıralaması güncellendi'),
                    duration: Duration(seconds: 1),
                  ),
                );
              },
            ),
          ];
        } else {
          // Alınmış ürünler için sadece sıralanmış görünüm göster (düzenleme yok)
          return sortedItems.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 4.0),
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 500),
                opacity: 0.6,
                child: ShoppingListItem(item: item),
              ),
            ),
          ).toList();
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ShoppingListProvider>(context);
    final currentList = provider.selectedList;

    if (currentList == null) {
      return const Center(
        child: Text(
          'Önce alışveriş listesi oluşturun',
          style: TextStyle(fontSize: 18),
        ),
      );
    }

    // Liste rengi
    final listColor = _getColorFromString(currentList.color, context);

    return Scaffold(
      appBar: AppBar(
        title: Text(currentList.name), // Null kontrolü gereksiz, currentList null değil
        backgroundColor: listColor,
        foregroundColor: ColorUtils.getContrastColor(listColor),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Arama sayfasına yönlendir
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SearchScreen(),
                ),
              );
            },
          ),
        ],
      ),
      drawer: _buildDrawer(context, provider),
      body: provider.lists.isEmpty
          ? _buildEmptyListsView(context)
          : _buildShoppingListView(context, provider),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => const AddItemDialog(),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Ürün Ekle'),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context, ShoppingListProvider provider) {
    final lists = provider.lists;
    final selectedListId = provider.selectedListId;

    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.primaryContainer,
                ],
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_cart,
                    size: 48,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Alışveriş Listeleri',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${lists.length} liste',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onPrimary.withAlpha(204),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child:
                lists.isEmpty
                    ? Center(
                      child: Text(
                        'Henüz liste oluşturmadınız',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    )
                    : ListView.builder(
                      padding: const EdgeInsets.only(top: 4.0),
                      itemCount: lists.length,
                      itemBuilder: (context, index) {
                        final list = lists[index];
                        final isSelected = list.id == selectedListId;
                        
                        // Debug log ekleyerek renk değerini görelim
                        developer.log('Drawer: Liste [${list.name}] renk değeri: "${list.color}"');
                        
                        final Color? listColorOrNull = list.color != null
                          ? ColorUtils.colorFromString(list.color) 
                          : null;
                          
                        if (list.color != null) {
                          if (listColorOrNull != null) {
                            // ignore: deprecated_member_use
                            developer.log('Drawer: Renk dönüşümü başarılı [${list.name}]: "${list.color}" => RGB(${listColorOrNull.r},${listColorOrNull.g},${listColorOrNull.b})');
                          } else {
                            developer.log('Drawer: Renk dönüşümü başarısız [${list.name}] - input: "${list.color}"');
                          }
                        }
                        
                        final Color listColor = listColorOrNull ?? Theme.of(context).colorScheme.primary;
                        developer.log('Drawer: Kullanılan renk [${list.name}]: ${ColorUtils.colorToString(listColor)}, RGB(${listColor.r},${listColor.g},${listColor.b})');

                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: isSelected
                                ? listColor
                                : listColor.withAlpha((0.6 * 255).round()),
                            foregroundColor: ColorUtils.getContrastColor(listColor),
                            child: Icon(
                              IconUtils.getIconData(list.icon),
                              size: 20,
                            ),
                          ),
                          title: Text(list.name),
                          subtitle: Text('${list.itemCount} ürün'),
                          selected: isSelected,
                          onTap: () {
                            provider.selectList(list.id);
                            Navigator.pop(context);
                          },
                          trailing: PopupMenuButton(
                            itemBuilder:
                                (context) => [
                                  const PopupMenuItem(
                                    value: 'edit',
                                    child: Row(
                                      children: [
                                        Icon(Icons.edit, size: 18),
                                        SizedBox(width: 8),
                                        Text('Düzenle'),
                                      ],
                                    ),
                                  ),
                                  const PopupMenuItem(
                                    value: 'delete',
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.delete,
                                          color: Colors.red,
                                          size: 18,
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          'Sil',
                                          style: TextStyle(color: Colors.red),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                            onSelected: (value) {
                              if (value == 'edit') {
                                showDialog(
                                  context: context,
                                  builder:
                                      (context) => EditListDialog(list: list),
                                );
                              } else if (value == 'delete') {
                                _showDeleteConfirmation(
                                  context,
                                  provider,
                                  list,
                                );
                              }
                            },
                          ),
                        );
                      },
                    ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: OutlinedButton.icon(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => const AddListDialog(),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('Yeni Liste Ekle'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyListsView(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.format_list_bulleted,
            size: 100,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            'Henüz Liste Yok',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 8),
          const Text(
            'Yeni bir alışveriş listesi oluşturmak için + butonuna dokunun',
            style: TextStyle(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildShoppingListView(
    BuildContext context,
    ShoppingListProvider provider,
  ) {
    final selectedList = provider.selectedList;
    final unpurchasedItems = provider.currentUnpurchasedItems;
    final purchasedItems = provider.currentPurchasedItems;
    
    // Kategori bazlı gruplama burada doğrudan kullanılacak
    
    // Liste rengi
    final listColor = _getColorFromString(selectedList!.color, context);

    return Column(
      children: [
        // Liste başlığı
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: listColor.withAlpha(25),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: listColor,
                foregroundColor: ColorUtils.getContrastColor(listColor),
                radius: 16,
                child: Icon(
                  IconUtils.getIconData(selectedList.icon),
                  size: 16,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      selectedList.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${unpurchasedItems.length} alınacak, ${purchasedItems.length} tamamlandı',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onSurface.withAlpha(179),
                      ),
                    ),
                  ],
                ),
              ),
              // Sıralama tipi değiştirme butonu
              PopupMenuButton<SortType>(
                icon: Icon(
                  _getSortTypeIcon(),
                  size: 20,
                ),
                tooltip: 'Sıralama Seçenekleri',
                onSelected: (SortType value) {
                  setState(() {
                    _sortType = value;
                  });
                },
                itemBuilder: (BuildContext context) => <PopupMenuEntry<SortType>>[
                  const PopupMenuItem<SortType>(
                    value: SortType.category,
                    child: Row(
                      children: [
                        Icon(Icons.category, size: 18),
                        SizedBox(width: 8),
                        Text('Kategoriye Göre'),
                      ],
                    ),
                  ),
                  const PopupMenuItem<SortType>(
                    value: SortType.alphabetical,
                    child: Row(
                      children: [
                        Icon(Icons.sort_by_alpha, size: 18),
                        SizedBox(width: 8),
                        Text('Alfabetik'),
                      ],
                    ),
                  ),
                  const PopupMenuItem<SortType>(
                    value: SortType.dateAdded,
                    child: Row(
                      children: [
                        Icon(Icons.date_range, size: 18),
                        SizedBox(width: 8),
                        Text('Eklenme Tarihine Göre'),
                      ],
                    ),
                  ),
                  const PopupMenuItem<SortType>(
                    value: SortType.priority,
                    child: Row(
                      children: [
                        Icon(Icons.priority_high, size: 18),
                        SizedBox(width: 8),
                        Text('Önceliğe Göre'),
                      ],
                    ),
                  ),
                  const PopupMenuItem<SortType>(
                    value: SortType.custom,
                    child: Row(
                      children: [
                        Icon(Icons.drag_indicator, size: 18),
                        SizedBox(width: 8),
                        Text('Özelleştirilmiş Sıralama'),
                      ],
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.edit, size: 20),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => EditListDialog(list: selectedList),
                  );
                },
              ),
            ],
          ),
        ),
        // Ürün listesi
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              if (unpurchasedItems.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: listColor,
                        foregroundColor: ColorUtils.getContrastColor(listColor),
                        radius: 14,
                        child: const Icon(
                          Icons.shopping_basket_outlined,
                          size: 16,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Alınacaklar (${unpurchasedItems.length})',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(),
                
                // Sıralama tipine göre ürünleri göster
                ..._getSortedItems(unpurchasedItems, listColor),
                
                const SizedBox(height: 24),
              ],

              if (purchasedItems.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: listColor.withAlpha(179),
                        foregroundColor: ColorUtils.getContrastColor(listColor),
                        radius: 14,
                        child: const Icon(
                          Icons.check_circle_outline,
                          size: 16,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Alınanlar (${purchasedItems.length})',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      TextButton.icon(
                        icon: const Icon(Icons.delete_sweep, size: 16),
                        label: const Text('Temizle'),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder:
                                (context) => AlertDialog(
                                  title: const Text('Alınanları Temizle'),
                                  content: const Text(
                                    'Satın alınmış tüm ürünler listeden kaldırılacak. Onaylıyor musunuz?',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('İPTAL'),
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        provider.clearCompletedItems();
                                        Navigator.pop(context);
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Satın alınan ürünler silindi',
                                            ),
                                            duration: Duration(seconds: 2),
                                          ),
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        foregroundColor: Colors.white,
                                        backgroundColor: Colors.red,
                                      ),
                                      child: const Text('TEMİZLE'),
                                    ),
                                  ],
                                ),
                          );
                        },
                        style: TextButton.styleFrom(foregroundColor: Colors.red),
                      ),
                    ],
                  ),
                ),
                const Divider(),
                
                // Sıralama tipine göre ürünleri göster
                ..._getSortedItems(purchasedItems, listColor, isPurchased: true),
              ],
            ],
          ),
        ),
      ],
    );
  }

  // Aktif sıralama tipine göre ikon seçen yardımcı fonksiyon
  IconData _getSortTypeIcon() {
    switch (_sortType) {
      case SortType.category:
        return Icons.category;
      case SortType.alphabetical:
        return Icons.sort_by_alpha;
      case SortType.dateAdded:
        return Icons.date_range;
      case SortType.priority:
        return Icons.priority_high;
      case SortType.custom:
        return Icons.drag_indicator;
    }
  }

  void _showDeleteConfirmation(
    BuildContext context,
    ShoppingListProvider provider,
    ShoppingList list,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Listeyi Sil'),
            content: Text(
              '${list.name} listesini silmek istediğinize emin misiniz? Bu işlem geri alınamaz ve listedeki tüm ürünler silinecektir.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('İPTAL'),
              ),
              ElevatedButton(
                onPressed: () {
                  provider.removeList(list.id);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${list.name} listesi silindi'),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.red,
                ),
                child: const Text('SİL'),
              ),
            ],
          ),
    );
  }
}
