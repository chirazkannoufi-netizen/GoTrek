import 'package:flutter/material.dart';

enum BookingKind {
  stay('Stay', Icons.hotel_outlined),
  trip('Trip', Icons.flight_takeoff_outlined),
  experience('Experience', Icons.hiking_outlined);

  const BookingKind(this.label, this.icon);

  final String label;
  final IconData icon;
}

enum BookingStatus {
  confirmed('Confirmed'),
  completed('Completed'),
  cancelled('Cancelled');

  const BookingStatus(this.label);

  final String label;
}

/// A confirmed booking. Persisted locally so it survives a restart.
class Booking {
  const Booking({
    required this.id,
    required this.reference,
    required this.kind,
    required this.title,
    required this.subtitle,
    required this.imageAsset,
    required this.startDate,
    required this.endDate,
    required this.guests,
    required this.total,
    required this.status,
    required this.createdAt,
    required this.paymentLabel,
  });

  final String id;
  final String reference;
  final BookingKind kind;
  final String title;
  final String subtitle;
  final String imageAsset;
  final DateTime startDate;
  final DateTime endDate;
  final int guests;
  final double total;
  final BookingStatus status;
  final DateTime createdAt;
  final String paymentLabel;

  int get nights => endDate.difference(startDate).inDays;

  Booking copyWith({BookingStatus? status}) => Booking(
    id: id,
    reference: reference,
    kind: kind,
    title: title,
    subtitle: subtitle,
    imageAsset: imageAsset,
    startDate: startDate,
    endDate: endDate,
    guests: guests,
    total: total,
    status: status ?? this.status,
    createdAt: createdAt,
    paymentLabel: paymentLabel,
  );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'reference': reference,
    'kind': kind.name,
    'title': title,
    'subtitle': subtitle,
    'imageAsset': imageAsset,
    'startDate': startDate.toIso8601String(),
    'endDate': endDate.toIso8601String(),
    'guests': guests,
    'total': total,
    'status': status.name,
    'createdAt': createdAt.toIso8601String(),
    'paymentLabel': paymentLabel,
  };

  static Booking fromJson(Map<String, dynamic> json) => Booking(
    id: json['id'] as String,
    reference: json['reference'] as String,
    kind: _enumByName(BookingKind.values, json['kind'], BookingKind.stay),
    title: json['title'] as String,
    subtitle: json['subtitle'] as String,
    imageAsset: json['imageAsset'] as String,
    startDate: DateTime.parse(json['startDate'] as String),
    endDate: DateTime.parse(json['endDate'] as String),
    guests: json['guests'] as int,
    total: (json['total'] as num).toDouble(),
    status: _enumByName(
      BookingStatus.values,
      json['status'],
      BookingStatus.confirmed,
    ),
    createdAt: DateTime.parse(json['createdAt'] as String),
    paymentLabel: json['paymentLabel'] as String,
  );
}

T _enumByName<T extends Enum>(List<T> values, Object? name, T fallback) {
  for (final T value in values) {
    if (value.name == name) return value;
  }
  return fallback;
}
