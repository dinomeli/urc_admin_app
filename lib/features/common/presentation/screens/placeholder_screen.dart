import 'package:flutter/material.dart';
import '../../widgets/custom_drawer.dart'; // import کن

class PlaceholderScreen extends StatelessWidget {
  final String title;

  const PlaceholderScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      drawer: const CustomDrawer(), // ← اضافه شد
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('صفحه $title', style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 20),
            const Text('در حال توسعه است...', style: TextStyle(fontSize: 18, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}