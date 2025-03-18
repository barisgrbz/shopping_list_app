import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/shopping_list_provider.dart';
import '../models/shopping_list.dart';
import '../utils/color_utils.dart';
import '../utils/icon_utils.dart';
import '../utils/app_logger.dart';
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
    
    // Başlangıç değerlerini ayarla
    if (widget.list.color != null) {
      final colorFromString = ColorUtils.colorFromString(widget.list.color!);
      if (colorFromString != null) {
        selectedColor = colorFromString;
        AppLogger.logColorStringConversion(logTag, widget.list.color!, colorFromString);
      } else {
        AppLogger.log(logTag, 'Renk dönüşümü başarısız: "${widget.list.color}"');
        selectedColor = Colors.green; // Varsayılan renk
      }
    } else {
      AppLogger.log(logTag, 'Renk değeri yok');
      selectedColor = Colors.green; // Varsayılan renk
    }
    
    AppLogger.logColor(logTag, 'Kullanılan renk', selectedColor);
  }

  @override
  Future<void> performOperation(String colorString) async {
    AppLogger.logOperation(logTag, 'Liste güncelleme işlemi', isStart: true);
    
    final provider = Provider.of<ShoppingListProvider>(context, listen: false);
    
    await provider.updateList(
      widget.list.id,
      name: nameController.text.trim(),
      icon: IconUtils.iconToString(selectedIcon),
      color: colorString,
    );
    
    AppLogger.logOperation(logTag, 'Liste güncelleme işlemi', isStart: false);
  }

  @override
  String get dialogTitle => '${widget.list.name} Listesini Düzenle';

  @override
  String get submitButtonText => 'Kaydet';

  @override
  IconData get submitButtonIcon => Icons.save;
}
