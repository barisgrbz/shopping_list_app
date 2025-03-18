import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'models/shopping_item.dart';
import 'models/shopping_list.dart';
import 'providers/shopping_list_provider.dart';
import 'screens/home_screen.dart';
import 'utils/app_logger.dart';

void main() async {
  AppLogger.log('Main', 'Uygulama başlatılıyor');
  
  // Hive'ı başlat
  await Hive.initFlutter();
  AppLogger.log('Main', 'Hive başlatıldı');

  // Adapterleri kaydet
  Hive.registerAdapter(ShoppingItemAdapter());
  Hive.registerAdapter(ShoppingListAdapter());
  AppLogger.log('Main', 'Hive adaptörleri kaydedildi');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    AppLogger.log('MyApp', 'UI yapılandırılıyor');
    
    return ChangeNotifierProvider(
      create: (context) => ShoppingListProvider(),
      child: MaterialApp(
        title: 'Alışveriş Listesi',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            elevation: 0,
          ),
          floatingActionButtonTheme: const FloatingActionButtonThemeData(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
          ),
        ),
        darkTheme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
        ),
        themeMode: ThemeMode.system,
        home: const HomeScreen(),
      ),
    );
  }
}
