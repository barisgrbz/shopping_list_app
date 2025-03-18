# Alışveriş Listesi Uygulaması - Değişiklik Günlüğü

Bu dosya, Alışveriş Listesi uygulamasının önemli değişikliklerini belgelemektedir.

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