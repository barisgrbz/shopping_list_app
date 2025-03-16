import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/shopping_list_provider.dart';

class AddItemDialog extends StatefulWidget {
  const AddItemDialog({super.key});

  @override
  State<AddItemDialog> createState() => _AddItemDialogState();
}

class _AddItemDialogState extends State<AddItemDialog> {
  final _formKey = GlobalKey<FormState>();
  final _textController = TextEditingController();
  final List<String> _suggestions = [
    'Süt', 'Ekmek', 'Yumurta', 'Peynir', 'Meyve', 'Sebze', 
    'Su', 'Çay', 'Kahve', 'Makarna', 'Pirinç'
  ];
  
  bool _isSubmitting = false;

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
        final provider = Provider.of<ShoppingListProvider>(context, listen: false);
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

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: contentBox(context),
    );
  }
  
  Widget contentBox(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        color: Theme.of(context).dialogTheme.backgroundColor ?? Theme.of(context).colorScheme.surface,
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
          const Text(
            'Alışveriş Listesine Ekle',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
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
                onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
                child: const Text('İptal'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _isSubmitting ? null : _addItem,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.add),
                          SizedBox(width: 8),
                          Text('Ekle'),
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