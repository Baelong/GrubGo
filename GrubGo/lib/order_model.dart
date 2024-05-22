class Order {
  final String id;
  final String address;
  final String paymentMethod;
  final double subtotal;
  final double taxes;
  final double deliveryFee;
  final double total;
  final DateTime date;
  final List<Map<String, dynamic>> items;

  Order({
    required this.id,
    required this.address,
    required this.paymentMethod,
    required this.subtotal,
    required this.taxes,
    required this.deliveryFee,
    required this.total,
    required this.date,
    required this.items,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'address': address,
      'paymentMethod': paymentMethod,
      'subtotal': subtotal,
      'taxes': taxes,
      'deliveryFee': deliveryFee,
      'total': total,
      'date': date.toIso8601String(),
      'items': items,
    };
  }

  factory Order.fromMap(Map<String, dynamic> map) {
    return Order(
      id: map['id'],
      address: map['address'],
      paymentMethod: map['paymentMethod'],
      subtotal: map['subtotal'],
      taxes: map['taxes'],
      deliveryFee: map['deliveryFee'],
      total: map['total'],
      date: DateTime.parse(map['date']),
      items: List<Map<String, dynamic>>.from(map['items']),
    );
  }
}
