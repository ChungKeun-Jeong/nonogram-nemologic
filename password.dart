import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:home_learn/admin_nemo.dart';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';

class Password extends StatefulWidget {
  const Password({Key? key}) : super(key: key);

  @override
  _PasswordState createState() => _PasswordState();
}

class _PasswordState extends State<Password> {
  TextEditingController passwd = new TextEditingController();
  var correctPasswd = "tada";

  @override
  Widget build(BuildContext context) {
    final med = MediaQuery.of(context);
    return KeyboardDismisser(
      gestures: [GestureType.onTap, GestureType.onPanUpdateDownDirection],
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Container(
          child: Column(
            children: <Widget>[
              SizedBox(
                width: med.size.width,
                height: med.size.height * 0.05,
              ),
              SizedBox(
                width: med.size.width,
                height: med.size.height * 0.1,
                child: Text(
                  '관리자 모드',
                  style: TextStyle(
                    fontSize: med.size.height * 0.05,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(
                width: med.size.width,
                height: med.size.height * 0.1,
              ),
              SizedBox(
                width: med.size.width * 0.1,
                height: med.size.height * 0.1,
                child: TextField(
                  controller: passwd,
                  maxLength: 10,
                  //keyboardType: TextInputType.number,
                  //inputFormatters: [WhitelistingTextInputFormatter(RegExp('[0-9]')),],
                  obscureText: true,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'password',
                    counterText: '',
                  ),
                ),
              ),
              SizedBox(
                width: med.size.width,
                height: med.size.height * 0.05,
              ),
              SizedBox(
                width: med.size.width * 0.08,
                height: med.size.height * 0.08,
                child: RaisedButton(
                  child: Text('확인',
                      style: TextStyle(fontSize: med.size.height * 0.03)),
                  onPressed: () {
                    if (passwd.text == correctPasswd) {
                      print(passwd.text);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => AdminNemo()),
                      );
                    } else
                      print("error");
                  },
                ),
              ),
              SizedBox(
                width: med.size.width,
                height: med.size.height * 0.3,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  SizedBox(
                      width: med.size.width * 0.15,
                      height: med.size.height * 0.22,
                      child: Align(
                        alignment: Alignment.bottomLeft,
                        child: IconButton(
                          icon: Icon(
                            Icons.arrow_back,
                            color: Colors.black,
                          ),
                          // 터치시 뒤로 돌아감
                          onPressed: () => Navigator.pop(context),
                          iconSize: med.size.width * 0.1,
                        ),
                      )),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
