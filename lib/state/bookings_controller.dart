import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/booking.dart';
import '../data/models/booking_draft.dart';
import '../data/repositories/booking_repository.dart';
import 'repository_providers.dart';

/// Bookings the user has confirmed, newest first.
class BookingsController extends AsyncNotifier<List<Booking>> {
  @override
  Future<List<Booking>> build() => ref.read(bookingRepositoryProvider).load();

  /// Turns a checkout draft into a stored booking and returns it so the
  /// confirmation screen can show the reference.
  Future<Booking> confirm({
    required BookingDraft draft,
    required String paymentLabel,
  }) async {
    final BookingRepository repository = ref.read(bookingRepositoryProvider);
    final Booking booking = Booking(
      id: repository.newId(),
      reference: repository.newReference(),
      kind: draft.kind,
      title: draft.title,
      subtitle: draft.subtitle,
      imageAsset: draft.imageAsset,
      startDate: draft.startDate,
      endDate: draft.endDate,
      guests: draft.guests,
      total: draft.total,
      status: BookingStatus.confirmed,
      createdAt: DateTime.now(),
      paymentLabel: paymentLabel,
    );

    final List<Booking> updated = <Booking>[booking, ...?state.value];
    state = AsyncValue<List<Booking>>.data(updated);
    await repository.save(updated);
    return booking;
  }

  Future<void> cancel(String bookingId) async {
    final List<Booking> updated = <Booking>[
      for (final Booking booking in state.value ?? const <Booking>[])
        booking.id == bookingId
            ? booking.copyWith(status: BookingStatus.cancelled)
            : booking,
    ];
    state = AsyncValue<List<Booking>>.data(updated);
    await ref.read(bookingRepositoryProvider).save(updated);
  }
}

final AsyncNotifierProvider<BookingsController, List<Booking>>
bookingsControllerProvider =
    AsyncNotifierProvider<BookingsController, List<Booking>>(
      BookingsController.new,
    );

final Provider<int> upcomingBookingsCountProvider = Provider<int>((Ref ref) {
  final List<Booking> bookings =
      ref.watch(bookingsControllerProvider).value ?? const <Booking>[];
  final DateTime now = DateTime.now();
  return bookings
      .where(
        (Booking booking) =>
            booking.status == BookingStatus.confirmed &&
            booking.startDate.isAfter(now),
      )
      .length;
});
