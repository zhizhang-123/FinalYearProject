import 'package:flutter/material.dart';
import 'main.dart';

class IdentifyPage extends StatefulWidget {
  IdentifyPage({Key? key}) : super(key: key);

  @override
  _IdentifyPageState createState() => _IdentifyPageState();
}

class _IdentifyPageState extends State<IdentifyPage>{
  @override
  Widget build(BuildContext context){
    return Scaffold(
      body: Container(
        child: Center(
          child: TextButton(
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Colors.blue, width: 2), // 设置边框颜色和宽度
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12), // 圆角
                ),
              ),
              child: Text('On Progress!!!'),
              onPressed: (){
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MainPage()));
              }
          ),
        ),
      ),
    );
  }
}