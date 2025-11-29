import 'package:flutter/material.dart';

class PlantRecordPage extends StatefulWidget {
  PlantRecordPage({Key? key}) : super(key: key);

  @override
  _PlantRecordPageState createState() => _PlantRecordPageState();
}

class _PlantRecordPageState extends State<PlantRecordPage>{
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
      
    );
  }
}