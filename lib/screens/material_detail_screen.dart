import 'package:flutter/material.dart';

class MaterialDetailScreen extends StatelessWidget {
  final Map<String, dynamic> material;

  const MaterialDetailScreen({super.key, required this.material});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(material['name'] ?? 'Material Detail')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Name: ${material['name'] ?? 'Unknown'}'),
            Text('Quantity: ${material['quantity'] ?? '0'}'),
            Text('Supplier: ${material['supplier'] ?? 'Unknown'}'),
            Text('Arrival: ${material['arrivalDate'] ?? 'Unknown'}'),
          ],
        ),
      ),
    );
  }
}