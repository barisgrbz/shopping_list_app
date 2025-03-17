import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import '../utils/constants.dart';

part 'shopping_item.g.dart';

@HiveType(typeId: Constants.shoppingItemTypeId)
class ShoppingItem {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  bool isPurchased;

  @HiveField(3)
  final DateTime createdAt;

  @HiveField(4)
  String listId;
  
  @HiveField(5)
  String category;

  ShoppingItem({
    required this.id,
    required this.name,
    required this.isPurchased,
    required this.createdAt,
    required this.listId,
    this.category = Constants.defaultCategory,
  });

  // Factory constructor to create a new item with a default ID
  factory ShoppingItem.create({
    required String name, 
    required String listId,
    String category = Constants.defaultCategory,
  }) {
    return ShoppingItem(
      id: Uuid().v4(),
      name: name,
      isPurchased: false,
      createdAt: DateTime.now(),
      listId: listId,
      category: category,
    );
  }
}
