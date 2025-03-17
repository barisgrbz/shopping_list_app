import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/shopping_list_provider.dart';
import '../widgets/shopping_list_item.dart';
import '../models/shopping_list.dart';
import '../utils/color_utils.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _searchAllLists = true; // Varsayılan olarak tüm listelerde arama yapar

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ShoppingListProvider>(context);
    final searchResults = provider.searchItems(_searchQuery, searchAllLists: _searchAllLists);
    
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            hintText: 'Ürün ara...',
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.white70),
          ),
          style: const TextStyle(color: Colors.white),
          cursorColor: Colors.white,
          autofocus: true,
          onChanged: (value) {
            setState(() {
              _searchQuery = value;
            });
          },
        ),
        actions: [
          // Arama modu seçici
          IconButton(
            icon: Icon(_searchAllLists ? Icons.list : Icons.list_alt),
            tooltip: _searchAllLists ? 'Tüm listelerde arama' : 'Sadece seçili listede arama',
            onPressed: () {
              setState(() {
                _searchAllLists = !_searchAllLists;
              });
            },
          ),
          if (_searchQuery.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                setState(() {
                  _searchController.clear();
                  _searchQuery = '';
                });
              },
            ),
        ],
      ),
      body: Column(
        children: [
          // Arama modu göstergesi
          Container(
            color: _searchAllLists ? Colors.amber.shade100 : Colors.blue.shade100,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: Row(
              children: [
                Icon(
                  _searchAllLists ? Icons.search : Icons.search,
                  size: 18,
                  color: _searchAllLists ? Colors.amber.shade800 : Colors.blue.shade800,
                ),
                const SizedBox(width: 8),
                Text(
                  _searchAllLists 
                      ? 'Tüm listelerde arama yapılıyor' 
                      : 'Sadece ${provider.selectedList?.name ?? ''} listesinde arama yapılıyor',
                  style: TextStyle(
                    fontSize: 14,
                    color: _searchAllLists ? Colors.amber.shade800 : Colors.blue.shade800,
                  ),
                ),
                const Spacer(),
                Switch(
                  value: _searchAllLists,
                  onChanged: (value) {
                    setState(() {
                      _searchAllLists = value;
                    });
                  },
                  activeColor: Colors.amber.shade800,
                  inactiveTrackColor: Colors.blue.shade200,
                ),
              ],
            ),
          ),
          // Arama sonuçları
          Expanded(
            child: _searchQuery.isEmpty
                ? const Center(
                    child: Text(
                      'Ürün aramak için yukarıdan arama yapın',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  )
                : searchResults.isEmpty
                    ? const Center(
                        child: Text(
                          'Sonuç bulunamadı',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16.0),
                        itemCount: searchResults.length,
                        itemBuilder: (context, index) {
                          final item = searchResults[index];
                          
                          // Tüm listelerde arama yaparken, hangi listeye ait olduğunu gösterelim
                          if (_searchAllLists) {
                            // Liste adını bul
                            final itemList = provider.lists.firstWhere(
                              (list) => list.id == item.listId,
                              orElse: () => ShoppingList(
                                id: '',
                                name: 'Bilinmeyen Liste',
                                createdAt: DateTime.now(),
                              ),
                            );
                            
                            // Liste rengini alma
                            final Color? listColorOrNull = itemList.color != null
                              ? ColorUtils.colorFromString(itemList.color)
                              : null;
                            final Color listColor = listColorOrNull ?? Theme.of(context).colorScheme.primary;
                            
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (index == 0 || searchResults[index-1].listId != item.listId)
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 8, top: 16),
                                    child: Row(
                                      children: [
                                        CircleAvatar(
                                          backgroundColor: listColor,
                                          radius: 10,
                                          child: const Icon(Icons.list, size: 12, color: Colors.white),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          itemList.name,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ShoppingListItem(item: item),
                              ],
                            );
                          }
                          
                          return ShoppingListItem(item: item);
                        },
                      ),
          ),
        ],
      ),
    );
  }
} 