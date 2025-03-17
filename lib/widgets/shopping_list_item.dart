import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/shopping_item.dart';
import '../providers/shopping_list_provider.dart';
import '../utils/color_utils.dart';
import '../utils/constants.dart';
import 'package:intl/intl.dart';

class ShoppingListItem extends StatelessWidget {
  final ShoppingItem item;

  const ShoppingListItem({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final timeAgo = _getTimeAgo(item.createdAt);
    final provider = Provider.of<ShoppingListProvider>(context, listen: false);
    final selectedList = provider.selectedList;
    final Color? listColorOrNull = selectedList?.color != null 
      ? ColorUtils.colorFromString(selectedList?.color) 
      : null;
    final Color listColor = listColorOrNull ?? Theme.of(context).colorScheme.primary;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      elevation: item.isPurchased ? 1.0 : 2.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
        side: BorderSide(
          color: item.isPurchased ? Colors.grey.shade300 : Colors.transparent,
          width: 1.0,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16.0,
            vertical: 4.0,
          ),
          leading: Checkbox(
            value: item.isPurchased,
            shape: const CircleBorder(),
            activeColor: listColor,
            onChanged: (_) {
              Provider.of<ShoppingListProvider>(
                context,
                listen: false,
              ).togglePurchasedStatus(item.id);
            },
          ),
          title: Text(
            item.name,
            style: TextStyle(
              fontSize: 16,
              fontWeight:
                  item.isPurchased ? FontWeight.normal : FontWeight.bold,
              decoration:
                  item.isPurchased ? TextDecoration.lineThrough : null,
              color: item.isPurchased ? Colors.grey : null,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.category_outlined,
                    size: 12,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    item.category,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
              Text(
                'Eklenme: $timeAgo',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(
                  Icons.edit, 
                  size: 20,
                  color: listColor,
                ),
                onPressed: () {
                  _showEditItemDialog(context, item);
                },
              ),
              IconButton(
                icon: Icon(
                  Icons.delete_outline,
                  size: 20,
                  color: Colors.red.shade300,
                ),
                onPressed: () {
                  _deleteItem(context, item);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getTimeAgo(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);

    if (difference.inDays > 7) {
      final dateFormat = DateFormat.yMMMd(); // Örn: Jan 21, 2024
      return dateFormat.format(dateTime);
    } else if (difference.inDays > 0) {
      return '${difference.inDays} gün önce';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} saat önce';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} dakika önce';
    } else {
      return 'Az önce';
    }
  }

  void _showEditItemDialog(BuildContext context, ShoppingItem item) {
    final TextEditingController controller = TextEditingController(text: item.name);
    String selectedCategory = item.category;
    
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Ürünü Düzenle'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: controller,
                    decoration: const InputDecoration(
                      labelText: 'Ürün Adı',
                      border: OutlineInputBorder(),
                    ),
                    autofocus: true,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selectedCategory,
                    decoration: const InputDecoration(
                      labelText: 'Kategori',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.category_outlined),
                    ),
                    items: Constants.defaultCategories.map((category) {
                      return DropdownMenuItem<String>(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          selectedCategory = value;
                        });
                      }
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('İPTAL'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (controller.text.trim().isNotEmpty) {
                      // Provider üzerinden ürünü güncelle
                      Provider.of<ShoppingListProvider>(context, listen: false)
                          .updateItem(
                            item.id, 
                            controller.text.trim(),
                            category: selectedCategory,
                          );
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('KAYDET'),
                ),
              ],
            );
          }
        );
      },
    );
  }

  // Ürünü silme ve Snackbar gösterme
  void _deleteItem(BuildContext context, ShoppingItem item) {
    // Provider'a erişim
    final provider = Provider.of<ShoppingListProvider>(
      context,
      listen: false,
    );
    
    // Ürünü sil
    provider.removeItem(item.id);
    
    // Snackbar göster
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${item.name} silindi'),
        action: SnackBarAction(
          label: 'GERİ AL',
          onPressed: () {
            // Son silinen ürünü geri yükle
            provider.restoreLastDeletedItem().then((_) {
              // İşlem tamamlandığında bildirim göster
              ScaffoldMessenger.of(context).clearSnackBars();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Ürün geri alındı'),
                  duration: Duration(seconds: 1),
                ),
              );
            });
          },
        ),
      ),
    );
  }
}
