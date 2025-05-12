import 'package:flutter/material.dart';

class Errorscreen extends StatelessWidget {
   final String? errorMessage;

  const Errorscreen({Key? key, this.errorMessage}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text("Error Occured: $errorMessage")),);
  }
}