import 'package:flutter/material.dart';

/// İkonlarla ilgili yardımcı fonksiyonlar
class IconUtils {
  /// String'den [IconData] objesine dönüştürür
  static IconData getIconData(String? iconString) {
    if (iconString == null || iconString.isEmpty) {
      return Icons.list_alt; // Varsayılan ikon
    }
    
    const Map<String, IconData> iconMap = {
      'list_alt': Icons.list_alt,
      'shopping_bag': Icons.shopping_bag,
      'shopping_cart': Icons.shopping_cart,
      'shopping_basket': Icons.shopping_basket,
      'store': Icons.store,
      'local_grocery_store': Icons.local_grocery_store,
      'kitchen': Icons.kitchen,
      'home': Icons.home,
      'sports_esports': Icons.sports_esports,
      'devices': Icons.devices,
      'school': Icons.school,
      'weekend': Icons.weekend,
    };
    
    // Eğer ikon ismi ile eşleşme varsa onu döndür
    if (iconMap.containsKey(iconString)) {
      return iconMap[iconString]!;
    }
    
    // Eşleşme yoksa varsayılan ikonu döndür
    return Icons.list_alt; // Varsayılan ikon
  }
  
  /// Ikon değerini string'e dönüştürür (kaydetmek için)
  static String iconToString(IconData icon) {
    // Bilinen ikonların isimleri
    Map<IconData, String> iconNameMap = {
      Icons.list_alt: 'list_alt',
      Icons.shopping_bag: 'shopping_bag',
      Icons.shopping_cart: 'shopping_cart',
      Icons.shopping_basket: 'shopping_basket',
      Icons.store: 'store',
      Icons.local_grocery_store: 'local_grocery_store',
      Icons.kitchen: 'kitchen',
      Icons.home: 'home',
      Icons.sports_esports: 'sports_esports',
      Icons.devices: 'devices',
      Icons.school: 'school',
      Icons.weekend: 'weekend',
    };
    
    // Eğer bilinen bir ikon ise ismini döndür
    if (iconNameMap.containsKey(icon)) {
      return iconNameMap[icon]!;
    }
    
    // Bilinmeyen ikonlar için code point'i string olarak döndür
    return icon.codePoint.toString();
  }
  
  /// Alışveriş listesi için önceden tanımlanmış ikonlar
  static List<IconData> get shoppingListIcons => [
    Icons.list_alt,
    Icons.shopping_bag,
    Icons.shopping_cart,
    Icons.shopping_basket,
    Icons.store,
    Icons.local_grocery_store,
    Icons.kitchen,
    Icons.home,
    Icons.sports_esports,
    Icons.devices,
    Icons.school,
    Icons.weekend,
  ];
  
  /// Alışveriş listeleri için kullanılabilecek temel renk listesi
  static List<Color> get shoppingListColors => [
    Colors.red,
    Colors.pink,
    Colors.purple,
    Colors.deepPurple,
    Colors.indigo,
    Colors.blue,
    Colors.lightBlue,
    Colors.cyan,
    Colors.teal,
    Colors.green,
    Colors.lightGreen, 
    Colors.lime,
    Colors.yellow,
    Colors.amber,
    Colors.orange,
    Colors.deepOrange,
    Colors.brown,
    Colors.grey,
    Colors.blueGrey,
    Colors.black,
  ];
}
