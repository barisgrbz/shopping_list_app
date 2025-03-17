import 'package:flutter/material.dart';
import 'dart:developer' as developer;

/// Renklerle ilgili yardımcı fonksiyonlar
class ColorUtils {
  /// Renk nesnesini RRGGBB formatında string'e dönüştürür
  static String colorToString(Color color) {
    // RGB değerlerini doğrudan int değerlere dönüştür ve hex string oluştur
    final int r = color.red; 
    final int g = color.green;
    final int b = color.blue;
    
    String hexString = 
      r.toRadixString(16).padLeft(2, '0') +
      g.toRadixString(16).padLeft(2, '0') +
      b.toRadixString(16).padLeft(2, '0');
    
    developer.log('ColorUtils.colorToString: RGB($r,$g,$b) => $hexString');
    
    return hexString;
  }

  /// RRGGBB formatındaki string'i Color nesnesine dönüştürür
  static Color? colorFromString(String? colorString) {
    if (colorString == null || colorString.isEmpty) {
      developer.log('ColorUtils.colorFromString: null veya boş string geldi');
      return null;
    }

    try {
      // Giriş string'ini normalize et
      String normalizedColor = colorString.replaceAll('#', '').trim();
      developer.log('ColorUtils.colorFromString: Giriş: "$colorString", Normalize: "$normalizedColor"');
      
      if (normalizedColor.length > 6) {
        normalizedColor = normalizedColor.substring(0, 6);
        developer.log('ColorUtils.colorFromString: String çok uzun, kısaltıldı: "$normalizedColor"');
      }
      
      if (normalizedColor.length < 6) {
        normalizedColor = normalizedColor.padRight(6, '0');
        developer.log('ColorUtils.colorFromString: String çok kısa, uzatıldı: "$normalizedColor"');
      }

      // String'i bileşenlerine ayır ve renk oluştur
      final int r = int.parse(normalizedColor.substring(0, 2), radix: 16);
      final int g = int.parse(normalizedColor.substring(2, 4), radix: 16);
      final int b = int.parse(normalizedColor.substring(4, 6), radix: 16);
      
      final color = Color.fromRGBO(r, g, b, 1.0);
      
      developer.log('ColorUtils.colorFromString: "$normalizedColor" => RGB(${color.red},${color.green},${color.blue})');
      
      return color;
    } catch (e) {
      developer.log('ColorUtils.colorFromString: Hata oluştu: $e');
      return null;
    }
  }
  
  /// Renk adına göre renk objesi döndürür
  static Color? colorFromName(String? colorName) {
    if (colorName == null || colorName.isEmpty) {
      developer.log('ColorUtils.colorFromName: null veya boş string geldi');
      return null;
    }

    // Renk adını standardize et (küçük harf, boşlukları kaldır)
    final standardName = colorName.toLowerCase().trim();
    developer.log('ColorUtils.colorFromName: Aranan renk adı: "$standardName"');

    // Temel renkler için map
    final Map<String, Color> namedColors = {
      'kırmızı': Colors.red,
      'red': Colors.red,
      'mavi': Colors.blue,
      'blue': Colors.blue,
      'yeşil': Colors.green,
      'green': Colors.green,
      'sarı': Colors.yellow,
      'yellow': Colors.yellow,
      'turuncu': Colors.orange,
      'orange': Colors.orange,
      'mor': Colors.purple,
      'purple': Colors.purple,
      'pembe': Colors.pink,
      'pink': Colors.pink,
      'kahverengi': Colors.brown,
      'brown': Colors.brown,
      'gri': Colors.grey,
      'grey': Colors.grey,
      'siyah': Colors.black,
      'black': Colors.black,
      'beyaz': Colors.white,
      'white': Colors.white,
      'indigo': Colors.indigo,
      'teal': Colors.teal,
      'cyan': Colors.cyan,
    };

    final foundColor = namedColors[standardName];
    if (foundColor != null) {
      developer.log('ColorUtils.colorFromName: Renk bulundu - "$standardName" => RGB(${foundColor.red},${foundColor.green},${foundColor.blue})');
      return foundColor;
    }

    developer.log('ColorUtils.colorFromName: Renk bulunamadı - "$standardName"');
    return null;
  }
  
  /// Arka plan rengine göre okunabilir metin rengi döndürür
  static Color getContrastColor(Color? backgroundColor) {
    if (backgroundColor == null) {
      developer.log('ColorUtils.getContrastColor: Arka plan rengi null, varsayılan olarak beyaz döndürülüyor');
      return Colors.white;
    }

    // Parlaklık hesapla
    final luminance = (0.299 * backgroundColor.red + 
                         0.587 * backgroundColor.green + 
                         0.114 * backgroundColor.blue) / 255;

    developer.log('ColorUtils.getContrastColor: Parlaklık: $luminance, RGB(${backgroundColor.red},${backgroundColor.green},${backgroundColor.blue})');
    
    final contrastColor = luminance > 0.5 ? Colors.black : Colors.white;
    
    return contrastColor;
  }
}
