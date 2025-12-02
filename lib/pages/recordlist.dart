import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
// 【重要】请确认这里引入了你之前写的“添加页面”的文件名
import 'plantrecord.dart';

class RecordListPage extends StatelessWidget {
  const RecordListPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 1. 获取当前登录的用户
    final User? user = FirebaseAuth.instance.currentUser;

    // 如果用户没登录（理论上不应该发生，但为了安全起见）
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text("请先登录")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Plant Record List"),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        backgroundColor: Colors.green,
      ),

      // 2. 右下角的添加按钮
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // 跳转到添加页面
          Navigator.push(context, MaterialPageRoute(builder: (context) => PlantRecordPage()));
        },
        label: const Text("Add"),
        icon: const Icon(Icons.add),
        backgroundColor: Colors.green,
      ),

      // 3. 核心部分：实时监听数据库数据的 StreamBuilder
      body: StreamBuilder<QuerySnapshot>(
        // 构建查询：
        // 1. 找 'plants' 集合
        // 2. 过滤条件：userId 必须等于当前用户的 uid
        // 3. 排序：按创建时间 'createdAt' 倒序排列（新的在上面）
        stream: FirebaseFirestore.instance
            .collection('plants')
            .where('userId', isEqualTo: user.uid)
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          // 状态 A：如果连接正在等待中（通常是刚打开页面时）
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // 状态 B：如果出错了
          if (snapshot.hasError) {
            return Center(child: Text('加载失败: ${snapshot.error}'));
          }

          // 状态 C：如果没有数据，或者数据列表为空 (实现你的要求)
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return _buildEmptyState();
          }

          // 状态 D：有数据了！构建列表
          final documents = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: documents.length,
            itemBuilder: (context, index) {
              // 获取单个文档的数据
              final data = documents[index].data() as Map<String, dynamic>;
              final String docID = documents[index].id;
              // 构建卡片视图
              return _buildPlantCard(data, docID, context);
            },
          );
        },
      ),
    );
  }

  // ================= 子组件：空状态视图 =================
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
            "Click Add Button To Record Your Plant!",
            style: TextStyle(color: Colors.grey[400]),
          ),
        ],
      ),
    );
  }

  // ================= 子组件：植物卡片视图 =================
  Widget _buildPlantCard(Map<String, dynamic> data, String docID, BuildContext context) {
    final String name = data['name'] ?? '未知植物';
    final String description = data['description'] ?? '暂无描述';
    final String imageUrl = data['imageUrl'] ?? '';

    String dateString = '未知日期';

    // 检查数据库里有没有 createdAt 这个字段
    if (data['createdAt'] != null) {
      // 这里的 data['createdAt'] 可能是 Timestamp (Firestore专用格式)
      // 所以我们先尝试把它转成 DateTime
      Timestamp t = data['createdAt'] as Timestamp;
      DateTime date = t.toDate();

      // 2. 把它变成好看的字符串，例如 "2025-12-02 14:30"
      // padLeft(2,'0') 的意思是如果月份是 5，自动变成 05
      dateString = "${date.year}-${date.month.toString().padLeft(2,'0')}-${date.day.toString().padLeft(2,'0')} ${date.hour.toString().padLeft(2,'0')}:${date.minute.toString().padLeft(2,'0')}";
    }

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 左侧：图片
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: 80,
                height: 80,
                color: Colors.grey[200],
                child: imageUrl.isNotEmpty
                    ? Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  // 添加一个简单的加载占位符
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    //return const Center(child: Icon(Icons.image, color: Colors.grey));
                    return const Center(child: CircularProgressIndicator());
                  },
                  // 添加加载错误处理
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.broken_image, color: Colors.grey);
                  },
                )
                    : const Icon(Icons.image_not_supported, color: Colors.grey),
              ),
            ),
            const SizedBox(width: 16),
            // 右侧：文字信息
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // 名字 (使用 Expanded 防止名字太长把按钮挤出屏幕)
                      Expanded(
                        child: Text(
                          name,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      // 🗑️ 删除按钮
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(), // 让按钮紧凑一点
                        onPressed: () {
                          _confirmDelete(context, docID); // 点击触发确认弹窗
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 1),

                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      height: 1.3,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis, // 文字太长显示省略号
                  ),

                  const SizedBox(height: 8),

                  Row(
                    children: [
                      const Icon(Icons.access_time, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        "$dateString", // 这里显示刚才算出来的日期
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ================= 辅助函数：删除确认弹窗 =================
void _confirmDelete(BuildContext context, String docID) {
  showDialog(
    context: context,
    builder: (BuildContext ctx) {
      return AlertDialog(
        title: const Text("Confirm Delete?"),
        content: const Text("Are you confirm delete this record? Cannot restore after deleted."),
        actions: [
          // 取消按钮
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          // 确认删除按钮
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop(); // 先关掉弹窗

              // 执行删除操作
              try {
                await FirebaseFirestore.instance
                    .collection('plants')
                    .doc(docID)
                    .delete();

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Delete!')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to delete: $e')),
                );
              }
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      );
    },
  );
}