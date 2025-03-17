import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/shopping_list_provider.dart';
import '../models/shopping_list.dart';
import '../utils/constants.dart';
import '../utils/category_helper.dart';

class AddItemDialog extends StatefulWidget {
  const AddItemDialog({super.key});

  @override
  State<AddItemDialog> createState() => _AddItemDialogState();
}

class _AddItemDialogState extends State<AddItemDialog> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _textController = TextEditingController();
  
  late TabController _tabController;
  String? _selectedListId;
  String? _selectedCategory;
  bool _isListView = false; // Liste görünümü kontrolü
  bool _isTabView = true; // Tab görünümü veya Accordion görünümü kontrolü
  // Kategorilerin genişletilme durumları
  late List<bool> _expandedCategories;

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    // Initialize with current list
    final provider = Provider.of<ShoppingListProvider>(context, listen: false);
    _selectedListId = provider.selectedListId;
    
    // Tab controller for categories
    _tabController = TabController(
      length: Constants.defaultCategories.length,
      vsync: this,
    );
    
    // Initialize expanded categories
    _expandedCategories = List.generate(
      Constants.defaultCategories.length,
      (index) => index == 0, // İlk kategori açık, diğerleri kapalı
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _addItem(String name) async {
    if (name.isEmpty) return;
    
      setState(() {
        _isSubmitting = true;
      });

      try {
        final provider = Provider.of<ShoppingListProvider>(
          context,
          listen: false,
        );
      
      // Kategori tespiti yap
      final category = _selectedCategory ?? CategoryHelper.detectCategory(name);
      
      await provider.addItem(
        name.trim(),
        category: category,
      );
      
        if (mounted) {
          Navigator.of(context).pop();
        }
      } finally {
        if (mounted) {
          setState(() {
            _isSubmitting = false;
          });
        }
      }
  }

  void _addManualItem() async {
    if (_formKey.currentState!.validate()) {
      final itemName = _textController.text.trim();
      _addItem(itemName);
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

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ShoppingListProvider>(context);
    final lists = provider.lists;
    final selectedList = provider.selectedList;

    // If no list is selected or no lists exist, show message
    if (selectedList == null || lists.isEmpty) {
      return AlertDialog(
        title: const Text('Uyarı'),
        content: const Text('Önce bir alışveriş listesi oluşturmalısınız.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('TAMAM'),
          ),
        ],
      );
    }

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      elevation: 0,
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: _isTabView 
            ? contentBox(context, lists, selectedList)
            : accordionContentBox(context, lists, selectedList),
      ),
    );
  }

  Widget contentBox(
    BuildContext context,
    List<ShoppingList> lists,
    ShoppingList selectedList,
  ) {
    // Get color of selected list
    Color listColor = _getColorFromString(selectedList.color, context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        color:
            Theme.of(context).dialogTheme.backgroundColor ??
            Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10.0,
            offset: Offset(0.0, 10.0),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Row(
            children: [
              Expanded(
                child: Text(
            '${selectedList.name} Listesine Ekle',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.view_agenda, size: 20),
                tooltip: 'Akordeon Görünümü',
                onPressed: () {
                  setState(() {
                    _isTabView = false;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Liste seçimi
          if (lists.length > 1)
            DropdownButtonFormField<String>(
              value: _selectedListId ?? selectedList.id,
              decoration: InputDecoration(
                labelText: 'Eklenecek Liste',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
              ),
              items:
                  lists.map((list) {
                    return DropdownMenuItem<String>(
                      value: list.id,
                      child: Text(list.name),
                    );
                  }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedListId = value;
                  // Listeyi değiştirdiğinde, provider'ı da güncelle
                  if (value != null) {
                    Provider.of<ShoppingListProvider>(
                      context,
                      listen: false,
                    ).selectList(value);
                  }
                });
              },
            ),
          if (lists.length > 1) const SizedBox(height: 12),
          
          // Manuel ürün ekleme formu
          Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
              controller: _textController,
              autofocus: true,
              decoration: InputDecoration(
                    labelText: 'Ürün Adı Girin',
                hintText: 'Örn: Süt, Ekmek',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                prefixIcon: const Icon(Icons.shopping_bag_outlined),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () => _textController.clear(),
                ),
              ),
              textCapitalization: TextCapitalization.sentences,
              textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _addManualItem(),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Lütfen bir ürün adı girin';
                }
                return null;
              },
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: _isSubmitting ? null : _addManualItem,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Ekle'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: listColor,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 40),
                  ),
                ),
              ],
            ),
          ),
          
          // VEYA ayırıcısı
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12.0),
            child: Row(
              children: [
                Expanded(child: Divider()),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text('VEYA KATEGORİDEN SEÇİN', style: TextStyle(fontSize: 11)),
                ),
                Expanded(child: Divider()),
              ],
            ),
          ),
          
          // Kategori tabları
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 36,
                  alignment: Alignment.centerLeft,
                  child: TabBar(
                    controller: _tabController,
                    isScrollable: true,
                    tabs: Constants.defaultCategories
                        .map((category) => Tab(
                          text: category,
                          height: 36,
                        ))
                        .toList(),
                    labelColor: Theme.of(context).colorScheme.primary,
                    labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    unselectedLabelStyle: const TextStyle(fontSize: 12),
                    indicatorColor: Theme.of(context).colorScheme.primary,
                    indicatorSize: TabBarIndicatorSize.label,
                  ),
                ),
              ),
              // Görünüm değiştirme düğmesi
              IconButton(
                icon: Icon(
                  _isListView ? Icons.grid_view : Icons.view_list,
                  size: 20,
                ),
                tooltip: _isListView ? 'Izgara Görünümü' : 'Liste Görünümü',
                onPressed: () {
                  setState(() {
                    _isListView = !_isListView;
                  });
                },
              ),
            ],
          ),
          
          // Kategori içeriği
          Flexible(
            child: SizedBox(
              height: 180,
              child: TabBarView(
                controller: _tabController,
                children: Constants.defaultCategories.map((category) {
                  final products = CategoryHelper.getSuggestionsForCategory(category);
                  
                  if (products.isEmpty) {
                    return const Center(
                      child: Text('Bu kategoride önerilen ürün bulunmuyor.'),
                    );
                  }
                  
                  return _isListView
                    ? _buildListView(context, products, category)
                    : _buildChipsView(context, products, category);
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Liste görünümü 
  Widget _buildListView(BuildContext context, List<String> products, String category) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      itemCount: products.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(
            products[index],
            style: const TextStyle(fontSize: 14),
          ),
          dense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 0),
          visualDensity: VisualDensity.compact,
          enabled: !_isSubmitting,
          leading: Icon(
            Icons.add_circle_outline,
            size: 18,
            color: Theme.of(context).colorScheme.primary,
          ),
          onTap: _isSubmitting
            ? null
            : () {
                setState(() {
                  _selectedCategory = category;
                });
                _addItem(products[index]);
              },
        );
      },
    );
  }

  // Çip görünümü
  Widget _buildChipsView(BuildContext context, List<String> products, String category) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
      child: Wrap(
        spacing: 6.0,
        runSpacing: 6.0,
        children: products.map((product) {
          return InputChip(
            label: Text(
              product,
              style: const TextStyle(fontSize: 12),
            ),
            avatar: const Icon(
              Icons.add_circle_outline,
              size: 16,
            ),
            tooltip: 'Ekle: $product',
            backgroundColor: Theme.of(context).chipTheme.backgroundColor,
            disabledColor: Theme.of(context).disabledColor,
            isEnabled: !_isSubmitting,
            onPressed: _isSubmitting
                ? null
                : () {
                    setState(() {
                      _selectedCategory = category;
                    });
                    _addItem(product);
                  },
          );
        }).toList(),
      ),
    );
  }

  // Accordion tarzı görünüm
  Widget accordionContentBox(
    BuildContext context,
    List<ShoppingList> lists,
    ShoppingList selectedList,
  ) {
    // Get color of selected list
    Color listColor = _getColorFromString(selectedList.color, context);
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        color: Theme.of(context).dialogTheme.backgroundColor ??
            Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10.0,
            offset: Offset(0.0, 10.0),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Row(
            children: [
              Expanded(
                child: Text(
                  '${selectedList.name} Listesine Ekle',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.view_module, size: 20),
                tooltip: 'Tab Görünümü',
                onPressed: () {
                  setState(() {
                    _isTabView = true;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Liste seçimi
          if (lists.length > 1)
            DropdownButtonFormField<String>(
              value: _selectedListId ?? selectedList.id,
              decoration: InputDecoration(
                labelText: 'Eklenecek Liste',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
              ),
              items: lists.map((list) {
                return DropdownMenuItem<String>(
                  value: list.id,
                  child: Text(list.name),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedListId = value;
                  // Listeyi değiştirdiğinde, provider'ı da güncelle
                  if (value != null) {
                    Provider.of<ShoppingListProvider>(
                      context,
                      listen: false,
                    ).selectList(value);
                  }
                });
              },
            ),
          if (lists.length > 1) const SizedBox(height: 12),
          
          // Manuel ürün ekleme formu
          Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _textController,
                  autofocus: true,
                  decoration: InputDecoration(
                    labelText: 'Ürün Adı Girin',
                    hintText: 'Örn: Süt, Ekmek',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    prefixIcon: const Icon(Icons.shopping_bag_outlined),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () => _textController.clear(),
                    ),
                  ),
                  textCapitalization: TextCapitalization.sentences,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _addManualItem(),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Lütfen bir ürün adı girin';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: _isSubmitting ? null : _addManualItem,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Ekle'),
                style: ElevatedButton.styleFrom(
                    backgroundColor: listColor,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 40),
                  ),
                ),
              ],
            ),
          ),
          
          // VEYA ayırıcısı
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12.0),
            child: Row(
                          children: [
                Expanded(child: Divider()),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text('VEYA KATEGORİDEN SEÇİN', style: TextStyle(fontSize: 11)),
                ),
                Expanded(child: Divider()),
              ],
            ),
          ),
          
          // Kategori acordion listesi (custom)
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: Constants.defaultCategories.length,
              itemBuilder: (context, index) {
                final category = Constants.defaultCategories[index];
                final products = CategoryHelper.getSuggestionsForCategory(category);
                
                return Card(
                  margin: EdgeInsets.only(bottom: 8.0),
                  child: Column(
                    children: [
                      // Kategori başlığı
                      ListTile(
                        leading: Icon(
                          getCategoryIcon(category),
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        title: Text(
                          category,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        trailing: Icon(
                          _expandedCategories[index] 
                              ? Icons.keyboard_arrow_up 
                              : Icons.keyboard_arrow_down
                        ),
                        onTap: () {
                          setState(() {
                            _expandedCategories[index] = !_expandedCategories[index];
                          });
                        },
                      ),
                      
                      // Kategori içeriği
                      if (_expandedCategories[index])
                        products.isEmpty
                          ? const Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Text('Bu kategoride önerilen ürün bulunmuyor.'),
                            )
                          : Padding(
                              padding: const EdgeInsets.only(
                                left: 16.0,
                                right: 16.0,
                                bottom: 16.0,
                              ),
                              child: Wrap(
                                spacing: 6.0,
                                runSpacing: 6.0,
                                children: products.map((product) {
                                  return InputChip(
                                    label: Text(
                                      product,
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                    avatar: const Icon(
                                      Icons.add_circle_outline,
                                      size: 16,
                                    ),
                                    tooltip: 'Ekle: $product',
                                    backgroundColor: Theme.of(context).chipTheme.backgroundColor,
                                    disabledColor: Theme.of(context).disabledColor,
                                    isEnabled: !_isSubmitting,
                                    onPressed: _isSubmitting
                                        ? null
                                        : () {
                                            setState(() {
                                              _selectedCategory = category;
                                            });
                                            _addItem(product);
                                          },
                                  );
                                }).toList(),
                        ),
              ),
            ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
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
}
