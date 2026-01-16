import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MaterialsScreen extends StatefulWidget {
  const MaterialsScreen({super.key});

  @override
  State<MaterialsScreen> createState() => _MaterialsScreenState();
}

class _MaterialsScreenState extends State<MaterialsScreen> {
  final _nameController = TextEditingController();
  final _quantityController = TextEditingController();
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser!;
    if (user == null) {
      return const Center(child: Text('Please login first'));
    }

    final materialsRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('materials');

    Query query = materialsRef.orderBy('createdAt', descending: true);

    if (_searchQuery.isNotEmpty) {
      query = query
          .where('name', isGreaterThanOrEqualTo: _searchQuery)
          .where('name', isLessThan: '$_searchQuery\uf8ff');
    }

    return Scaffold(
      // Floating Action Button (yellow/orange + button)
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.yellow[700],
        elevation: 6,
        child: const Icon(Icons.add, color: Colors.white, size: 30),
        onPressed: () {
          _showAddMaterialDialog(context, materialsRef);
        },
      ),

      body: Column(
        children: [
          // Blue header - exact match to your UI
          Container(
            width: double.infinity,
            color: Colors.blue,
            padding: const EdgeInsets.fromLTRB(16, 40, 16, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Material Inventory',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Icon(Icons.search, color: Colors.white),
              ],
            ),
          ),

          // Search input
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: (value) =>
                  setState(() => _searchQuery = value.trim().toLowerCase()),
              decoration: InputDecoration(
                hintText: 'Search',
                filled: true,
                fillColor: Colors.grey[100],
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),

          // Real-time materials list (appears below search input)
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: query.snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                      child: Text('Error: ${snapshot.error}',
                          style: const TextStyle(color: Colors.red)));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                      child: CircularProgressIndicator(color: Colors.blue));
                }

                final materials = snapshot.data?.docs ?? [];

                if (materials.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inventory_2, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'No materials yet\nAdd one using the + button!',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: materials.length,
                  itemBuilder: (context, index) {
                    final mat = materials[index].data() as Map<String, dynamic>;
                    final name = mat['name'] ?? 'Unknown';
                    final quantity = mat['quantity'] ?? '0 Available';

                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                        title: Text(name,
                            style:
                                const TextStyle(fontWeight: FontWeight.w600)),
                        trailing: Text(
                          quantity,
                          style: const TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Dialog to add new material
  void _showAddMaterialDialog(
      BuildContext context, CollectionReference materialsRef) {
    final _nameController = TextEditingController();
    final _quantityController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Add New Material',
            style: TextStyle(color: Colors.blue)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Material Name',
                  hintText: 'e.g., Cement Bags',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _quantityController,
                decoration: InputDecoration(
                  labelText: 'Quantity',
                  hintText: 'e.g., 120 Available',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                keyboardType: TextInputType.text,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () async {
              final name = _nameController.text.trim();
              final quantity = _quantityController.text.trim();

              if (name.isEmpty || quantity.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please fill all fields')),
                );
                return;
              }

              // Add to Firestore
              await materialsRef.add({
                'name': name,
                'quantity': quantity,
                'createdAt': FieldValue.serverTimestamp(),
              });

              // Close dialog
              Navigator.pop(context);

              // Show success message
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Material added successfully!'),
                  backgroundColor: Colors.green,
                  duration: const Duration(seconds: 2),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  margin:
                      const EdgeInsets.only(bottom: 80, right: 16, left: 16),
                ),
              );
            },
            child: const Text('Add Material',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
