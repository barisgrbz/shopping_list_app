import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/shopping_list_provider.dart';
import '../widgets/shopping_list_item.dart';
import '../widgets/add_item_dialog.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120.0,
            floating: true,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text('Alışveriş Listesi'),
              background: Container(
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
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.search),
                onPressed: () {
                  // Arama işlevi eklenecek
                },
              ),
            ],
          ),
          Consumer<ShoppingListProvider>(
            builder: (context, provider, child) {
              final unpurchasedItems = provider.unpurchasedItems;
              final purchasedItems = provider.purchasedItems;

              if (unpurchasedItems.isEmpty && purchasedItems.isEmpty) {
                return SliverFillRemaining(
                  child: Center(
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
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: Colors.grey.shade600,
                              ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Yeni ürünler eklemek için + butonuna dokunun',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.all(16.0),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    if (unpurchasedItems.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          children: [
                            const Icon(Icons.shopping_basket_outlined),
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
                      ...unpurchasedItems.map((item) => Padding(
                            padding: const EdgeInsets.only(bottom: 4.0),
                            child: AnimatedOpacity(
                              duration: const Duration(milliseconds: 500),
                              opacity: 1.0,
                              child: ShoppingListItem(item: item),
                            ),
                          )),
                      const SizedBox(height: 24),
                    ],
                    
                    if (purchasedItems.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          children: [
                            const Icon(Icons.check_circle_outline),
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
                                  builder: (context) => AlertDialog(
                                    title: const Text('Alınanları Temizle'),
                                    content: const Text('Satın alınmış tüm ürünler listeden kaldırılacak. Onaylıyor musunuz?'),
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
                                              content: Text('Satın alınan ürünler silindi'),
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
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Divider(),
                      ...purchasedItems.map((item) => Padding(
                            padding: const EdgeInsets.only(bottom: 4.0),
                            child: AnimatedOpacity(
                              duration: const Duration(milliseconds: 500),
                              opacity: 0.6,
                              child: ShoppingListItem(item: item),
                            ),
                          )),
                    ],
                  ]),
                ),
              );
            },
          ),
        ],
      ),
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
} 