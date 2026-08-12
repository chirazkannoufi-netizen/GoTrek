import 'package:flutter/material.dart';
import 'package:gotrek_app/pages/payment_method.dart';

class FlightDetailScreen extends StatelessWidget {
  final String destinationName;
  final String imagePath;
  final String arrivalDate;
  final String arrivalTime;
  final String departureTime;
  final String returnDate;
  final String returnDepartureTime;
  final String price;

  const FlightDetailScreen({
    super.key,
    required this.destinationName,
    required this.imagePath,
    this.arrivalDate = 'November 10, 2023 - Wednesday',
    this.arrivalTime = '14:00',
    this.departureTime = '19:00',
    this.returnDate = 'November 13, 2023',
    this.returnDepartureTime = '16:00',
    this.price = '40',
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.asset(
                      imagePath,
                      height: 250,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    bottom: 20,
                    left: 20,
                    child: Text(
                      destinationName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 25),
              _buildDetailRow(
                'Arriving Date To US, California',
                '\$$price',
                mainText: arrivalDate,
                mainTextColor: Colors.black,
              ),
              const SizedBox(height: 20),
              _buildDetailRow('Time', '',
                  mainText: arrivalTime, mainTextColor: Colors.black),
              const SizedBox(height: 25),
              _buildFlightSection(
                title: 'Flight on: $arrivalDate',
                departureTime: '14:00',
                departureLocation: 'California',
                arrivalTime: '19:00',
                arrivalLocation: destinationName,
              ),
              const SizedBox(height: 25),
              _buildFlightSection(
                title: 'Return Flight on: $returnDate',
                departureTime: '14:00',
                departureLocation: destinationName,
                arrivalTime: '10:00',
                arrivalLocation: 'California',
              ),
              const SizedBox(height: 40),
              Center(
                child: SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const PaymentMethodScreen(totalPrice: '',)),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade700,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Book Now',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value,
      {String? mainText, Color? mainTextColor}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade700,
              ),
            ),
          ],
        ),
        if (mainText != null && mainText.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 5.0),
            child: Text(
              mainText,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: mainTextColor ?? Colors.black,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildFlightSection({
    required String title,
    required String departureTime,
    required String departureLocation,
    required String arrivalTime,
    required String arrivalLocation,
  }) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    departureTime,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    departureLocation,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              Column(
                children: [
                  Icon(Icons.flight, color: Colors.blue.shade700, size: 30),
                  Container(
                    width: 80,
                    height: 1,
                    color: Colors.grey[300],
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    arrivalTime,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    arrivalLocation,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}