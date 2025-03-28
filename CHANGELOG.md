# Alışveriş Listesi Uygulaması - Değişiklik Günlüğü

Bu dosya, Alışveriş Listesi uygulamasının önemli değişikliklerini belgelemektedir.

## [1.1.3] - 2025-03-19

### Düzeltilen
- İkon rengi sorunu çözüldü - seçilen renkle uyumlu kontrast renk otomatik olarak belirleniyor
- Renk dönüşüm işlemlerinde (`color.r.round()` yerine `color.red`) kullanılarak daha doğru renk dönüşümü sağlandı
- `Color.fromRGBO()` yerine `Color.fromARGB()` kullanılarak daha tutarlı renk üretimi sağlandı
- Null veya geçersiz renk değerleri için ek kontroller eklendi
- Web build işlemi için base-href parametresi eklendi

## [1.1.2] - 2025-03-18

### Eklenen
- Çoklu ürün ekleme özelliği - alt alta yazılan ürünleri tek seferde ekleme
- Web sürümü için iyileştirmeler ve klavye giriş desteği
- GitHub Pages web sürümü desteği ve güncellemesi

### Değiştirilen
- Ürün ekleme diyaloğu artık çoklu satır destekliyor
- Web sürümü için build komutuna `--base-href` parametresi eklendi
- Repository yapısı iyileştirildi, gereksiz build dosyaları silindi

### Düzeltilen
- Web sürümünde Enter tuşu davranışı iyileştirildi
- GitHub Pages web uygulaması yolları düzeltildi
- TextFormField duyarlılığı artırıldı

## [1.1.1] - 2025-03-18

### Eklenen
- Kategori işlemleri ile ürünleri daha kolay yönetebilme
- Akıllı arama özellikleri ile ürünleri tüm listelerde arma yapabilme
- Çeşitli sıralama ölçütleri (alfabe, tarih, kategori,önem,özelleştirlmiş)

### Değiştirilen
- Kullanılmayan `../utils/color_utils.dart` importu `add_list_dialog.dart` dosyasından kaldırıldı
- Deprecated API kullanımları güncellendi: 
  - `color_utils.dart` dosyasında `backgroundColor.red`, `backgroundColor.green`, ve `backgroundColor.blue` -> `backgroundColor.r`, `backgroundColor.g`, ve `backgroundColor.b` olarak güncellendi
  - `base_list_dialog.dart` dosyasında `selectedColor.value` ve `color.value` -> `selectedColor.hashCode` ve `color.hashCode` olarak güncellendi
  - `withOpacity()` -> `withAlpha()` ile değiştirildi 
- `color_utils.dart` dosyasında null-aware operatörler (`??=`) kullanılarak kod daha modern hale getirildi

### Düzeltilen
- Dart ve Flutter stil klavuzlarına uyum sağlandı
- Kod kalitesi ve okunabilirliği artırıldı
- Bellek ve performans verimliliği iyileştirildi

## [1.1.0] - 2025-03-17

### Eklenen
- Yeni liste oluşturma ve birden fazla liste yönetebilme özelliği
- Liste öğelerinin renk kodlaması
- Ürünleri satın alındı olarak işaretleme özelliği 
- Tarih bazlı filtreleme seçenekleri

### Değiştirilen
- Arayüz tasarımı yenilendi
- Performans iyileştirmeleri
- Renkli liste arka planları eklendi

### Düzeltilen
- Renk işleme ile ilgili sorunlar giderildi
- Satın alınma işaretlemesindeki gecikmeler düzeltildi
- Arayüz bileşenlerinin yerleşimindeki sorunlar düzeltildi

## [1.0.0] - İlk Sürüm

### Özellikler
- Alışveriş öğeleri ekleme, düzenleme ve silme
- Öğeleri satın alındı olarak işaretleme
- Eklenme zamanı bilgisi gösterimi
- Öğeleri kaydırarak silme özelliği
- Yaygın kullanılan ürünler için öneriler
- Tamamlanan öğeleri toplu temizleme
- Açık ve koyu tema desteği
- Hive veritabanı ile yerel depolama
- Android, iOS ve Web platformları desteği 