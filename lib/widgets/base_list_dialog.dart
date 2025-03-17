import 'package:flutter/material.dart';
import '../utils/icon_utils.dart';

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

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController();
    initializeValues();
  }

  /// Alt sınıflar tarafından uygulanacak başlangıç değerlerini ayarlama metodu
  void initializeValues();

  /// Alt sınıflar tarafından uygulanacak işlem metodu
  Future<void> handleSubmit();

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

  /// Form gönderme işlemi
  void submit() async {
    if (formKey.currentState!.validate()) {
      setState(() {
        isSubmitting = true;
      });

      try {
        await handleSubmit();
        if (mounted) {
          Navigator.of(context).pop();
        }
      } finally {
        if (mounted) {
          setState(() {
            isSubmitting = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: contentBox(context),
    );
  }

  Widget contentBox(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      constraints: const BoxConstraints(maxWidth: 400),
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
            dialogTitle,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          // Form alanı
          buildForm(),
          const SizedBox(height: 14),
          // İkon seçimi
          buildIconSelection(),
          const SizedBox(height: 14),
          // Renk seçimi
          buildColorSelection(),
          const SizedBox(height: 16),
          // Alt butonlar
          buildActionButtons(),
        ],
      ),
    );
  }

  Widget buildForm() {
    return Form(
      key: formKey,
      child: TextFormField(
        controller: nameController,
        autofocus: true,
        style: const TextStyle(fontSize: 14),
        decoration: InputDecoration(
          labelText: 'Liste Adı',
          hintText: 'Örn: Market, Kırtasiye',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          isDense: true,
          prefixIcon: Icon(selectedIcon, color: selectedColor, size: 18),
          suffixIcon: IconButton(
            icon: const Icon(Icons.clear, size: 16),
            onPressed: () => nameController.clear(),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            visualDensity: VisualDensity.compact,
          ),
        ),
        textCapitalization: TextCapitalization.sentences,
        textInputAction: TextInputAction.done,
        onFieldSubmitted: (_) => submit(),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'Lütfen bir liste adı girin';
          }
          return null;
        },
      ),
    );
  }

  Widget buildIconSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('İkon Seç', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Container(
          height: 120,
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: GridView.builder(
            padding: const EdgeInsets.all(4),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1,
              crossAxisSpacing: 2,
              mainAxisSpacing: 2,
            ),
            itemCount: listIcons.length,
            itemBuilder: (context, index) {
              final icon = listIcons[index];
              final isSelected = icon == selectedIcon;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedIcon = icon;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: isSelected ? selectedColor : Colors.white,
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: selectedColor.withAlpha(100),
                              blurRadius: 2,
                              spreadRadius: 0.5,
                            )
                          ]
                        : [
                            BoxShadow(
                              color: Colors.black.withAlpha(10),
                              blurRadius: 1,
                              spreadRadius: 0,
                            )
                          ],
                  ),
                  child: Center(
                    child: Icon(
                      icon,
                      color: isSelected ? Colors.white : Colors.grey.shade700,
                      size: 16,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget buildColorSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Renk Seç', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Container(
          height: 50,
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: listColors.length,
            itemBuilder: (context, index) {
              final color = listColors[index];
              final isSelected = color.red == selectedColor.red && 
                              color.green == selectedColor.green && 
                              color.blue == selectedColor.blue;
              
              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedColor = color;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? Colors.white : Colors.transparent,
                      width: 2,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: color.withAlpha(100),
                              blurRadius: 3,
                              spreadRadius: 0.5,
                            )
                          ]
                        : null,
                  ),
                  width: isSelected ? 35 : 32,
                  height: isSelected ? 35 : 32,
                  child: isSelected 
                      ? const Icon(Icons.check, color: Colors.white, size: 16)
                      : null,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: isSubmitting ? null : () => Navigator.of(context).pop(),
          style: TextButton.styleFrom(
            visualDensity: VisualDensity.compact,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          child: const Text('İptal'),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          onPressed: isSubmitting ? null : submit,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            backgroundColor: selectedColor,
            visualDensity: VisualDensity.compact,
          ),
          child:
              isSubmitting
                  ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                  : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(submitButtonIcon, color: Colors.white, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        submitButtonText,
                        style: const TextStyle(color: Colors.white, fontSize: 14),
                      ),
                    ],
                  ),
        ),
      ],
    );
  }
}
