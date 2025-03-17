import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:developer' as developer;
import '../providers/shopping_list_provider.dart';
import '../models/shopping_list.dart';
import '../utils/color_utils.dart';
import '../utils/icon_utils.dart';
import 'base_list_dialog.dart';

/// Mevcut bir alışveriş listesini düzenlemek için diyalog
class EditListDialog extends BaseListDialog {
  final ShoppingList list;

  const EditListDialog({super.key, required this.list});

  @override
  State<EditListDialog> createState() => _EditListDialogState();
}

class _EditListDialogState extends BaseListDialogState<EditListDialog> {
  @override
  void initializeValues() {
    nameController.text = widget.list.name;
    selectedIcon = IconUtils.getIconData(widget.list.icon);
    
    // Mevcut rengi alın veya varsayılan kullanın
    if (widget.list.color != null) {
      final Color? colorFromString = ColorUtils.colorFromString(widget.list.color);
      if (colorFromString != null) {
        selectedColor = colorFromString;
        developer.log('EditListDialog: initializeValues - Mevcut renk yüklendi: "${widget.list.color}" => RGB(${selectedColor.red},${selectedColor.green},${selectedColor.blue})');
      } else {
        developer.log('EditListDialog: initializeValues - Renk dönüşümü başarısız, varsayılan renk kullanılıyor. Input: "${widget.list.color}"');
        selectedColor = Colors.green; // Varsayılan renk
      }
    } else {
      developer.log('EditListDialog: initializeValues - Liste için renk yok, varsayılan renk kullanılıyor');
      selectedColor = Colors.green; // Varsayılan renk
    }
    
    developer.log('EditListDialog: initializeValues - Kullanılan renk: RGB(${selectedColor.red},${selectedColor.green},${selectedColor.blue})');
  }

  @override
  Future<void> handleSubmit() async {
    final provider = Provider.of<ShoppingListProvider>(context, listen: false);
    final colorString = ColorUtils.colorToString(selectedColor);
    
    developer.log('EditListDialog: handleSubmit - Renk dönüşümü: RGB(${selectedColor.red},${selectedColor.green},${selectedColor.blue}) => "$colorString"');
    
    // Test amaçlı olarak dönüşümün tutarlı olup olmadığını kontrol edelim
    final testColor = ColorUtils.colorFromString(colorString);
    if (testColor != null) {
      developer.log('EditListDialog: handleSubmit - Dönüşüm testi başarılı: "$colorString" => RGB(${testColor.red},${testColor.green},${testColor.blue})');
    } else {
      developer.log('EditListDialog: handleSubmit - Dönüşüm testi başarısız: "$colorString"');
    }
    
    await provider.updateList(
      widget.list.id,
      name: nameController.text.trim(),
      icon: IconUtils.iconToString(selectedIcon),
      color: colorString,
    );
  }

  @override
  String get dialogTitle => '${widget.list.name} Listesini Düzenle';

  @override
  String get submitButtonText => 'Kaydet';

  @override
  IconData get submitButtonIcon => Icons.save;
}
