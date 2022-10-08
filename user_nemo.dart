import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:home_learn/made_nemo.dart';
import 'package:home_learn/password.dart';

class UserNemo extends StatefulWidget {
  const UserNemo({Key? key}) : super(key: key);

  @override
  _UserNemoState createState() => _UserNemoState();
}

class _UserNemoState extends State<UserNemo> {
  var box = Hive.box('nemoData');
  String gameName = '';

  @override
  Widget build(BuildContext context) {
    final med = MediaQuery.of(context);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        child: Column(
          children: <Widget>[
            SizedBox(
              width: med.size.width,
              height: med.size.height * 0.05,
            ),
            Text(
              '네모 로직',
              style: TextStyle(
                fontSize: med.size.height * 0.05,
              ),
            ),
            SizedBox(
              width: med.size.width,
              height: med.size.height * 0.05,
            ),
            Expanded(
              child: ListView.builder(
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  itemCount: box.length ~/ 8,
                  itemBuilder: (context, index) {
                    return Card(
                      color: Color(0xFFEFDFBB),
                      child: SizedBox(
                        width: med.size.width,
                        height: med.size.height * 0.1,
                        child: Padding(
                          padding: EdgeInsets.all(med.size.height * 0.025),
                          child: InkWell(
                            child: Text(
                              "${index + 1}.    ${box.getAt(index * 8)}"
                              "   ( ${box.getAt(index * 8 + 2)} X ${box.getAt(index * 8 + 3)} )",
                              style: TextStyle(
                                fontSize: med.size.height * 0.03,
                              ),
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        MadeNemo(index: index)),
                              );
                            },
                            splashColor: Colors.yellow[100],
                          ),
                        ),
                      ),
                    );
                  }),
            ),
            Row(
              children: <Widget>[
                SizedBox(
                    width: med.size.width * 0.15,
                    child: Align(
                      alignment: Alignment.bottomLeft,
                      child: IconButton(
                        icon: Icon(
                          Icons.arrow_back,
                          color: Colors.black,
                        ),
                        // 터치시 뒤로 돌아감
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        iconSize: med.size.width * 0.1,
                      ),
                    )),
                SizedBox(
                  width: med.size.width * 0.62,
                ),
                RaisedButton(
                  child: Text('관리자 모드',
                      style: TextStyle(fontSize: med.size.height * 0.04)),
                  color: Colors.lightBlueAccent,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Password()),
                    );
                  },
                  shape: RoundedRectangleBorder(
                      borderRadius: new BorderRadius.circular(30.0)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
