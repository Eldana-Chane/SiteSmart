import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser!;
    final projectDoc = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('projects')
        .doc('main');

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Welcome!',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          StreamBuilder<DocumentSnapshot>(
            stream: projectDoc.snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              final data = snapshot.data?.data() as Map<String, dynamic>?;
              final projectName = data?['name'] ?? 'Aloz Plaza';
              final progress = (data?['progress'] as num?)?.toDouble() ?? 75.0;

              return Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Project: $projectName',
                          style: const TextStyle(fontSize: 20)),
                      const SizedBox(height: 12),
                      Text('Progress: ${progress.toInt()}%',
                          style: const TextStyle(fontSize: 18)),
                      const SizedBox(height: 12),
                      LinearProgressIndicator(
                        value: progress / 100,
                        minHeight: 12,
                        backgroundColor: Colors.grey[300],
                        color: Colors.blue,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
