class Payment {
  String id;
  String cardNumber;
  String cardHolderName;
  String expiryDate;
  String cvv;

  Payment({
    required this.id,
    required this.cardNumber,
    required this.cardHolderName,
    required this.expiryDate,
    required this.cvv,
  });

  factory Payment.fromFirestore(Map<String, dynamic> data, String documentId) {
    return Payment(
      id: documentId,
      cardNumber: data['cardNumber'],
      cardHolderName: data['cardHolderName'],
      expiryDate: data['expiryDate'],
      cvv: data['cvv'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'cardNumber': cardNumber,
      'cardHolderName': cardHolderName,
      'expiryDate': expiryDate,
      'cvv': cvv,
    };
  }
}
