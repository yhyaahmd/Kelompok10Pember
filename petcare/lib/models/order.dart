class Order {
  final String? id;
  final String? userId;
  final String productId;
  final int quantity;
  final double totalPrice;
  final String customerName;
  final String customerPhone;
  final String customerAddress;
  final String status;
  final DateTime? createdAt;

  Order({
    this.id,
    this.userId,
    required this.productId,
    required this.quantity,
    required this.totalPrice,
    required this.customerName,
    required this.customerPhone,
    required this.customerAddress,
    this.status = 'pending',
    this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'product_id': productId,
      'quantity': quantity,
      'total_price': totalPrice,
      'customer_name': customerName,
      'customer_phone': customerPhone,
      'customer_address': customerAddress,
      'status': status,
    };
  }

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      userId: json['user_id'],
      productId: json['product_id'],
      quantity: json['quantity'],
      totalPrice: double.parse(json['total_price'].toString()),
      customerName: json['customer_name'],
      customerPhone: json['customer_phone'],
      customerAddress: json['customer_address'],
      status: json['status'] ?? 'pending',
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
    );
  }
}
