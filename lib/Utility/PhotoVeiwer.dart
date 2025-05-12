import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class FullScreenImageViewer extends StatelessWidget {
  final String imageUrl;

  FullScreenImageViewer({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: Center(
        child: Image.network(
          imageUrl,
          errorBuilder: (context, error, stackTrace) {
            // Fallback for invalid URL in full-screen view
            return Icon(
              Icons.broken_image,
              color: Colors.grey[700],
              size: 100,
            );
          },
        ),
      ),
    );
  }
}