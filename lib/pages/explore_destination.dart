import 'package:flutter/material.dart';
import 'package:gotrek_app/pages/home.dart'; 
import 'package:gotrek_app/pages/favourites.dart'; 
import 'package:gotrek_app/pages/user_profile.dart'; 
import 'package:gotrek_app/pages/flight_details.dart'; 

class ExploreDestinationScreen extends StatefulWidget {
  const ExploreDestinationScreen({super.key});

  @override
  State<ExploreDestinationScreen> createState() => _ExploreDestinationScreenState();
}

class _ExploreDestinationScreenState extends State<ExploreDestinationScreen> {
  
  final List<Map<String, dynamic>> destinations = [
    {
      'name': 'Toronto, Canada',
      'distance': '12.4 km',
      'image': 'assets/images/toronto_canada.jpg',
      'arrivalDate': 'November 10, 2023 - Wednesday',
      'arrivalTime': '14:00',
      'departureTime': '19:00',
      'returnDate': 'November 13, 2023',
      'returnDepartureTime': '16:00',
      'price': '40',
    },
    {
      'name': 'New York, USA',
      'distance': '50 km',
      'image': 'assets/images/new_york_explore.jpg',
      'arrivalDate': 'December 1, 2023 - Friday',
      'arrivalTime': '10:00',
      'departureTime': '15:00',
      'returnDate': 'December 5, 2023',
      'returnDepartureTime': '12:00',
      'price': '60',
    },
    {
      'name': 'Russia',
      'distance': '2500 km',
      'image': 'assets/images/russia_explore.jpg', 
      'arrivalDate': 'January 15, 2024 - Monday',
      'arrivalTime': '09:00',
      'departureTime': '17:00',
      'returnDate': 'January 22, 2024',
      'returnDepartureTime': '14:00',
      'price': '120',
    },
    {
      'name': 'Paris, France',
      'distance': '3500 km',
      'image': 'assets/images/paris_explore.jpg', 
      'arrivalDate': 'February 10, 2024 - Saturday',
      'arrivalTime': '11:00',
      'departureTime': '18:00',
      'returnDate': 'February 17, 2024',
      'returnDepartureTime': '15:00',
      'price': '80',
    },
    {
      'name': 'Tokyo, Japan',
      'distance': '8000 km',
      'image': 'assets/images/tokyo_explore.jpg', 
      'arrivalDate': 'March 1, 2024 - Friday',
      'arrivalTime': '08:00',
      'departureTime': '20:00',
      'returnDate': 'March 8, 2024',
      'returnDepartureTime': '10:00',
      'price': '150',
    },
  ];

  
  List<Map<String, dynamic>> _filteredDestinations = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filteredDestinations = destinations; 
    _searchController.addListener(_filterDestinations);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterDestinations() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      _filteredDestinations = destinations.where((destination) {
        return destination['name']!.toLowerCase().contains(query);
      }).toList();
    });
  }

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
        title: const Text(
          'Explore',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.menu, color: Colors.black),
            onPressed: () {
            
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
              child: LinearProgressIndicator(
                value: 0.7, 
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade700),
                minHeight: 5,
                borderRadius: BorderRadius.circular(5),
              ),
            ),
            const SizedBox(height: 20),

            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.grey[200], 
                  borderRadius: BorderRadius.circular(15),
                ),
                child: TextField(
                  controller: _searchController, 
                  decoration: const InputDecoration(
                    hintText: 'Search places...',
                    hintStyle: TextStyle(color: Colors.grey),
                    prefixIcon: Icon(Icons.search, color: Colors.grey),
                    border: InputBorder.none,
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 15, horizontal: 0),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            if (_filteredDestinations.isNotEmpty)
              _buildExploreCard(
                _filteredDestinations[0],
              ),
            if (_filteredDestinations.isEmpty)
              const Padding(
                padding: EdgeInsets.all(20.0),
                child: Center(
                  child: Text(
                    'No destinations found matching your search.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ),
              ),

            const SizedBox(height: 30),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Text(
                'Nearby Locations',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            const SizedBox(height: 15),

            
            ..._filteredDestinations.skip(1).map((destination) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                child: _buildSmallDestinationCard(
                  destination,
                ),
              );
            }).toList(),

            if (_filteredDestinations.length <= 1 && _filteredDestinations.isNotEmpty)
              const Padding(
                padding: EdgeInsets.all(20.0),
                child: Center(
                  child: Text(
                    'No other nearby locations found or displayed based on your search.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ),
              ),

            const SizedBox(height: 20),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2,
        onTap: (index) {
          
          if (index == 0) { // Home
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomeScreen()),
            );
          } else if (index == 1) { // Favorites
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const FavouritesScreen()),
            );
          } else if (index == 2) { 
            
          } else if (index == 3) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const UserProfileScreen()),
            );
          }
        },
        selectedItemColor: Colors.blue.shade800, 
        unselectedItemColor: Colors.grey, 
        type: BottomNavigationBarType.fixed, 
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_border),
            label: 'Favorites',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.location_on_outlined), 
            label: 'Explore',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  
  Widget _buildExploreCard(Map<String, dynamic> destination) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Container(
        height: 300, 
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 5,
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
          image: DecorationImage(
            image: AssetImage(destination['image']!),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            
            Positioned.fill(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  height: 100,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withOpacity(0.7),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ),
            
            Positioned(
              bottom: 20,
              left: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    destination['name']!,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    destination['distance']!,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FlightDetailScreen(
                            destinationName: destination['name']!,
                            imagePath: destination['image']!,
                            arrivalDate: destination['arrivalDate']!,
                            arrivalTime: destination['arrivalTime']!,
                            departureTime: destination['departureTime']!,
                            returnDate: destination['returnDate']!,
                            returnDepartureTime: destination['returnDepartureTime']!,
                            price: destination['price']!,
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade700,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      elevation: 0,
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.near_me, color: Colors.white, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Start',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  
  Widget _buildSmallDestinationCard(Map<String, dynamic> destination) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
        
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(
              destination['image']!,
              width: 70,
              height: 70,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 15),
          // تفاصيل الاسم والمسافة
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  destination['name']!,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  destination['distance']!,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.arrow_forward_ios, color: Colors.blue.shade700, size: 20),
            onPressed: () {

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FlightDetailScreen(
                    destinationName: destination['name']!,
                    imagePath: destination['image']!,
                    arrivalDate: destination['arrivalDate']!,
                    arrivalTime: destination['arrivalTime']!,
                    departureTime: destination['departureTime']!,
                    returnDate: destination['returnDate']!,
                    returnDepartureTime: destination['returnDepartureTime']!,
                    price: destination['price']!,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}