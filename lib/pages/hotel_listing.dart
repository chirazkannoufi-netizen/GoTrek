import 'package:flutter/material.dart';
import 'package:gotrek_app/pages/hotel_details.dart';

class HotelListingScreen extends StatefulWidget {
  const HotelListingScreen({super.key});

  @override
  State<HotelListingScreen> createState() => _HotelListingScreenState();
}

class _HotelListingScreenState extends State<HotelListingScreen> {
  String _selectedService = 'Hotel';

  final List<Map<String, dynamic>> hotels = [
    {
      'name': 'The Plaza Hotel',
      'location': 'Manhattan, New York',
      'rating': 4.9,
      'reviews': 1200,
      'price': 250,
      'image': 'assets/images/the_plaza_hotel.jpg',
      'description':
          'The Plaza Hotel is a landmark luxury hotel and condominium apartment building in Midtown Manhattan in New York City. It was built in 1907. It is at the western side of Grand Army Plaza, just across from Central Park, and at the southeastern corner of Central Park South and Fifth Avenue. It is one of the most famous hotels in the world, known for its elegant design and rich history.',
      'facilities': ['Free Wi-Fi', 'Pool', 'Breakfast', 'Gym', 'Spa', 'Restaurant', 'Concierge Service']
    },
    {
      'name': 'The Ritz-Carlton New York, Central Park',
      'location': 'Manhattan, New York',
      'rating': 4.8,
      'reviews': 950,
      'price': 300,
      'image': 'assets/images/ritz_carlton_central_park.jpg',
      'description':
          'Overlooking Central Park, this upscale hotel with an ornate facade is a 3-minute walk from a subway station and 5 minutes on foot from Carnegie Hall. Elegant rooms feature Italian marble bathrooms, flat-screen TVs, and Wi-Fi access. Guests can enjoy stunning park views and exceptional service.',
      'facilities': ['Free Wi-Fi', 'Gym', 'Restaurant', 'Concierge Service', 'Room Service', 'Bar']
    },
    {
      'name': 'Baccarat Hotel New York',
      'location': 'Manhattan, New York',
      'rating': 4.9,
      'reviews': 780,
      'price': 350,
      'image': 'assets/images/baccarat_hotel.jpg',
      'description':
          'Set across the street from the Museum of Modern Art, this upscale hotel is an 8-minute walk from Central Park and a 10-minute walk from Grand Central Terminal. Posh rooms feature floor-to-ceiling windows, custom-made furnishings, and Baccarat crystal accents. It offers a unique blend of luxury and art.',
      'facilities': ['Free Wi-Fi', 'Indoor Pool', 'Bar', 'Room Service', 'Spa', 'Fitness Center']
    },
    {
      'name': 'The Peninsula New York',
      'location': 'Manhattan, New York',
      'rating': 4.7,
      'reviews': 1100,
      'price': 280,
      'image': 'assets/images/the_peninsula_hotel.jpg',
      'description':
          'This grand Midtown hotel is a 3-minute walk from 5th Avenue-53rd Street subway station and a 9-minute walk from Central Park. Refined rooms feature marble bathrooms, flat-screen TVs, minibars, and complimentary Wi-Fi. Known for its impeccable service and rooftop pool.',
      'facilities': ['Free Wi-Fi', 'Spa', 'Rooftop Pool', 'Fitness Center', 'Restaurant', 'Bar']
    },
    {
      'name': 'The Carlyle, A Rosewood Hotel',
      'location': 'Manhattan, New York',
      'rating': 4.8,
      'reviews': 850,
      'price': 320,
      'image': 'assets/images/the_carlyle_hotel.jpg',
      'description':
          'Overlooking Central Park, this iconic, upscale hotel on the Upper East Side is a 3-minute walk from the 77th Street subway station and a 12-minute walk from the Metropolitan Museum of Art. Elegant rooms feature custom-made furnishings, flat-screen TVs, and minibars. It embodies classic New York glamour and discretion.',
      'facilities': ['Free Wi-Fi', 'Fitness Center', 'Bar', 'Room Service', 'Spa', 'Live Music']
    },
  ];

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
          'Services',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.black),
            onPressed: () {
              // TODO: Add more options logic here
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(130.0),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildServiceTab('Hotel', Icons.hotel),
                    _buildServiceTab('Flight', Icons.flight),
                    _buildServiceTab('Bus', Icons.directions_bus),
                    _buildServiceTab('Boat', Icons.directions_boat),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const TextField(
                    decoration: InputDecoration(
                      hintText: 'Search any hotels...',
                      hintStyle: TextStyle(color: Colors.grey),
                      prefixIcon: Icon(Icons.search, color: Colors.grey),
                      border: InputBorder.none,
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 15, horizontal: 0),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.sort, color: Colors.black54),
                    const SizedBox(width: 5),
                    Text(
                      'Sort By',
                      style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 16,
                          fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                Text(
                  'Price (Low to High)',
                  style: TextStyle(
                      color: Colors.blue.shade700,
                      fontSize: 16,
                      fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              itemCount: hotels.length,
              itemBuilder: (context, index) {
                final hotel = hotels[index];
                return _buildHotelCard(
                  hotel['name']!,
                  hotel['location']!,
                  hotel['rating']!,
                  hotel['price']!,
                  hotel['image']!,
                  hotel['reviews']!,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceTab(String serviceName, IconData icon) {
    bool isSelected = _selectedService == serviceName;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedService = serviceName;
        });
        if (serviceName == 'Flight') {
          // Navigator.push(context, MaterialPageRoute(builder: (context) => FlightListingScreen()));
        }
      },
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? Colors.blue.shade700 : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(icon, color: isSelected ? Colors.white : Colors.black54),
                if (!isSelected) const SizedBox(width: 5),
                if (!isSelected)
                  Text(
                    serviceName,
                    style: const TextStyle(
                      color: Colors.black54,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHotelCard(
      String name, String location, double rating, int price, String imagePath, int reviews) {
    final hotelData = hotels.firstWhere((h) => h['name'] == name);

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Image.asset(
              imagePath,
              width: 120,
              height: 120,
              fit: BoxFit.cover,
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    location,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.star, color: Colors.amber, size: 18),
                      const SizedBox(width: 4),
                      Text(
                        '$rating (${reviews} Reviews)',
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '\$${price}/Room/Night',
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade700),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => HotelDetailsScreen(
                                hotelName: hotelData['name']!,
                                hotelImage: hotelData['image']!,
                                price: hotelData['price']!,
                                location: hotelData['location']!,
                                rating: hotelData['rating']!,
                                numberOfReviews: hotelData['reviews']!,
                                description: hotelData['description']!,
                                hotel: hotelData,
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade700,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 0,
                          minimumSize: Size.zero,
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), // Smaller padding for smaller text
                        ),
                        child: const Text(
                          'Book Now',
                          style: TextStyle(fontSize: 12, color: Colors.white), // Smaller font size
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}