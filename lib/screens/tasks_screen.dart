import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  final _taskController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser!;
    if (user == null) {
      return const Center(child: Text('Please login first'));
    }

    final tasksRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('tasks');

    return Scaffold(
      // Floating Action Button (blue + button) is here!
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        elevation: 6,
        child: const Icon(Icons.add, color: Colors.white, size: 30),
        onPressed: () async {
          final title = _taskController.text.trim();
          if (title.isEmpty) return;

          // Add the task to Firestore
          await tasksRef.add({
            'title': title,
            'status': 'in progress', // Default status - you can change later
            'createdAt': FieldValue.serverTimestamp(),
          });

          // Clear the input field
          _taskController.clear();

          // Show success message (green SnackBar)
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Task added successfully!'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              margin: const EdgeInsets.only(
                bottom: 80, // Makes it appear above the bottom nav
                right: 16,
                left: 16,
              ),
            ),
          );
        },
      ),

      body: Column(
        children: [
          // Blue header (exact match to your UI)
          Container(
            width: double.infinity,
            color: Colors.blue,
            padding: const EdgeInsets.fromLTRB(16, 40, 16, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Task List',
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

          // Input field for new task
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _taskController,
              decoration: InputDecoration(
                hintText: 'Add new task...',
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),

          // Real-time task list (updates instantly when FAB is pressed)
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: tasksRef.orderBy('createdAt', descending: true).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.red)));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: Colors.blue));
                }

                final tasks = snapshot.data?.docs ?? [];

                if (tasks.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.list_alt, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'No tasks yet\nAdd your first task using the + button!',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    final task = tasks[index].data() as Map<String, dynamic>;
                    final title = task['title'] ?? 'Untitled';
                    final status = (task['status'] ?? 'pending').toString().toLowerCase();

                    Color statusColor = Colors.grey;
                    if (status.contains('progress')) statusColor = Colors.yellow[700]!;
                    if (status.contains('completed')) statusColor = Colors.green;

                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: statusColor,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            task['status'] ?? 'pending',
                            style: const TextStyle(color: Colors.white, fontSize: 12),
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
}