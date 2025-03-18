import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/shopping_list_provider.dart';
import '../utils/app_logger.dart';
import '../utils/icon_utils.dart';
import 'base_list_dialog.dart';

/// Yeni alışveriş listesi eklemek için diyalog
class AddListDialog extends BaseListDialog {
  const AddListDialog({super.key});

  @override
  State<AddListDialog> createState() => _AddListDialogState();
}

class _AddListDialogState extends BaseListDialogState<AddListDialog> {
  @override
  void initializeValues() {
    // Yeni liste eklenirken varsayılan değerler kullanılır
    selectedColor = Colors.green;
    selectedIcon = Icons.list_alt;
    AppLogger.log(logTag, 'Varsayılan değerler ayarlandı');
    AppLogger.logColor(logTag, 'Varsayılan renk', selectedColor);
  }

  @override
  Future<void> performOperation(String colorString) async {
    AppLogger.logOperation(logTag, 'Liste ekleme işlemi', isStart: true);
    
    final provider = Provider.of<ShoppingListProvider>(context, listen: false);
    
    // Yeni liste oluştur
    await provider.addList(
      nameController.text.trim(),
      icon: IconUtils.iconToString(selectedIcon),
      color: colorString,
    );
    
    AppLogger.logOperation(logTag, 'Liste ekleme işlemi', isStart: false);
  }

  @override
  String get dialogTitle => 'Yeni Alışveriş Listesi';

  @override
  String get submitButtonText => 'Oluştur';

  @override
  IconData get submitButtonIcon => Icons.add;
}
