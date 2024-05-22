class Address {
  String id;
  String address;

  Address({
    required this.id,
    required this.address,
  });

  factory Address.fromFirestore(Map<String, dynamic> data, String documentId) {
    return Address(
      id: documentId,
      address: data['address'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'address': address,
    };
  }
}
