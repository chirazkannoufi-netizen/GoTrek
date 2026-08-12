import 'package:flutter/material.dart';
import 'package:gotrek_app/pages/welcome.dart';
import 'package:gotrek_app/pages/login.dart';
import 'package:gotrek_app/pages/signup.dart';
import 'package:gotrek_app/pages/sms_verification.dart';
import 'package:gotrek_app/pages/home.dart';
import 'package:gotrek_app/pages/explore_destination.dart';
import 'package:gotrek_app/pages/flight_details.dart';
import 'package:gotrek_app/pages/hotel_details.dart';
import 'package:gotrek_app/pages/hotel_listing.dart';
import 'package:gotrek_app/pages/payment_method.dart';
import 'package:gotrek_app/pages/payment_success.dart';
import 'package:gotrek_app/pages/favourites.dart';
import 'package:gotrek_app/pages/user_profile.dart';
// ignore: unused_import
import 'package:gotrek_app/pages/welcom_success.dart';

void main() {
  runApp(const GoTrekApp());
}

class GoTrekApp extends StatelessWidget {
  const GoTrekApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Go Trek App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const Welcome(),
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignUpScreen(),
        '/sms_verification':
            (context) => const SMSVerificationScreen(phoneNumber: '0655286003'),
        '/home': (context) => const HomeScreen(),
        '/explore_destination': (context) => const ExploreDestinationScreen(),
        '/flight_details':
            (context) =>
                const FlightDetailScreen(destinationName: '', imagePath: ''),
        '/hotel_listing': (context) => const HotelListingScreen(),
        '/payment_method':
            (context) => const PaymentMethodScreen(totalPrice: ''),
        '/payment_success': (context) => const PaymentSuccessScreen(),
        '/favourites': (context) => const FavouritesScreen(),
        '/user_profile': (context) => const UserProfileScreen(),
      },
    );
  }
}
