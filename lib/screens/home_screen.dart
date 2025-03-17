import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:developer' as developer;
import '../providers/shopping_list_provider.dart';
import '../widgets/shopping_list_item.dart';
import '../widgets/add_item_dialog.dart';
import '../widgets/add_list_dialog.dart';
import '../widgets/edit_list_dialog.dart';
import '../models/shopping_list.dart';
import '../utils/icon_utils.dart';
import '../utils/color_utils.dart';
import '../screens/search_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ShoppingListProvider>(
      builder: (context, provider, child) {
        final selectedList = provider.selectedList;
        final Color? listColorOrNull = selectedList?.color != null 
          ? ColorUtils.colorFromString(selectedList?.color) 
          : null;
        final Color selectedColor = listColorOrNull ?? Theme.of(context).colorScheme.primary;

        return Scaffold(
          appBar: AppBar(
            title: Text(selectedList?.name ?? 'Alışveriş Listesi'),
            backgroundColor: selectedColor,
            foregroundColor: ColorUtils.getContrastColor(selectedColor),
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
          floatingActionButton:
              selectedList == null
                  ? FloatingActionButton.extended(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => const AddListDialog(),
                      );
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Liste Ekle'),
                  )
                  : FloatingActionButton.extended(
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
      },
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
                            developer.log('Drawer: Renk dönüşümü başarılı [${list.name}]: "${list.color}" => RGB(${listColorOrNull.red},${listColorOrNull.green},${listColorOrNull.blue})');
                          } else {
                            developer.log('Drawer: Renk dönüşümü başarısız [${list.name}] - input: "${list.color}"');
                          }
                        }
                        
                        final Color listColor = listColorOrNull ?? Theme.of(context).colorScheme.primary;
                        developer.log('Drawer: Kullanılan renk [${list.name}]: ${ColorUtils.colorToString(listColor)}, RGB(${listColor.red},${listColor.green},${listColor.blue})');

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
    final unpurchasedItems = provider.currentUnpurchasedItems;
    final purchasedItems = provider.currentPurchasedItems;
    final selectedList = provider.selectedList;
    final Color? listColorOrNull = selectedList?.color != null 
      ? ColorUtils.colorFromString(selectedList?.color) 
      : null;
    final Color listColor = listColorOrNull ?? Theme.of(context).colorScheme.primary;

    if (unpurchasedItems.isEmpty && purchasedItems.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_cart_outlined,
              size: 100,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              'Alışveriş listeniz boş',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 8),
            const Text(
              'Yeni ürünler eklemek için + butonuna dokunun',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView(
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
          ...unpurchasedItems.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 4.0),
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 500),
                opacity: 1.0,
                child: ShoppingListItem(item: item),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],

        if (purchasedItems.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: listColor.withAlpha((0.7 * 255).round()),
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
          ...purchasedItems.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 4.0),
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 500),
                opacity: 0.6,
                child: ShoppingListItem(item: item),
              ),
            ),
          ),
        ],
      ],
    );
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
