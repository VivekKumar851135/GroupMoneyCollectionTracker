import 'package:flutter/material.dart';

class Customwidget {

Widget buildHomeButton() {
  
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 12),
    child: Container(
      height: 60,
      decoration: BoxDecoration(
        color: const Color(0xFF5865F2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Center(
        child: Icon(
          Icons.discord,
          color: Colors.white,
          size: 28,
        ),
      ),
    ),
  );
}
  
}

 Widget buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Container(
        height: 2,
        color: const Color(0xFF2D2F32),
      ),
    );
  }