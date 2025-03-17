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
    'Bakliyat & Tahıllar',
    'Dondurulmuş Gıdalar',
    'Baharatlar & Soslar',
    'Diğer',
  ];
  
  // Kategori bazlı örnek ürünler
  static const Map<String, List<String>> categoryProducts = {
    'Meyve & Sebze': ['Elma', 'Muz', 'Portakal', 'Domates', 'Salatalık', 'Patates', 'Soğan', 'Limon', 'Biber', 'Marul', 'Brokoli', 'Havuç', 'Ispanak', 'Avokado', 'Çilek', 'Üzüm', 'Karpuz', 'Kavun', 'Ananas', 'Mango', 'Kivi', 'Nar', 'Erik', 'Şeftali', 'Kayısı', 'Kiraz', 'Mandalina', 'Greyfurt', 'Armut', 'Turp', 'Pırasa', 'Kereviz', 'Enginar', 'Kabak', 'Patlıcan', 'Fasulye', 'Bezelye', 'Mantar', 'Sarımsak', 'Zencefil', 'Zerdeçal'],
    'Et & Tavuk': ['Kıyma', 'Tavuk Göğsü', 'Kuşbaşı', 'Biftek', 'Balık', 'Sucuk', 'Sosis', 'Jambon', 'Hindi', 'Kuzu Pirzola', 'Dana Antrikot', 'Tavuk Kanat', 'Tavuk But', 'Somon', 'Karides', 'Midye', 'Kalamar', 'Levrek', 'Çipura', 'Alabalık', 'Dana Rosto', 'Tavuk Nugget', 'Tavuk Şinitzel', 'Tavuk Ciğeri', 'Tavuk Yüreği'],
    'Süt Ürünleri': ['Süt', 'Yoğurt', 'Peynir', 'Tereyağı', 'Kaymak', 'Ayran', 'Kefir', 'Kaşar', 'Labne', 'Krema', 'Mozzarella', 'Beyaz Peynir', 'Çedar', 'Feta', 'Ricotta', 'Mascarpone', 'Parmesan', 'Rokfor', 'Gouda', 'Brie', 'Camembert', 'Tulum Peyniri', 'Lor Peyniri', 'Süzme Yoğurt', 'Ayran', 'Kefir'],
    'İçecekler': ['Su', 'Meyve Suyu', 'Kola', 'Çay', 'Kahve', 'Gazoz', 'Maden Suyu', 'Ayran', 'Enerji İçeceği', 'Smoothie', 'Limonata', 'Şalgam', 'Bira', 'Şarap', 'Votka', 'Viski', 'Rom', 'Cin', 'Likör', 'Sıcak Çikolata', 'Bitki Çayı', 'Yeşil Çay', 'Sütlü Kahve', 'Espresso', 'Cappuccino', 'Latte', 'Mocha'],
    'Temizlik': ['Deterjan', 'Yumuşatıcı', 'Bulaşık Deterjanı', 'Çamaşır Suyu', 'Temizlik Bezi', 'Sünger', 'Çöp Poşeti', 'Cam Temizleyici', 'Toz Bezi', 'Tuvalet Kağıdı', 'Kağıt Havlu', 'Sabun', 'Dezenfektan', 'Yüzey Temizleyici', 'Klozet Temizleyici', 'Fırça', 'Mop', 'Süpürge', 'Toz Torbası', 'Eldiven', 'Temizlik Spreyi', 'Leke Çıkarıcı'],
    'Kişisel Bakım': ['Şampuan', 'Sabun', 'Diş Macunu', 'Duş Jeli', 'Tıraş Köpüğü', 'Deodorant', 'Pamuk', 'Yüz Kremi', 'El Kremi', 'Saç Kremi', 'Parfüm', 'Tıraş Bıçağı', 'Diş Fırçası', 'Göz Kremi', 'Vücut Losyonu', 'Dudak Balmı', 'Tırnak Makası', 'Cımbız', 'Makyaj Temizleyici', 'Makyaj Pamuğu', 'Saç Spreyi', 'Saç Jölesi', 'Saç Köpüğü'],
    'Atıştırmalık': ['Çikolata', 'Bisküvi', 'Cips', 'Kuruyemiş', 'Kraker', 'Gofret', 'Kek', 'Dondurma', 'Jelibon', 'Patlamış Mısır', 'Çubuk Kraker', 'Çikolatalı Bar', 'Enerji Barı', 'Kurabiye', 'Lokum', 'Pestil', 'Cezerye', 'Leblebi', 'Fındık', 'Fıstık', 'Badem', 'Ceviz', 'Kaju', 'Kuru Üzüm', 'Kuru Kayısı', 'Kuru İncir'],
    'Ev Gereçleri': ['Pil', 'Ampul', 'Çivi', 'Tornavida', 'Mum', 'Kibrit', 'Bant', 'Çekiç', 'Tornavida Seti', 'Makas', 'Yapıştırıcı', 'Fırça', 'Süpürge', 'Ütü', 'Elektrik Süpürgesi', 'Çamaşır Sepeti', 'Ütü Masası', 'Çamaşır İpi', 'Askı', 'Çöp Kovası', 'Çöp Torbası', 'Temizlik Kovası', 'Temizlik Fırçası'],
    'Bakliyat & Tahıllar': ['Pirinç', 'Bulgur', 'Mercimek', 'Nohut', 'Fasulye', 'Makarna', 'Yulaf', 'Kinoa', 'Arpa', 'Çavdar', 'Buğday', 'Kuskus', 'Kinoa', 'Karabuğday', 'Mısır Unu', 'İrmik', 'Tarhana', 'Erişte', 'Şehriye', 'Bulgur Pilavı', 'Kuskus', 'Kinoa'],
    'Dondurulmuş Gıdalar': ['Dondurulmuş Pizza', 'Dondurulmuş Sebzeler', 'Dondurma', 'Dondurulmuş Köfte', 'Dondurulmuş Patates', 'Dondurulmuş Meyve', 'Dondurulmuş Börek', 'Dondurulmuş Balık', 'Dondurulmuş Tavuk', 'Dondurulmuş Deniz Ürünleri', 'Dondurulmuş Hamur', 'Dondurulmuş Tatlılar'],
    'Baharatlar & Soslar': ['Tuz', 'Karabiber', 'Ketçap', 'Mayonez', 'Zeytinyağı', 'Sirke', 'Pul Biber', 'Kekik', 'Nane', 'Kimyon', 'Hardal', 'Acı Sos', 'Barbekü Sos', 'Soya Sosu', 'Balzamik Sirke', 'Zerdeçal', 'Zencefil', 'Tarçın', 'Vanilya', 'Safran', 'Karanfil', 'Anason', 'Sumak', 'Defne Yaprağı', 'Biberiye'],
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
