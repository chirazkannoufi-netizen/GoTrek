import 'package:flutter/material.dart';

enum CardBrand {
  visa('Visa', Icons.credit_card),
  mastercard('Mastercard', Icons.credit_card);

  const CardBrand(this.label, this.icon);

  final String label;
  final IconData icon;
}

/// A saved payment method. Only the last four digits are ever held — the app
/// never captures or stores a full card number.
class PaymentCard {
  const PaymentCard({
    required this.id,
    required this.brand,
    required this.last4,
    required this.holderName,
    required this.expiryMonth,
    required this.expiryYear,
  });

  final String id;
  final CardBrand brand;
  final String last4;
  final String holderName;
  final int expiryMonth;
  final int expiryYear;

  String get label => '${brand.label} •••• $last4';

  String get expiryLabel =>
      '${expiryMonth.toString().padLeft(2, '0')}/${expiryYear % 100}';
}
