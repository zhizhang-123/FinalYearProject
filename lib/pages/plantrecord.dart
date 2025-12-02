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
  // 控制器，用于获取文本框输入
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descController = TextEditingController();

  File? _photo; // 存储用户拍摄/选择的照片
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false; // 上传状态Loading

  // ==========================================
  // 1. 补全缺失的：选择图片功能
  // ==========================================
  Future<void> _pickImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(source: source, imageQuality: 10);

    if (pickedFile != null) {
      setState(() {
        _photo = File(pickedFile.path);
      });
    }
  }

  // ==========================================
  // 2. 上传功能 (保持你原本正确的逻辑)
  // ==========================================
  Future<void> _uploadPlant() async {
    // 基本检查
    if (_photo == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('请先拍照')));
      return;
    }

    setState(() { _isUploading = true; });

    try {
      // 准备文件名 (使用当前时间戳)
      final String fileName = "${DateTime.now().millisecondsSinceEpoch}.jpg";

      // 获取引用
      // (新项目会自动从 google-services.json 读取 bucket，无需手动指定)
      final Reference storageRef = FirebaseStorage.instance
          .ref()
          .child('plant_photos') // 存放在 plant_photos 文件夹
          .child(fileName);

      // 上传文件
      print("开始上传...");
      final UploadTask uploadTask = storageRef.putFile(_photo!);

      // 等待上传完成
      final TaskSnapshot snapshot = await uploadTask;
      print("上传成功！");

      // 获取下载链接
      final String downloadUrl = await snapshot.ref.getDownloadURL();
      print("图片链接: $downloadUrl");

      // 存入 Firestore
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
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('保存成功！🌱')));
        Navigator.pop(context); // 返回上一页
      }

    } catch (e) {
      print("报错了: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('上传失败: $e')));
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
            // 图片展示区域
            GestureDetector(
              onTap: () {
                // 点击弹出选择框：拍照或相册
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
                            _pickImage(ImageSource.camera); // 这里的红线现在应该消失了
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.photo_library),
                          title: const Text('Gallery'),
                          onTap: () {
                            Navigator.pop(context);
                            _pickImage(ImageSource.gallery); // 这里的红线现在应该消失了
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

            // 输入框：植物名称
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Your Plant Name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.local_florist),
              ),
            ),
            const SizedBox(height: 16),

            // 输入框：备注描述
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

            // 上传按钮
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