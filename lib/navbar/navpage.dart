import 'package:flutter/material.dart';

import 'package:punching_machine/Homepage/punchInpage.dart';
import 'package:punching_machine/ReportPage/reportPage.dart';



class Navbar extends StatefulWidget {
  const Navbar({super.key});

  @override
  State<Navbar> createState() => _NavbarState();
}

class _NavbarState extends State<Navbar> {
  List items = [const PunchInPage(), const ReportPage()];

  int currentIndex = 0;

  navigatePage(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  getData() {
    
    setState(() {});
  }

  @override
  void initState() {
    getData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
          onTap: (index) {
            navigatePage(index);
          },
          currentIndex: currentIndex,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
            BottomNavigationBarItem(
                icon: Icon(Icons.calendar_month), label: "Report")
          ]),
      body: items[currentIndex],
    );
  }
}
