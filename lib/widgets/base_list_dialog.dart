import 'package:flutter/material.dart';
import '../utils/icon_utils.dart';
import '../utils/color_utils.dart';
import '../utils/app_logger.dart';

/// Liste diyalogları için ortak taban sınıf
abstract class BaseListDialog extends StatefulWidget {
  const BaseListDialog({super.key});
}

/// BaseListDialog için state sınıfı
abstract class BaseListDialogState<T extends BaseListDialog> extends State<T> {
  final formKey = GlobalKey<FormState>();
  late final TextEditingController nameController;
  bool isSubmitting = false;

  /// Seçilen renk
  Color selectedColor = Colors.green;

  /// Seçilen ikon
  IconData selectedIcon = Icons.list_alt;

  /// Liste ikonları
  List<IconData> get listIcons => IconUtils.shoppingListIcons;

  /// Liste renkleri
  List<Color> get listColors => IconUtils.shoppingListColors;
  
  /// Logger tag
  String get logTag => runtimeType.toString();

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController();
    initializeValues();
    AppLogger.logOperation(logTag, 'initState', isStart: true);
  }

  /// Alt sınıflar tarafından uygulanacak başlangıç değerlerini ayarlama metodu
  void initializeValues();

  /// Alt sınıflar tarafından uygulanacak asıl işlem
  Future<void> performOperation(String colorString);

  /// Dialog başlığı
  String get dialogTitle;

  /// Gönderme butonu metni
  String get submitButtonText;

  /// Gönderme butonu ikonu
  IconData get submitButtonIcon;

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  /// Seçilen rengin string temsilini hazırla ve doğrula
  String prepareColor(Color color) {
    final colorString = ColorUtils.colorToString(color);
    AppLogger.log(logTag, 'Renk hazırlanıyor: ${ColorUtils.colorToString(color)}');
    
    // Test amaçlı renk dönüşüm kontrolü
    ColorUtils.validateColor(logTag, colorString);
    
    return colorString;
  }

  /// Form gönderme işlemi - Bu metot tüm alt sınıflar için ortak
  void submit() async {
    if (formKey.currentState!.validate()) {
      setState(() {
        isSubmitting = true;
      });

      try {
        AppLogger.logOperation(logTag, 'İşlem başlıyor', isStart: true);
        
        // Renk dönüşümü yap ve ortak hazırlık işlemlerini gerçekleştir
        final colorString = prepareColor(selectedColor);
        
        // Alt sınıfın asıl işlemini çağır
        await performOperation(colorString);
        
        AppLogger.logOperation(logTag, 'İşlem tamamlandı', isStart: false);
        
        if (mounted) {
          Navigator.of(context).pop();
        }
      } catch (e) {
        AppLogger.logError(logTag, 'İşlem sırasında hata', e);
      } finally {
        if (mounted) {
          setState(() {
            isSubmitting = false;
          });
        }
      }
    }
  }
  
  /// Renk seçimi UI
  Widget buildColorSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Liste Rengi', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: listColors.map((color) {
            final isSelected = selectedColor.hashCode == color.hashCode;
            return GestureDetector(
              onTap: () {
                setState(() {
                  selectedColor = color;
                });
                AppLogger.logColor(logTag, 'Renk seçildi', color);
              },
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? Colors.white : Colors.transparent,
                    width: 3,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: Colors.black.withAlpha(77),
                            blurRadius: 5,
                            spreadRadius: 1,
                          )
                        ]
                      : null,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
  
  /// İkon seçimi UI
  Widget buildIconSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Liste İkonu', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: listIcons.map((icon) {
            final isSelected = selectedIcon.codePoint == icon.codePoint;
            return GestureDetector(
              onTap: () {
                setState(() {
                  selectedIcon = icon;
                });
                AppLogger.log(logTag, 'İkon seçildi: ${IconUtils.iconToString(icon)}');
              },
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isSelected ? selectedColor : Colors.grey.shade200,
                  shape: BoxShape.circle,
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: Colors.black.withAlpha(51),
                            blurRadius: 3,
                            spreadRadius: 1,
                          )
                        ]
                      : null,
                ),
                child: Icon(
                  icon,
                  color: isSelected ? Colors.white : Colors.grey.shade700,
                  size: 24,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
  
  /// İsim giriş alanı
  Widget buildNameField() {
    return TextFormField(
      controller: nameController,
      decoration: const InputDecoration(
        labelText: 'Liste Adı',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.edit),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Liste adı boş olamaz';
        }
        return null;
      },
      maxLength: 50,
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(dialogTitle),
      content: Form(
        key: formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              buildNameField(),
              const SizedBox(height: 16),
              buildColorSelection(),
              const SizedBox(height: 16),
              buildIconSelection(),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: isSubmitting ? null : () => Navigator.of(context).pop(),
          child: const Text('İptal'),
        ),
        ElevatedButton.icon(
          onPressed: isSubmitting ? null : submit,
          icon: Icon(submitButtonIcon),
          label: isSubmitting
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(submitButtonText),
        ),
      ],
    );
  }
}
