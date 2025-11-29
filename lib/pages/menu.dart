import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login.dart';
import 'identify.dart';
import 'notification.dart';
import 'record.dart';

class MenuPage extends StatefulWidget {
  MenuPage({Key? key}) : super(key: key);

  @override
  _MenuPageState createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage>{
  // 辅助方法：构建居中的菜单项
  Widget _buildCenteredMenuItem({
    required String imagePath,
    required String buttonName,
    required VoidCallback onTap,
  }) {
    // 使用 ConstrainedBox 限制单个按钮的最大宽度，实现水平居中效果
    return ConstrainedBox(
      constraints: const BoxConstraints(
        maxWidth: 400, // 设定按钮的最大宽度，您可以调整这个值
      ),
      child: _MenuItemButton(
        imagePath: imagePath,
        buttonName: buttonName,
        onTap: onTap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Plant Care With AI"), // 确保 title 是 const
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        backgroundColor: Colors.green,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              // 使用 pushReplacement 导航到登录页，并移除所有历史记录
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> LoginPage()));
            },
          )
        ],
      ),

      // *** 修改开始：用 Center + Column 替换 ListView ***
      body: Center(
        // Column 用于垂直堆叠按钮
        child: SingleChildScrollView( // <--- 建议添加 SingleChildScrollView 以防按钮过多时溢出
          padding: const EdgeInsets.all(16.0),
          child: Column(
            // 确保 Column 的内容在垂直方向上居中
            mainAxisAlignment: MainAxisAlignment.center,
            // 确保 Column 只占用子组件所需的最小高度
            mainAxisSize: MainAxisSize.min,

            children: <Widget>[
              // 菜单项 1
              _buildCenteredMenuItem(
                imagePath: 'assets/identify.png',
                buttonName: 'Plant Disease Identify',
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => IdentifyPage()));
                },
              ),
              const SizedBox(height: 16.0), // 按钮之间的间距

              // 菜单项 2
              _buildCenteredMenuItem(
                imagePath: 'assets/clock1.png',
                buttonName: 'Set Notification ',
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => NotificationPage()));
                },
              ),
              const SizedBox(height: 16.0), // 按钮之间的间距

              // 菜单项 3
              _buildCenteredMenuItem(
                imagePath: 'assets/icon.png',
                buttonName: 'Plant Record',
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => RecordPage()));
                },
              ),
            ],
          ),
        ),
      ),
      // *** 修改结束 ***
    );
  }
}

// *** _MenuItemButton 保持不变，但移除了冗余的边框 ***
class _MenuItemButton extends StatelessWidget {
  final String imagePath;
  final String buttonName;
  final VoidCallback onTap;

  const _MenuItemButton({
    required this.imagePath,
    required this.buttonName,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // InkWell 提供水波纹效果，让点击更有反馈
    return InkWell(
      onTap: onTap,
      child: Container(
        // 为整个按钮添加一个边框，颜色与您的标题栏颜色配合，使用灰色
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade400, width: 1.0),
          borderRadius: BorderRadius.circular(8.0), // 可选：添加圆角
        ),
        padding: const EdgeInsets.all(16.0), // 内部填充
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // 1. 图片部分
            Container(
              height: 100, // 设定图片高度
              alignment: Alignment.center,
              // 如果图片有背景，您可以将图片放在 Center 中
              child: Image.asset(
                imagePath,
                fit: BoxFit.contain, // 使用 contain 确保图片完整显示
              ),
            ),

            const SizedBox(height: 8.0), // 图片和文字之间的间距

            // 2. 文字部分
            Text(
              buttonName,
              textAlign: TextAlign.center, // 文字居中
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black, // 保持黑色，除非背景变深
              ),
            ),
          ],
        ),
      ),
    );
  }
}