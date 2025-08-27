import 'package:flutter/material.dart';
import 'main.dart';

class RecordPage extends StatefulWidget {
  RecordPage({Key? key}) : super(key: key);

  @override
  _RecordPageState createState() => _RecordPageState();
}

class _RecordPageState extends State<RecordPage>{
  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plant Record'),
      ),
      body: Container(
        child: Center(
          child: Text(
            'No Plant Record Set!',
            style: TextStyle(color: Colors.red, fontSize:30),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){

        },
        child: Icon(
            Icons.add
        ),
      ),
    );
  }
}