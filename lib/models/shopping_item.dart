import 'package:hive/hive.dart';

part 'shopping_item.g.dart';

@HiveType(typeId: 0)
class ShoppingItem extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  bool isPurchased;

  @HiveField(3)
  DateTime createdAt;

  ShoppingItem({
    required this.id,
    required this.name,
    this.isPurchased = false,
    required this.createdAt,
  });
} 