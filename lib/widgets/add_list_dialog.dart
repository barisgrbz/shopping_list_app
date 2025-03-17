import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:developer' as developer;
import '../providers/shopping_list_provider.dart';
import '../utils/color_utils.dart';
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
    developer.log('AddListDialog: initializeValues - Varsayılan değerler ayarlandı');
    developer.log('AddListDialog: initializeValues - Varsayılan renk: RGB(${selectedColor.red},${selectedColor.green},${selectedColor.blue})');
  }

  @override
  Future<void> handleSubmit() async {
    final provider = Provider.of<ShoppingListProvider>(context, listen: false);
    final colorString = ColorUtils.colorToString(selectedColor);
    
    developer.log('AddListDialog: handleSubmit - Seçilen renk bilgileri:');
    developer.log('AddListDialog: handleSubmit - Renk: RGB(${selectedColor.red},${selectedColor.green},${selectedColor.blue})');
    developer.log('AddListDialog: handleSubmit - RRGGBB: $colorString');
    
    // Test amaçlı renk dönüşümünü tekrar kontrol edelim
    final colorFromString = ColorUtils.colorFromString(colorString);
    if (colorFromString != null) {
      developer.log('AddListDialog: handleSubmit - Dönüşüm sonrası renk: RGB(${colorFromString.red},${colorFromString.green},${colorFromString.blue})');
    } else {
      developer.log('AddListDialog: handleSubmit - HATA! Renk dönüşümü başarısız oldu: "$colorString"');
    }
    
    // Yeni liste oluştur
    await provider.addList(
      nameController.text.trim(),
      icon: IconUtils.iconToString(selectedIcon),
      color: colorString,
    );
  }

  @override
  String get dialogTitle => 'Yeni Alışveriş Listesi';

  @override
  String get submitButtonText => 'Oluştur';

  @override
  IconData get submitButtonIcon => Icons.add;
}
