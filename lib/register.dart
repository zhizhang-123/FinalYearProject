import 'package:flutter/material.dart';
import 'main.dart';
import 'login.dart';

class RegisterPage extends StatefulWidget {
  RegisterPage({Key? key}) : super(key: key);

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  @override
  Widget build(BuildContext context){
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children:[
          Image.asset('assets/icon.png', width:200, height:200),
          const SizedBox(height:20),
          const Text('🪴 Register 🪴', textAlign: TextAlign.center),
          const SizedBox(height:20),
          const TextField(
            decoration: InputDecoration(
              labelText: '👤UserName',
              hintText: 'Input UserName',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height:20),
          const TextField(
            obscureText: true,
            decoration: InputDecoration(
              labelText: '🔒PassWord',
              hintText: 'Input PassWord',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height:10),
          TextButton(
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: Colors.blue, width: 2), // 设置边框颜色和宽度
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12), // 圆角
              ),
            ),
            child: Text('Register'),
            onPressed: (){
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MainPage()));
            },
          ),
          TextButton(
            child: Text('Have Account? Login Here!',
              style: TextStyle(
                decoration: TextDecoration.underline,
                decorationColor: Colors.black,
                decorationStyle: TextDecorationStyle.solid,
                color: Colors.black,
              ),
            ),
            onPressed: (){
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginPage()));
            },
          ),
        ],
      ),
    );
  }
}