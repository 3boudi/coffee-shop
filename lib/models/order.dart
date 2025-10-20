import 'dart:convert';

enum OrderStatus { pending, confirmed }

class OrderItem {
  final String productId;
  final int quantity;

  OrderItem({required this.productId, required this.quantity});

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      productId: json['productId'] ?? '',
      quantity: json['quantity'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {'productId': productId, 'quantity': quantity};
  }

  OrderItem copyWith({String? productId, int? quantity}) {
    return OrderItem(
      productId: productId ?? this.productId,
      quantity: quantity ?? this.quantity,
    );
  }
}

class Order {
  final String id;
  final String userId;
  final List<OrderItem> products;
  final OrderStatus status;
  final double totalPrice;
  final DateTime createdAt;
  final DateTime updatedAt;

  Order({
    required this.id,
    required this.userId,
    required this.products,
    required this.status,
    required this.totalPrice,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    List<OrderItem> items = [];
    String productsString = json['products'] ?? '[]';
    try {
      final decoded = jsonDecode(productsString) as List<dynamic>;
      items = decoded
          .map((item) => OrderItem.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      items = [];
    }

    return Order(
      id: json['\$id'] ?? '',
      userId: json['userId'] ?? '',
      products: items,
      status: OrderStatus.values.firstWhere(
        (e) => e.name == (json['status'] ?? 'pending'),
        orElse: () => OrderStatus.pending,
      ),
      totalPrice: (json['totalPrice'] ?? 0.0).toDouble(),
      createdAt: DateTime.parse(
        json['\$createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        json['\$updatedAt'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'products': jsonEncode(products.map((item) => item.toJson()).toList()),
      'status': status.name,
      'totalPrice': totalPrice,
    };
  }

  Order copyWith({
    String? id,
    String? userId,
    List<OrderItem>? products,
    OrderStatus? status,
    double? totalPrice,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Order(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      products: products ?? this.products,
      status: status ?? this.status,
      totalPrice: totalPrice ?? this.totalPrice,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
