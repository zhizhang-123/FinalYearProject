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
  Widget _buildCenteredMenuItem({
    required String imagePath,
    required String buttonName,
    required VoidCallback onTap,
  }) {
    return ConstrainedBox(
      constraints: const BoxConstraints(
        maxWidth: 400,
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
        title: const Text("Plant Care With AI"),
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
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> LoginPage()));
            },
          )
        ],
      ),

      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,

            children: <Widget>[
              _buildCenteredMenuItem(
                imagePath: 'assets/identify.png',
                buttonName: 'Plant Disease Identify',
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => IdentifyPage()));
                },
              ),
              const SizedBox(height: 16.0),

              _buildCenteredMenuItem(
                imagePath: 'assets/clock1.png',
                buttonName: 'Set Notification ',
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => NotificationPage()));
                },
              ),
              const SizedBox(height: 16.0),

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
    );
  }
}

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
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade400, width: 1.0),
          borderRadius: BorderRadius.circular(8.0),
        ),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Container(
              height: 100,
              alignment: Alignment.center,
              child: Image.asset(
                imagePath,
                fit: BoxFit.contain,
              ),
            ),

            const SizedBox(height: 8.0),

            Text(
              buttonName,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}