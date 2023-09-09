import 'package:flutter/material.dart';
import 'package:untitled/ui/menu/income.dart';

import 'menu/home.dart';
import 'menu/profile.dart';

class LayoutNavigationBar extends StatefulWidget {
  String accesstoken;

  LayoutNavigationBar({super.key, required this.accesstoken});

  @override
  _LayoutNavigationBarState createState() => _LayoutNavigationBarState();
}

class _LayoutNavigationBarState extends State<LayoutNavigationBar> {
  int _currentIndex = 0;

  late final List<Widget> _children;

  @override
  void initState() {
    super.initState();

    _children = [
      Home(
        accesstoken: widget.accesstoken,
      ),
      const Income(),
       Profile(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _children[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: onBarTapped,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(
              icon: Icon(Icons.trending_up), label: 'Pendapatan'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }

  void onBarTapped(int value) {
    setState(() {
      _currentIndex = value;
    });
  }
}
