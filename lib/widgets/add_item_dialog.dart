import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/shopping_list_provider.dart';
import '../models/shopping_list.dart';

class AddItemDialog extends StatefulWidget {
  const AddItemDialog({super.key});

  @override
  State<AddItemDialog> createState() => _AddItemDialogState();
}

class _AddItemDialogState extends State<AddItemDialog> {
  final _formKey = GlobalKey<FormState>();
  final _textController = TextEditingController();
  final List<String> _suggestions = [
    'Süt',
    'Ekmek',
    'Yumurta',
    'Peynir',
    'Meyve',
    'Sebze',
    'Su',
    'Çay',
    'Kahve',
    'Makarna',
    'Pirinç',
  ];

  bool _isSubmitting = false;
  String? _selectedListId;

  @override
  void initState() {
    super.initState();
    // Initialize with current list
    final provider = Provider.of<ShoppingListProvider>(context, listen: false);
    _selectedListId = provider.selectedListId;
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _addItem() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSubmitting = true;
      });

      try {
        final provider = Provider.of<ShoppingListProvider>(
          context,
          listen: false,
        );
        await provider.addItem(_textController.text.trim());
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
      child: contentBox(context, lists, selectedList),
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
      padding: const EdgeInsets.all(20),
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
          Text(
            '${selectedList.name} Listesine Ekle',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
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
          if (lists.length > 1) const SizedBox(height: 16),
          Form(
            key: _formKey,
            child: TextFormField(
              controller: _textController,
              autofocus: true,
              decoration: InputDecoration(
                labelText: 'Ürün Adı',
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
              onFieldSubmitted: (_) => _addItem(),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Lütfen bir ürün adı girin';
                }
                return null;
              },
            ),
          ),
          const SizedBox(height: 16),
          if (_suggestions.isNotEmpty)
            SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _suggestions.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      label: Text(_suggestions[index]),
                      selected: false,
                      onSelected: (selected) {
                        if (selected) {
                          _textController.text = _suggestions[index];
                        }
                      },
                    ),
                  );
                },
              ),
            ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed:
                    _isSubmitting ? null : () => Navigator.of(context).pop(),
                child: const Text('İptal'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _isSubmitting ? null : _addItem,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  backgroundColor: listColor,
                ),
                child:
                    _isSubmitting
                        ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                        : const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.add, color: Colors.white),
                            SizedBox(width: 8),
                            Text('Ekle', style: TextStyle(color: Colors.white)),
                          ],
                        ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
