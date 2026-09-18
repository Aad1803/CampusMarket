class ProductModel {
  final String productId;
  final String name;
  final double price;
  final String description;
  final String category;
  final String condition;
  final List<String> images;
  final String sellerName;
  final String sellerUniversity;
  final String userId;
  final DateTime? createdAt;
  final String status;

  ProductModel({
    required this.productId,
    required this.name,
    required this.price,
    required this.description,
    required this.category,
    required this.condition,
    required this.images,
    required this.sellerName,
    required this.sellerUniversity,
    required this.userId,
    required this.createdAt,
    required this.status,
  });

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'name': name,
      'price': price,
      'description': description,
      'category': category,
      'condition': condition,
      'images': images,
      'sellerName': sellerName,
      'sellerUniversity': sellerUniversity,
      'userId': userId,
      'createdAt': createdAt,
      'status': status,
    };
  }
}
