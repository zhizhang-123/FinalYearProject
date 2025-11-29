import 'package:flutter/material.dart';
import 'plantrecord.dart';

class RecordPage extends StatefulWidget {
  RecordPage({Key? key}) : super(key: key);

  @override
  _RecordPageState createState() => _RecordPageState();
}

class _RecordPageState extends State<RecordPage>{
  Widget _buildCenteredRecordItem({
    required String imagePath,
    required String buttonName,
    required VoidCallback onTap,
  }) {
    return ConstrainedBox(
      constraints: const BoxConstraints(
        maxWidth: 400,
      ),
      child: _RecordItemButton(
        imagePath: imagePath,
        buttonName: buttonName,
        onTap: onTap,
      ),
    );
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plant Record'),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        backgroundColor: Colors.green,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,

            children: <Widget>[
              _buildCenteredRecordItem(
                imagePath: 'assets/leafphoto.png',
                buttonName: 'Plant Record',
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => PlantRecordPage()));
                },
              ),

              const SizedBox(height: 16.0),

              _buildCenteredRecordItem(
                imagePath: 'assets/selectphoto.png',
                buttonName: 'Plant Disease History',
                onTap: () {
                  print('b');
                },
              ),

              const SizedBox(height: 16.0),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecordItemButton extends StatelessWidget {
  final String imagePath;
  final String buttonName;
  final VoidCallback onTap;

  const _RecordItemButton({
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