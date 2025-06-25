import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import '/screens/pet_screen.dart';
import 'package:petcare/screens/cam_screen.dart';
import '/screens/article_list_screen.dart';
import '/screens/food_store_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    PetScreen(),
    FoodStoreScreen(),
    ArticleListScreen(),
    CameraScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: CurvedNavigationBar(
        backgroundColor: const Color(0xFFF2F8FD),
        color: Color(0xFF2686C2),
        animationDuration: Duration(milliseconds: 300),
        items: <Widget>[
          Icon(Icons.pets, size: 30, color: Colors.white),
          Icon(Icons.shopping_cart, size: 30, color: Colors.white),
          Icon(Icons.article, size: 30, color: Colors.white),
          Icon(Icons.person, size: 30, color: Colors.white),
        ],
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}
