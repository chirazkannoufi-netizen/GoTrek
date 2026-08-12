import 'package:flutter/material.dart';

/// Hotel facilities. Modelled as an enum so the icon and label stay in sync
/// wherever a facility is rendered.
enum Amenity {
  wifi('Free Wi-Fi', Icons.wifi),
  pool('Pool', Icons.pool_outlined),
  breakfast('Breakfast', Icons.free_breakfast_outlined),
  gym('Fitness centre', Icons.fitness_center_outlined),
  spa('Spa', Icons.spa_outlined),
  restaurant('Restaurant', Icons.restaurant_outlined),
  bar('Bar', Icons.local_bar_outlined),
  roomService('Room service', Icons.room_service_outlined),
  concierge('Concierge', Icons.support_agent_outlined),
  parking('Parking', Icons.local_parking_outlined),
  airConditioning('Air conditioning', Icons.ac_unit_outlined),
  petFriendly('Pet friendly', Icons.pets_outlined);

  const Amenity(this.label, this.icon);

  final String label;
  final IconData icon;
}
