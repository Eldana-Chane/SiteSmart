import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  String _issueType = 'Safety Hazard';
  final _descriptionController = TextEditingController();
  File? _photo;
  bool _isLoading = false;

  final List<String> _issueTypes = ['Safety Hazard', 'Quality Issue', 'Delay', 'Other'];

  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.camera);
    if (picked != null) setState(() => _photo = File(picked.path));
  }

  Future<void> _submit() async {
    if (_descriptionController.text.trim().isEmpty) return;
    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser!;
      String? photoUrl;

      if (_photo != null) {
        final ref = FirebaseStorage.instance.ref().child('reports/${user.uid}/${DateTime.now().millisecondsSinceEpoch}.jpg');
        await ref.putFile(_photo!);
        photoUrl = await ref.getDownloadURL();
      }

      await FirebaseFirestore.instance.collection('users').doc(user.uid).collection('reports').add({
        'type': _issueType,
        'description': _descriptionController.text.trim(),
        'photoUrl': photoUrl,
        'createdAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Report submitted!')));
      _descriptionController.clear();
      setState(() {
        _photo = null;
        _isLoading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 16),
              color: Colors.blue,
              child: const Text(
                'Report Issue',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
            const SizedBox(height: 24),
            DropdownButtonFormField<String>(
              value: _issueType,
              items: _issueTypes.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
              onChanged: (v) => setState(() => _issueType = v!),
              decoration: InputDecoration(
                labelText: 'Issue Type',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _descriptionController,
              maxLines: 5,
              decoration: InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 24),
            const Text('Add photo', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: _pickPhoto,
              child: Container(
                height: 160,
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: _photo == null
                    ? const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.camera_alt, size: 48, color: Colors.grey),
                          SizedBox(height: 8),
                          Text('Tap to take photo'),
                        ],
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(_photo!, fit: BoxFit.cover),
                      ),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.yellow[700],
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _isLoading ? null : _submit,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.black)
                    : const Text('Submit Report', style: TextStyle(fontSize: 18, color: Colors.black)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}