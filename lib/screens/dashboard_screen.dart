import 'package:flutter/material.dart';
import '../constants.dart';
import 'task_screen.dart';
import 'material_screen.dart';
import 'report_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlue,
        title: const Text('SiteSmart'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Welcome!', style: TextStyle(fontSize: 22)),
            const SizedBox(height: 15),

            _infoCard('Project', 'Alfoz Plaza'),
            _infoCard('Progress', '75%'),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: AppColors.primaryBlue,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.task_alt), label: 'Tasks'),
          BottomNavigationBarItem(icon: Icon(Icons.inventory_2), label: 'Materials'),
          BottomNavigationBarItem(icon: Icon(Icons.report_problem), label: 'Reports'),
        ],
        onTap: (index) {
          if (index == 0) Navigator.push(context, MaterialPageRoute(builder: (_) => const TaskScreen()));
          if (index == 1) Navigator.push(context, MaterialPageRoute(builder: (_) => const MaterialScreen()));
          if (index == 2) Navigator.push(context, MaterialPageRoute(builder: (_) => const ReportScreen()));
        },
      ),
    );
  }

  Widget _infoCard(String title, String value) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.lightBlue,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 6),
          Text(value, style: const TextStyle(fontSize: 18)),
        ],
      ),
    );
  }
}
