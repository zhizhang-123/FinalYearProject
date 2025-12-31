import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PlantRecordPage extends StatefulWidget {
  const PlantRecordPage({Key? key}) : super(key: key);

  @override
  _PlantRecordPageState createState() => _PlantRecordPageState();
}

class _PlantRecordPageState extends State<PlantRecordPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descController = TextEditingController();

  File? _photo;
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;

  Future<void> _pickImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(source: source, imageQuality: 10);

    if (pickedFile != null) {
      setState(() {
        _photo = File(pickedFile.path);
      });
    }
  }

  Future<void> _uploadPlant() async {
    if (_photo == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Take Photo First')));
      return;
    }

    setState(() { _isUploading = true; });

    try {
      final String fileName = "${DateTime.now().millisecondsSinceEpoch}.jpg";

      final Reference storageRef = FirebaseStorage.instance
          .ref()
          .child('plant_photos')
          .child(fileName);

      final UploadTask uploadTask = storageRef.putFile(_photo!);

      final TaskSnapshot snapshot = await uploadTask;

      final String downloadUrl = await snapshot.ref.getDownloadURL();

      User? user = FirebaseAuth.instance.currentUser;
      String uid = user?.uid ?? "anonymous";

      await FirebaseFirestore.instance.collection('plants').add({
        'name': _nameController.text,
        'description': _descController.text,
        'imageUrl': downloadUrl,
        'createdAt': DateTime.now(),
        'userId': uid,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Save successful！🌱')));
        Navigator.pop(context);
      }

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Upload fail: $e')));
      }
    } finally {
      if (mounted) {
        setState(() { _isUploading = false; });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Plant Record"),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        backgroundColor: Colors.green,),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GestureDetector(
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  builder: (context) => SafeArea(
                    child: Wrap(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.camera_alt),
                          title: const Text('Take Photo'),
                          onTap: () {
                            Navigator.pop(context);
                            _pickImage(ImageSource.camera);
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.photo_library),
                          title: const Text('Gallery'),
                          onTap: () {
                            Navigator.pop(context);
                            _pickImage(ImageSource.gallery);
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
              child: Container(
                height: 250,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey),
                ),
                child: _photo != null
                    ? ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(_photo!, fit: BoxFit.cover),
                )
                    : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.add_a_photo, size: 50, color: Colors.grey),
                    SizedBox(height: 8),
                    Text("Click This To Upload Photo!"),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Your Plant Name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.local_florist),
              ),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _descController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Remark',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.description),
              ),
            ),
            const SizedBox(height: 30),

            ElevatedButton(
              onPressed: _isUploading ? null : _uploadPlant,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.green,
              ),
              child: _isUploading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                "Add Record",
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}