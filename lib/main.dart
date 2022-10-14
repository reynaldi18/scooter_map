import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'blank.dart';
import 'home.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  int _page = 0;
  final GlobalKey<CurvedNavigationBarState> _bottomNavigationKey = GlobalKey();
  Widget? _child;

  @override
  void initState() {
    _child = const Home();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: _child,
      bottomNavigationBar: CurvedNavigationBar(
        key: _bottomNavigationKey,
        index: 0,
        items: [
          SvgPicture.asset(
            'assets/icons/ic_scooter.svg',
            width: 30,
            color: _page == 0 ? Colors.white : Colors.black,
          ),
          SvgPicture.asset(
            'assets/icons/ic_bicycle.svg',
            width: 30,
            color: _page == 1 ? Colors.white : Colors.black,
          ),
          SvgPicture.asset(
            'assets/icons/ic_qrcode.svg',
            width: 30,
            color: _page == 2 ? Colors.white : Colors.black,
          ),
          SvgPicture.asset(
            'assets/icons/ic_user.svg',
            width: 30,
            color: _page == 3 ? Colors.white : Colors.black,
          ),
        ],
        color: Colors.white,
        buttonBackgroundColor: const Color(0xff76A1A1),
        backgroundColor: Colors.transparent,
        animationCurve: Curves.easeInOut,
        animationDuration: const Duration(milliseconds: 600),
        onTap: (index) {
          setState(() {
            _page = index;
            _handleNavigationChange(_page);
          });
        },
        letIndexChange: (index) => true,
      ),
    );
  }

  void _handleNavigationChange(int index) {
    setState(
      () {
        switch (index) {
          case 0:
            _child = const Home();
            break;
          case 1:
            _child = const Blank();
            break;
          case 2:
            _child = const Blank();
            break;
          case 3:
            _child = const Blank();
            break;
        }
      },
    );
  }
}
