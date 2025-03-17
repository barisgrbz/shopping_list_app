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
  static const String defaultCategory = 'Diğer';
  
  // Tüm kategoriler listesi
  static const List<String> defaultCategories = [
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
  
  // Kategori bazlı örnek ürünler
  static const Map<String, List<String>> categoryProducts = {
    'Meyve & Sebze': ['Elma', 'Muz', 'Portakal', 'Domates', 'Salatalık', 'Patates', 'Soğan', 'Limon', 'Biber'],
    'Et & Tavuk': ['Kıyma', 'Tavuk Göğsü', 'Kuşbaşı', 'Biftek', 'Balık', 'Sucuk', 'Sosis', 'Jambon'],
    'Süt Ürünleri': ['Süt', 'Yoğurt', 'Peynir', 'Tereyağı', 'Kaymak', 'Ayran', 'Kefir', 'Kaşar'],
    'İçecekler': ['Su', 'Meyve Suyu', 'Kola', 'Çay', 'Kahve', 'Gazoz', 'Maden Suyu', 'Ayran'],
    'Temizlik': ['Deterjan', 'Yumuşatıcı', 'Bulaşık Deterjanı', 'Çamaşır Suyu', 'Temizlik Bezi', 'Sünger', 'Çöp Poşeti'],
    'Kişisel Bakım': ['Şampuan', 'Sabun', 'Diş Macunu', 'Duş Jeli', 'Tıraş Köpüğü', 'Deodorant', 'Pamuk'],
    'Atıştırmalık': ['Çikolata', 'Bisküvi', 'Cips', 'Kuruyemiş', 'Kraker', 'Gofret', 'Kek'],
    'Ev Gereçleri': ['Pil', 'Ampul', 'Çivi', 'Tornavida', 'Mum', 'Kibrit', 'Bant'],
    'Diğer': ['Not Defteri', 'Kalem', 'Balon', 'Hediye Paketi', 'Oyuncak', 'Kitap'],
  };
  
  // Kategori anahtar kelimeleri (otomatik kategori tespiti için)
  static const Map<String, List<String>> categoryKeywords = {
    'Meyve & Sebze': ['meyve', 'sebze', 'elma', 'muz', 'portakal', 'domates', 'salatalık', 'patates', 'soğan', 'limon', 'biber', 'yeşil', 'taze'],
    'Et & Tavuk': ['et', 'tavuk', 'kıyma', 'biftek', 'kuşbaşı', 'balık', 'sucuk', 'sosis', 'jambon', 'hindi', 'köfte'],
    'Süt Ürünleri': ['süt', 'yoğurt', 'peynir', 'tereyağ', 'kaymak', 'ayran', 'kefir', 'kaşar', 'çökelek', 'lor'],
    'İçecekler': ['su', 'meyve suyu', 'kola', 'çay', 'kahve', 'gazoz', 'maden suyu', 'ayran', 'içecek', 'içmek', 'şişe'],
    'Temizlik': ['deterjan', 'yumuşatıcı', 'bulaşık', 'çamaşır suyu', 'temizlik', 'sünger', 'çöp poşeti', 'temiz', 'hijyen'],
    'Kişisel Bakım': ['şampuan', 'sabun', 'diş macunu', 'duş jeli', 'tıraş', 'deodorant', 'pamuk', 'saç', 'cilt', 'krem'],
    'Atıştırmalık': ['çikolata', 'bisküvi', 'cips', 'kuruyemiş', 'kraker', 'gofret', 'kek', 'atıştırmalık', 'tatlı', 'şeker'],
    'Ev Gereçleri': ['pil', 'ampul', 'çivi', 'tornavida', 'mum', 'kibrit', 'bant', 'elektrik', 'tamir', 'alet'],
  };
}
