class CreditCardVisa {
  String? id;
  String cardNumber;
  String cardHolderName;
  String expirationDate;
  String cvv;
  String cardName;
  String bankProvider;
  double saldo;
  String cardType;

  CreditCardVisa({
    this.id,
    required this.cardNumber,
    required this.cardHolderName,
    required this.expirationDate,
    required this.cvv,
    required this.cardName,
    required this.bankProvider,
    required this.saldo,
    required this.cardType,
  });

  factory CreditCardVisa.fromMap(Map<String, dynamic> map, {String? id}) {
    return CreditCardVisa(
      id: id,
      cardNumber: map['cardNumber'],
      cardHolderName: map['cardHolderName'],
      expirationDate: map['expirationDate'],
      cvv: map['cvv'],
      cardName: map['cardName'],
      bankProvider: map['bankProvider'],
      saldo: _convertToDouble(map['saldo']),
      cardType: map['cardType'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'cardNumber': cardNumber,
      'cardHolderName': cardHolderName,
      'expirationDate': expirationDate,
      'cvv': cvv,
      'cardName': cardName,
      'bankProvider': bankProvider,
      'saldo': saldo,
      'cardType': cardType,
    };
  }

  static double _convertToDouble(dynamic value) {
    if (value is int) {
      return value.toDouble();
    } else if (value is double) {
      return value;
    } else {
      return 0.0;
    }
  }
}
