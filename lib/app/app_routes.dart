import 'package:flutter/material.dart';

import '../data/models/attraction.dart';
import '../data/models/booking_draft.dart';
import '../data/models/catalog_item.dart';
import '../data/models/destination.dart';
import '../data/models/experience.dart';
import '../data/models/hotel.dart';
import '../features/attractions/attraction_sheet.dart';
import '../features/auth/login_screen.dart';
import '../features/auth/sign_up_screen.dart';
import '../features/checkout/checkout_screen.dart';
import '../features/destination/destination_details_screen.dart';
import '../features/experiences/experience_details_screen.dart';
import '../features/experiences/experiences_screen.dart';
import '../features/flights/flights_screen.dart';
import '../features/location/location_picker_sheet.dart';
import '../features/onboarding/welcome_screen.dart';
import '../features/profile/bookings_screen.dart';
import '../features/stays/hotel_details_screen.dart';
import '../features/stays/stays_screen.dart';
import 'app_shell.dart';

/// Navigation entry points.
///
/// Top-level destinations are named routes; detail screens are pushed through
/// the helpers below so they receive a typed model instead of a string. The
/// original registered `/flight_details` with `destinationName: ''` and
/// `imagePath: ''`, which rendered an empty screen and threw on the image.
abstract final class AppRoutes {
  static const String welcome = '/';
  static const String login = '/login';
  static const String signUp = '/sign-up';
  static const String home = '/home';

  static Map<String, WidgetBuilder> get namedRoutes => <String, WidgetBuilder>{
    welcome: (_) => const WelcomeScreen(),
    login: (_) => const LoginScreen(),
    signUp: (_) => const SignUpScreen(),
    home: (_) => const AppShell(),
  };

  static Route<T> _page<T>(Widget child) =>
      MaterialPageRoute<T>(builder: (_) => child);

  // --- Top-level ------------------------------------------------------------

  static void goHome(BuildContext context) => Navigator.of(
    context,
  ).pushNamedAndRemoveUntil(home, (Route<dynamic> route) => false);

  static void goLogin(BuildContext context) => Navigator.of(
    context,
  ).pushNamedAndRemoveUntil(login, (Route<dynamic> route) => false);

  // --- Details --------------------------------------------------------------

  static Future<void> openDestination(
    BuildContext context,
    Destination destination,
  ) => Navigator.of(
    context,
  ).push(_page<void>(DestinationDetailsScreen(destination: destination)));

  static Future<void> openHotel(BuildContext context, Hotel hotel) =>
      Navigator.of(context).push(_page<void>(HotelDetailsScreen(hotel: hotel)));

  static Future<void> openExperience(
    BuildContext context,
    Experience experience,
  ) => Navigator.of(
    context,
  ).push(_page<void>(ExperienceDetailsScreen(experience: experience)));

  static Future<void> showAttraction(
    BuildContext context,
    Attraction attraction,
  ) => showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (_) => AttractionSheet(attraction: attraction),
  );

  /// Opens whichever detail view matches [item]. Used by the saved list, which
  /// holds all four content types.
  static Future<void> openCatalogItem(BuildContext context, CatalogItem item) =>
      switch (item) {
        Destination() => openDestination(context, item),
        Hotel() => openHotel(context, item),
        Experience() => openExperience(context, item),
        Attraction() => showAttraction(context, item),
        _ => Future<void>.value(),
      };

  // --- Lists ----------------------------------------------------------------

  static Future<void> openStays(BuildContext context) =>
      Navigator.of(context).push(_page<void>(const StaysScreen()));

  static Future<void> openExperiences(BuildContext context) =>
      Navigator.of(context).push(_page<void>(const ExperiencesScreen()));

  static Future<void> openBookings(BuildContext context) =>
      Navigator.of(context).push(_page<void>(const BookingsScreen()));

  /// Today's departures from the user's city.
  static Future<void> openFlights(BuildContext context) =>
      Navigator.of(context).push(_page<void>(const FlightsScreen()));

  /// "Choose your location" — opened from the home app bar, never Explore.
  static Future<void> showLocationPicker(BuildContext context) =>
      showModalBottomSheet<void>(
        context: context,
        showDragHandle: true,
        isScrollControlled: true,
        builder: (_) => const LocationPickerSheet(),
      );

  // --- Checkout -------------------------------------------------------------

  static Future<void> openCheckout(BuildContext context, BookingDraft draft) =>
      Navigator.of(context).push(_page<void>(CheckoutScreen(draft: draft)));
}
