import 'dart:developer' as developer;
import 'package:flutter/material.dart';

/// Uygulama genelinde standartlaştırılmış loglama metotları sağlar
class AppLogger {
  /// Genel loglama
  static void log(String tag, String message) {
    developer.log('$tag: $message');
  }

  /// Renk ile ilgili loglar
  static void logColor(String tag, String action, Color color) {
    developer.log('$tag: $action - RGB(${color.r},${color.g},${color.b})');
  }
  
  /// Renk dönüşüm logları
  static void logColorConversion(String tag, String from, String to, Color? color) {
    if (color != null) {
      developer.log('$tag: Dönüşüm $from => $to: RGB(${color.r},${color.g},${color.b})');
    } else {
      developer.log('$tag: Dönüşüm başarısız $from => $to');
    }
  }

  /// Renk string dönüşüm logları
  static void logColorStringConversion(String tag, String colorString, Color? color) {
    if (color != null) {
      developer.log('$tag: String "$colorString" => RGB(${color.r},${color.g},${color.b})');
    } else {
      developer.log('$tag: String dönüşümü başarısız "$colorString"');
    }
  }

  /// İşlem başlangıç/bitiş logları
  static void logOperation(String tag, String operation, {bool isStart = true}) {
    developer.log('$tag: ${isStart ? "Başlıyor" : "Tamamlandı"} - $operation');
  }

  /// Hata logları
  static void logError(String tag, String operation, dynamic error) {
    developer.log('$tag: HATA - $operation: $error');
  }
} 