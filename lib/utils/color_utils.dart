import 'package:flutter/material.dart';
import 'app_logger.dart';

/// Renklerle ilgili yardımcı fonksiyonlar
class ColorUtils {
  static const String _tag = 'ColorUtils';

  /// Renk nesnesini RRGGBB formatında string'e dönüştürür
  static String colorToString(Color color) {
    // round() kullanımını kaldıralım, doğrudan integer değere dönüşüm yapalım
    String redHex = color.red.toRadixString(16).padLeft(2, '0');
    String greenHex = color.green.toRadixString(16).padLeft(2, '0');
    String blueHex = color.blue.toRadixString(16).padLeft(2, '0');
    return "$redHex$greenHex$blueHex";
  }

  /// RRGGBB formatındaki string'i Color nesnesine dönüştürür
  static Color? colorFromString(String? colorString) {
    if (colorString == null || colorString.isEmpty) {
      AppLogger.log(_tag, 'colorFromString: null veya boş string geldi');
      return null;
    }

    try {
      // Giriş string'ini normalize et
      String normalizedColor = colorString.replaceAll('#', '').trim();
      AppLogger.log(
        _tag,
        'colorFromString: Giriş: "$colorString", Normalize: "$normalizedColor"',
      );

      if (normalizedColor.length > 6) {
        normalizedColor = normalizedColor.substring(0, 6);
        AppLogger.log(
          _tag,
          'colorFromString: String çok uzun, kısaltıldı: "$normalizedColor"',
        );
      }

      if (normalizedColor.length < 6) {
        normalizedColor = normalizedColor.padRight(6, '0');
        AppLogger.log(
          _tag,
          'colorFromString: String çok kısa, uzatıldı: "$normalizedColor"',
        );
      }

      // String'i bileşenlerine ayır ve renk oluştur
      final int r = int.parse(normalizedColor.substring(0, 2), radix: 16);
      final int g = int.parse(normalizedColor.substring(2, 4), radix: 16);
      final int b = int.parse(normalizedColor.substring(4, 6), radix: 16);

      // Color.fromRGBO yerine Color() constructor'ı kullanarak daha tutarlı bir dönüşüm yapalım
      final color = Color.fromARGB(255, r, g, b);

      AppLogger.logColorStringConversion(_tag, normalizedColor, color);

      return color;
    } catch (e) {
      AppLogger.logError(_tag, 'colorFromString', e);
      return null;
    }
  }

  /// Renk adına göre renk objesi döndürür
  static Color? colorFromName(String? colorName) {
    if (colorName == null || colorName.isEmpty) {
      AppLogger.log(_tag, 'colorFromName: null veya boş string geldi');
      return null;
    }

    // Renk adını standardize et (küçük harf, boşlukları kaldır)
    final standardName = colorName.toLowerCase().trim();
    AppLogger.log(_tag, 'colorFromName: Aranan renk adı: "$standardName"');

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
      AppLogger.logColor(
        _tag,
        'colorFromName: Renk bulundu - "$standardName"',
        foundColor,
      );
      return foundColor;
    }

    AppLogger.log(_tag, 'colorFromName: Renk bulunamadı - "$standardName"');
    return null;
  }

  /// String veya renk adından renk oluştur (varsa), yoksa varsayılan rengi döndür
  static Color getColorOrDefault(dynamic colorInput, Color defaultColor) {
    if (colorInput == null) {
      return defaultColor;
    }

    Color? result;

    if (colorInput is String) {
      // Önce hex string olarak dene
      result ??= colorFromString(colorInput);

      // Olmadıysa isim olarak dene
      result ??= colorFromName(colorInput);
    } else if (colorInput is Color) {
      result = colorInput;
    }

    return result ?? defaultColor;
  }

  /// Arka plan rengine göre kontrast renk döndürür (koyu arka plana açık yazı, açık arka plana koyu yazı)
  static Color getContrastColor(Color? backgroundColor) {
    if (backgroundColor == null) {
      AppLogger.log(
        _tag,
        'getContrastColor: Arka plan rengi null, varsayılan olarak beyaz döndürülüyor',
      );
      return Colors.white;
    }

    // Rengin parlaklığını hesapla (0-1 arası)
    // Formül: (0.299*R + 0.587*G + 0.114*B) / 255
    final double luminance =
        (0.299 * backgroundColor.r +
            0.587 * backgroundColor.g +
            0.114 * backgroundColor.b) /
        255;

    AppLogger.log(
      _tag,
      'getContrastColor: Parlaklık: $luminance, RGB(${backgroundColor.r},${backgroundColor.g},${backgroundColor.b})',
    );

    // Parlaklık 0.5'ten büyükse koyu, küçükse açık renk döndür
    return luminance > 0.5 ? Colors.black : Colors.white;
  }

  /// Renk geçerliliğini test et ve log oluştur
  static bool validateColor(String tag, String colorString) {
    final Color? color = colorFromString(colorString);
    final bool isValid = color != null;

    if (isValid) {
      AppLogger.logColorStringConversion(tag, colorString, color);
    } else {
      AppLogger.log(tag, 'Renk doğrulama başarısız: "$colorString"');
    }

    return isValid;
  }
}
