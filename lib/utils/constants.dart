/// Uygulama için sabit değerler
class Constants {
  // Hive Box adları
  static const String itemsBoxName = 'shopping_items';
  static const String listsBoxName = 'shopping_lists';

  // Hive Type ID'leri
  static const int shoppingItemTypeId = 0;
  static const int shoppingListTypeId = 1;

  // Varsayılan liste adı
  static const String defaultListName = 'Alışveriş Listem';

  // UI sabitleri
  static const double dialogBorderRadius = 16.0;
  static const double cardBorderRadius = 12.0;
  static const double inputBorderRadius = 8.0;

  // Animation sabitleri
  static const int animationDurationMs = 500;

  // Min-Max Değerler
  static const int maxListNameLength = 50;
  static const int maxItemNameLength = 100;
  
  // Kategori sabitleri
  static const String defaultCategory = 'Genel';
  static const List<String> defaultCategories = [
    'Genel',
    'Meyve & Sebze',
    'Et & Tavuk',
    'Süt Ürünleri',
    'İçecekler',
    'Temizlik',
    'Kişisel Bakım',
    'Atıştırmalık',
    'Ev Gereçleri',
    'Diğer',
  ];
  
  // Kategorilere göre yaygın ürünler
  static const Map<String, List<String>> categoryProducts = {
    'Meyve & Sebze': ['Elma', 'Muz', 'Portakal', 'Domates', 'Salatalık', 'Soğan', 'Patates', 'Biber', 'Ispanak', 'Maydanoz', 'Havuç'],
    'Et & Tavuk': ['Kıyma', 'Tavuk Göğsü', 'Kuşbaşı', 'Dana Et', 'Köfte', 'Tavuk But', 'Balık', 'Hindi', 'Sucuk', 'Sosis'],
    'Süt Ürünleri': ['Süt', 'Peynir', 'Yoğurt', 'Tereyağı', 'Kaymak', 'Kaşar', 'Ayran', 'Kefir', 'Krema'],
    'İçecekler': ['Su', 'Çay', 'Kahve', 'Meyve Suyu', 'Kola', 'Soda', 'Gazoz', 'Ayran', 'Limonata'],
    'Temizlik': ['Deterjan', 'Yumuşatıcı', 'Çamaşır Suyu', 'Bulaşık Sabunu', 'Temizlik Bezi', 'Cam Sil', 'Yüzey Temizleyici'],
    'Kişisel Bakım': ['Şampuan', 'Duş Jeli', 'Diş Macunu', 'Sabun', 'Tıraş Köpüğü', 'Deodorant', 'Islak Mendil'],
    'Atıştırmalık': ['Cips', 'Çikolata', 'Bisküvi', 'Kraker', 'Kuruyemiş', 'Gofret', 'Çekirdek', 'Kek'],
    'Ev Gereçleri': ['Ampul', 'Pil', 'Kibrit', 'Mum', 'Peçete', 'Kağıt Havlu', 'Tuvalet Kağıdı', 'Çöp Poşeti'],
    'Genel': ['Ekmek', 'Tuz', 'Şeker', 'Un', 'Makarna', 'Pirinç', 'Yumurta', 'Yağ', 'Salça', 'Bulgur'],
    'Diğer': [],
  };
  
  // Ürün kategori eşleştirme için kelime tabanlı tespit sistemi
  static const Map<String, List<String>> categoryKeywords = {
    'Meyve & Sebze': ['meyve', 'sebze', 'taze', 'organik', 'elma', 'muz', 'portakal', 'domates', 'salatalık', 'soğan', 'patates', 'biber', 'ıspanak', 'maydanoz', 'havuç'],
    'Et & Tavuk': ['et', 'tavuk', 'kıyma', 'but', 'göğüs', 'kanat', 'biftek', 'pirzola', 'kuşbaşı', 'sucuk', 'sosis', 'balık', 'hindi', 'köfte'],
    'Süt Ürünleri': ['süt', 'peynir', 'yoğurt', 'kaşar', 'ayran', 'tereyağ', 'kaymak', 'kefir', 'krema'],
    'İçecekler': ['su', 'çay', 'kahve', 'meyve suyu', 'kola', 'gazoz', 'soda', 'limonata', 'şerbet', 'içecek'],
    'Temizlik': ['deterjan', 'temizlik', 'temizleyici', 'çamaşır', 'bulaşık', 'sabun', 'sil', 'parlatıcı', 'bez', 'yumuşatıcı', 'çamaşır suyu'],
    'Kişisel Bakım': ['şampuan', 'duş', 'diş', 'sabun', 'tıraş', 'bakım', 'krem', 'losyon', 'deodorant', 'jel', 'macun', 'mendil'],
    'Atıştırmalık': ['cips', 'çikolata', 'bisküvi', 'gofret', 'kraker', 'kuruyemiş', 'çerez', 'atıştırmalık', 'kek', 'çekirdek'],
    'Ev Gereçleri': ['ampul', 'pil', 'kağıt', 'havlu', 'peçete', 'çöp', 'poşet', 'paket', 'torba', 'kibrit', 'mum', 'tuvalet kağıdı'],
  };
}
