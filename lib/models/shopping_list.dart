import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import '../utils/constants.dart';

part 'shopping_list.g.dart';

@HiveType(typeId: Constants.shoppingListTypeId)
class ShoppingList {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String? icon;

  @HiveField(3)
  String? color;

  @HiveField(4)
  final DateTime createdAt;

  @HiveField(5)
  int itemCount;

  ShoppingList({
    required this.id,
    required this.name,
    this.icon,
    this.color,
    required this.createdAt,
    this.itemCount = 0,
  });

  // Factory constructor to create a new list with a default ID
  factory ShoppingList.create({
    required String name,
    String? icon,
    String? color,
  }) {
    return ShoppingList(
      id: Uuid().v4(),
      name: name,
      icon: icon,
      color: color,
      createdAt: DateTime.now(),
      itemCount: 0,
    );
  }
}
