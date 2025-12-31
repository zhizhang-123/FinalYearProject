import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_ml_model_downloader/firebase_ml_model_downloader.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'solution.dart';

class IdentifyPage extends StatefulWidget {
  const IdentifyPage({Key? key}) : super(key: key);

  @override
  State<IdentifyPage> createState() => _IdentifyPageState();
}

class _IdentifyPageState extends State<IdentifyPage> {
  bool _canCheckSolution = false;
  String _currentDiseaseLabel = "";

  File? _image;
  String _result = "Take Your Leaf Photo";
  bool _isLoading = false;

  final ImagePicker _picker = ImagePicker();
  ImageLabeler? _imageLabeler;

  @override
  void dispose() {
    _imageLabeler?.close();
    super.dispose();
  }

  Future<void> _uploadResult(
      File imageFile,
      String diseaseName,
      double confidence,
      ) async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      print("User not logged in!");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login first to save history!')),
      );
      return;
    }

    try {
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();

      Reference storageRef = FirebaseStorage.instance
          .ref()
          .child('users/${user.uid}/plant_images/$fileName.jpg');

      UploadTask uploadTask = storageRef.putFile(imageFile);
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();

      await FirebaseFirestore.instance.collection('plant_history').add({
        'userId': user.uid,
        'diseaseName': diseaseName,
        'confidence': confidence,
        'imageUrl': downloadUrl,
        'timestamp': FieldValue.serverTimestamp(),
      });

      print("Upload Successful for user: ${user.uid}");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Result saved to your history!')),
      );
    } catch (e) {
      print("Upload Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Upload failed: $e')),
      );
    }
  }

  Future<void> _openSystemCamera() async {
    final pickedImage = await _picker.pickImage(source: ImageSource.camera);
    if (pickedImage != null) {
      _processImage(File(pickedImage.path));
    }
  }

  Future<void> _pickImageFromGallery() async {
    final pickedImage = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      _processImage(File(pickedImage.path));
    }
  }

  Future<void> _processImage(File imageFile) async {
    setState(() {
      _image = imageFile;
      _isLoading = true;
      _result = "Analyzing...";
      _canCheckSolution = false;
    });

    try {
      const String modelName = 'plantdisease';

      final FirebaseCustomModel model =
      await FirebaseModelDownloader.instance.getModel(
        modelName,
        FirebaseModelDownloadType.localModelUpdateInBackground,
      );

      final options = LocalLabelerOptions(
        modelPath: model.file.path,
        confidenceThreshold: 0.5,
      );

      _imageLabeler = ImageLabeler(options: options);

      final InputImage inputImage = InputImage.fromFile(imageFile);
      final List<ImageLabel> labels =
      await _imageLabeler!.processImage(inputImage);

      if (labels.isNotEmpty) {
        final topLabel = labels.first;
        final String labelText = topLabel.label;
        bool isHealthy = labelText.toLowerCase().contains('health');

        setState(() {
          _result = "Result: $labelText";
          _currentDiseaseLabel = labelText;
          _canCheckSolution = !isHealthy;
        });

        _uploadResult(imageFile, topLabel.label, topLabel.confidence);
      } else {
        setState(() {
          _result = "Unknown";
          _canCheckSolution = false;
        });
      }
    } catch (e) {
      setState(() {
        _result = "Error: $e";
        _canCheckSolution = false;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _navigateToSolution() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            SolutionPage(diseaseName: _currentDiseaseLabel),
      ),
    );
  }

  Widget _buildIdentifyButton({
    required String imagePath,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 150,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(imagePath, height: 60, fit: BoxFit.contain),
            const SizedBox(height: 12),
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Plant Disease Identify"),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                _result,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: _result == "Take Your Leaf Photo"
                      ? Colors.grey
                      : Colors.green.shade800,
                ),
              ),
            ),
            const SizedBox(height: 20),
            if (_image != null)
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    image: DecorationImage(
                      image: FileImage(_image!),
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              )
            else
              const Expanded(
                child: Center(
                  child: Icon(
                    Icons.image_not_supported_outlined,
                    size: 80,
                    color: Colors.grey,
                  ),
                ),
              ),
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.all(10.0),
                child: CircularProgressIndicator(),
              ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _canCheckSolution ? _navigateToSolution : null,
                icon: const Icon(Icons.lightbulb_outline),
                label: const Text(
                  "Check Solution",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey.shade300,
                  disabledForegroundColor: Colors.grey.shade500,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildIdentifyButton(
                    imagePath: 'assets/leafphoto.png',
                    icon: Icons.camera_alt,
                    label: 'Take Leaf Photo',
                    onTap: _openSystemCamera,
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: _buildIdentifyButton(
                    imagePath: 'assets/selectphoto.png',
                    icon: Icons.photo_library,
                    label: 'Gallery',
                    onTap: _pickImageFromGallery,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
