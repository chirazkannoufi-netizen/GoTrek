import 'booking.dart';

/// What the user is about to pay for.
///
/// Built by the stay / trip / experience screens and handed to checkout, so
/// the payment screen always knows the real total instead of receiving an
/// empty string.
class BookingDraft {
  const BookingDraft({
    required this.kind,
    required this.title,
    required this.subtitle,
    required this.imageAsset,
    required this.startDate,
    required this.endDate,
    required this.guests,
    required this.lineItems,
  });

  final BookingKind kind;
  final String title;
  final String subtitle;
  final String imageAsset;
  final DateTime startDate;
  final DateTime endDate;
  final int guests;
  final List<BookingLineItem> lineItems;

  double get subtotal => lineItems.fold(
    0,
    (double sum, BookingLineItem item) => sum + item.amount,
  );

  /// Flat service fee, shown as its own line at checkout.
  double get serviceFee => (subtotal * 0.08).roundToDouble();

  double get total => subtotal + serviceFee;

  int get nights => endDate.difference(startDate).inDays;
}

class BookingLineItem {
  const BookingLineItem({required this.label, required this.amount});

  final String label;
  final double amount;
}
