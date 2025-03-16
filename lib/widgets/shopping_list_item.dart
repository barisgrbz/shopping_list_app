import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/shopping_item.dart';
import '../providers/shopping_list_provider.dart';
import 'package:intl/intl.dart';

class ShoppingListItem extends StatelessWidget {
  final ShoppingItem item;

  const ShoppingListItem({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    final timeAgo = _getTimeAgo(item.createdAt);
    
    return Dismissible(
      key: Key(item.id),
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20.0),
        child: const Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),
      direction: DismissDirection.endToStart,
      onDismissed: (_) {
        Provider.of<ShoppingListProvider>(context, listen: false)
            .removeItem(item.id);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${item.name} silindi'),
            action: SnackBarAction(
              label: 'GERİ AL',
              onPressed: () {
                // Geri alma fonksiyonu eklenecek
              },
            ),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 4.0),
        elevation: item.isPurchased ? 1.0 : 2.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
          side: BorderSide(
            color: item.isPurchased 
                ? Colors.grey.shade300 
                : Colors.transparent,
            width: 1.0,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
            leading: Checkbox(
              value: item.isPurchased,
              shape: const CircleBorder(),
              activeColor: Theme.of(context).colorScheme.primary,
              onChanged: (_) {
                Provider.of<ShoppingListProvider>(context, listen: false)
                    .togglePurchasedStatus(item.id);
              },
            ),
            title: Text(
              item.name,
              style: TextStyle(
                fontSize: 16,
                fontWeight: item.isPurchased ? FontWeight.normal : FontWeight.bold,
                decoration: item.isPurchased ? TextDecoration.lineThrough : null,
                color: item.isPurchased ? Colors.grey : null,
              ),
            ),
            subtitle: Text(
              'Eklenme: $timeAgo',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, size: 20),
                  onPressed: () {
                    // Düzenleme işlevi eklenecek
                  },
                ),
                IconButton(
                  icon: Icon(
                    Icons.delete_outline,
                    size: 20,
                    color: Colors.red.shade300,
                  ),
                  onPressed: () {
                    Provider.of<ShoppingListProvider>(context, listen: false)
                        .removeItem(item.id);
                  },
                ),
              ],
            ),
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
} 