import 'constants.dart';

/// Kategori tespiti için yardımcı sınıf
class CategoryHelper {
  /// Ürün adına göre en uygun kategoriyi tespit eder
  static String detectCategory(String productName) {
    if (productName.isEmpty) {
      return Constants.defaultCategory;
    }

    final lowercaseName = productName.toLowerCase();
    
    // Tam eşleşme kontrolü
    for (final entry in Constants.categoryProducts.entries) {
      if (entry.value.any((product) => product.toLowerCase() == lowercaseName)) {
        return entry.key;
      }
    }
    
    // Anahtar kelime kontrolü
    for (final entry in Constants.categoryKeywords.entries) {
      if (entry.value.any((keyword) => lowercaseName.contains(keyword.toLowerCase()))) {
        return entry.key;
      }
    }
    
    // Eşleşme bulunamazsa varsayılan kategori
    return Constants.defaultCategory;
  }
  
  /// Kategoriye göre önerilen ürünleri döndürür
  static List<String> getSuggestionsForCategory(String category) {
    return Constants.categoryProducts[category] ?? [];
  }
  
  /// Tüm kategorilerdeki ürünleri birleştirip döndürür
  static List<String> getAllProducts() {
    final List<String> allProducts = [];
    
    Constants.categoryProducts.forEach((category, products) {
      allProducts.addAll(products);
    });
    
    return allProducts;
  }
} 