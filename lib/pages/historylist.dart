import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'solution.dart';

class HistoryListPage extends StatelessWidget {
  const HistoryListPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("History Disease List"),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        backgroundColor: Colors.green,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('plant_history')
            .where('userId', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            print("Firestore Error: ${snapshot.error}"); // 在控制台打印详细错误
            return Center(
              child: Text("Error: ${snapshot.error}"), // 在屏幕上显示错误
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return _buildEmptyState();
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: docs.length,
            padding: const EdgeInsets.all(10),
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;

              final String disease = data['diseaseName'] ?? 'Unknown';
              final String imageUrl = data['imageUrl'] ?? '';
              final Timestamp? timestamp = data['timestamp'];

              String dateStr = "Unknown Date";
              if (timestamp != null) {
                dateStr = DateFormat('yyyy-MM-dd HH:mm').format(timestamp.toDate());
              }

              return Card(
                margin: const EdgeInsets.only(bottom: 15),
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 图片部分保持不变
                    if (imageUrl.isNotEmpty)
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                        child: Image.network(
                          imageUrl,
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          loadingBuilder: (ctx, child, progress) {
                            if (progress == null) return child;
                            return const SizedBox(
                                height: 200,
                                child: Center(child: CircularProgressIndicator())
                            );
                          },
                          errorBuilder: (ctx, error, stack) => const SizedBox(
                              height: 200,
                              child: Center(child: Icon(Icons.broken_image, color: Colors.grey))
                          ),
                        ),
                      ),

                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Plant Disease Identification: $disease",
                            style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.green
                            ),
                          ),

                          const SizedBox(height: 8),
                          Row(
                            children:[
                              const Icon(Icons.access_time, size: 14, color: Colors.grey),
                              const SizedBox(width: 6),
                              Text(
                                dateStr,
                                style: TextStyle(color: Colors.grey[500], fontSize: 12),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12.0),
                          const Divider(),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton.icon(
                              onPressed: (disease.toLowerCase().contains('health')) ? null : () {
                                Navigator.push(context, MaterialPageRoute(builder: (context) => SolutionPage(diseaseName: disease),),
                                );
                              },
                              icon: Icon(
                                Icons.lightbulb_outline,
                                color: (disease.toLowerCase() == ('health') ? Colors.grey : Colors.orange),
                              ),
                              label: Text(
                                "Solution",
                                style: TextStyle(
                                  color: (disease.toLowerCase() == ('health') ? Colors.grey : Colors.orange),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.format_list_bulleted, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            "No Record",
            style: TextStyle(
              fontSize: 20,
              color: Colors.grey[400],
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "This Will Save Identify History!",
            style: TextStyle(color: Colors.grey[400]),
          ),
        ],
      ),
    );
  }
}