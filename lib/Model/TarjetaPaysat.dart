class CreditCardPaysat {
  String? id;
  final String cardNumber;
  final String cardHolderName;
  final String expirationDate;
  final String cvv;
  final String cardType;
  final bool isValid;
  String? uid;
  double? saldo;

  CreditCardPaysat({
    this.id,
    required this.cardNumber,
    required this.cardHolderName,
    required this.expirationDate,
    required this.cvv,
    required this.cardType,
    required this.isValid,
    this.uid,
    this.saldo = 0.0,
  });

  Map<String, dynamic> toMap() {
    return {
      'cardNumber': cardNumber,
      'cardHolderName': cardHolderName,
      'expirationDate': expirationDate,
      'cvv': cvv,
      'cardType': cardType,
      'isValid': isValid,
      'uid': uid,
      'saldo': saldo,
    };
  }

  factory CreditCardPaysat.fromMap(Map<String, dynamic> map, {String? id}) {
    return CreditCardPaysat(
      id: id,
      cardNumber: map['cardNumber'] ?? '',
      cardHolderName: map['cardHolderName'] ?? '',
      expirationDate: map['expirationDate'] ?? '',
      cvv: map['cvv'] ?? '',
      cardType: map['cardType'] ?? '',
      isValid: map['isValid'] ?? false,
      uid: map['uid'],
      saldo: (map['saldo'] ?? 0.0).toDouble(),
    );
  }
}
