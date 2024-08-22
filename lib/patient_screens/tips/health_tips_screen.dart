import 'dart:math';
import 'package:abtms/controllers/controllers.dart';
import 'package:abtms/patient_screens/tips/health_tips_details.dart';
import 'package:flutter/material.dart';

class HealthTipsPage extends StatelessWidget {
  final List<String> categories = [
    'Diet Best Practices',
    'Sleeping',
    'Exercises',
    'Hydration',
    'Fruits and Vegetables'
  ];

  final Map<String, List<String>> categoryImages = {
    'Diet Best Practices': [
      'assets/images/health_tips/diet/06a1f8e1c6d33fc7616c91a152b06629.jpg',
      'assets/images/health_tips/diet/Christmas-food-photographer-Robin-Goodlad9-1.jpg',
      'assets/images/health_tips/diet/unnamed.jpg'
    ],
    'Sleeping': [
      'assets/images/health_tips/sleep/700-00519551en_Masterfile.jpg',
      'assets/images/health_tips/sleep/depositphotos_420010652-stock-photo-african-american-guy-sleeping-lying.jpg',
      'assets/images/health_tips/sleep/Free Photo _ The young man lying in a bed.jpeg'
    ],
    'Exercises': [
      'assets/images/health_tips/exercise/exercise 1.jpg',
      'assets/images/health_tips/exercise/exercise 2.jpg',
      'assets/images/health_tips/exercise/exercise 3.jpg'
    ],
    'Hydration': [
      'assets/images/health_tips/hydration/Best side effect_ glowing skin.jpeg',
      'assets/images/health_tips/hydration/How To Stay Hydrated All Day — The College Nutritionist.jpeg',
      'assets/images/health_tips/hydration/Untitled-design-3-1.png'
    ],
    'Fruits and Vegetables': [
      'assets/images/health_tips/fruits_and_vegetables/A Complete Guide to Citrus Fruits.jpeg',
      'assets/images/health_tips/fruits_and_vegetables/Fruit Christmas Tree - Iowa Girl Eats.jpeg',
      'assets/images/health_tips/fruits_and_vegetables/How To Plan A Vegetable Garden In 7 Easy Steps.jpeg'
    ],
  };

  final random = Random();

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: const MyAppBar(title: 'Health Tips'),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16.0),
                height: 100,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF3E4D99),
                      Color.fromARGB(255, 23, 29, 58),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Health Tips',
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w500,
                          color: Colors.white),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Tap a card to view health tip',
                      style: TextStyle(fontSize: 15, color: Colors.white),
                    ),
                  ],
                ),
              ),
              Container(
                child: Column(
                  children: [
                    const SizedBox(
                      height: 20,
                    ),
                    Row(
                      children: [
                        const SizedBox(width: 5),
                        Text(
                          'Scroll horizontally to see more cards',
                          style:
                              TextStyle(fontSize: 14, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                    // SizedBox(
                    //   height: 7,
                    // ),
                    // Row(
                    //   children: [
                    //     SizedBox(width: 5),
                    //     Text(
                    //       'Tap a card to view health tip',
                    //       style:
                    //           TextStyle(fontSize: 14, color: Colors.grey[600]),
                    //     ),
                    //   ],
                    // ),
                    const SizedBox(
                      height: 7,
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: screenHeight * 0.55,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    final images = categoryImages[category]!;
                    final image = images[random.nextInt(images.length)];
                    return HealthTipCard(category: category, image: image);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

@override
class HealthTipCard extends StatelessWidget {
  final String category;
  final String image;

  const HealthTipCard({super.key, required this.category, required this.image});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => HealthTipDetailPage(
              category: category,
              image: image,
            ),
          ),
        );
      },
      child: Container(
        width: 270,
        margin: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          image: DecorationImage(
            image: AssetImage(image),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 300, //* (1 / 2), // 1/3rd of the container height
                width: 300,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.transparent, Colors.black.withOpacity(1)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(10),
                    bottomRight: Radius.circular(10),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(30),
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(10),
                    bottomRight: Radius.circular(10),
                  ),
                ),
                child: Text(
                  category,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
