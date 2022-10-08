import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:home_learn/fix_nemo.dart';
import 'package:home_learn/make_nemo.dart';

// 네모로직 관리자 모드
class AdminNemo extends StatefulWidget {
  const AdminNemo({Key? key}) : super(key: key);

  @override
  _AdminNemoState createState() => _AdminNemoState();
}

class _AdminNemoState extends State<AdminNemo> {
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
              height: med.size.height * 0.05,
            ),
            Expanded(
              child: ListView.builder(
                  scrollDirection: Axis.vertical, // 밑으로 스크롤
                  shrinkWrap: true,
                  itemCount: box.length ~/ 8,
                  itemBuilder: (context, index) {
                    return Card(
                      color: Color(0xFFEFDFBB),
                      child: Container(
                        width: med.size.width,
                        height: med.size.height * 0.1,
                        child: Row(
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.all(med.size.height * 0.025),
                              child: SizedBox(
                                width: med.size.width * 0.68,
                                height: med.size.height * 0.1,
                                child: Text(
                                  "${index + 1}.    ${box.getAt(index * 8)}"
                                  "   ( ${box.getAt(index * 8 + 2)} X ${box.getAt(index * 8 + 3)} )",
                                  style: TextStyle(
                                    fontSize: med.size.height * 0.03,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: med.size.width * 0.12,
                              height: med.size.height * 0.07,
                              child: RaisedButton(
                                child: Text(
                                  '게임 수정',
                                  style: TextStyle(
                                      fontSize: med.size.height * 0.03),
                                  textAlign: TextAlign.center,
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            FixNemo(index: index)),
                                  );
                                },
                              ),
                            ),
                            SizedBox(
                              width: med.size.width * 0.03,
                              height: med.size.height * 0.05,
                            ),
                            SizedBox(
                              width: med.size.width * 0.12,
                              height: med.size.height * 0.07,
                              child: RaisedButton(
                                child: Text(
                                  '게임 삭제',
                                  style: TextStyle(
                                      fontSize: med.size.height * 0.03),
                                  textAlign: TextAlign.center,
                                ),
                                onPressed: () {
                                  deleteGame(context, index);
                                },
                              ),
                            ),
                          ],
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
                          Navigator.pop(context);
                        },
                        iconSize: med.size.width * 0.1,
                      ),
                    )),
                SizedBox(
                  width: med.size.width * 0.28,
                ),
                RaisedButton(
                  child: Text('게임 만들기',
                      style: TextStyle(fontSize: med.size.height * 0.04)),
                  color: Colors.lightBlueAccent,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => MakeNemo()),
                    );
                  },
                  shape: RoundedRectangleBorder(
                      borderRadius: new BorderRadius.circular(30.0)),
                ),
                SizedBox(
                  width: med.size.width * 0.1,
                ),
                RaisedButton(
                  child: Text('전체 삭제',
                      style: TextStyle(fontSize: med.size.height * 0.04)),
                  color: Colors.redAccent[100],
                  onPressed: () {
                    deleteAll(context);
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

  // 게임 삭제
  void deleteGame(BuildContext context, int index) {
    showDialog(
      context: context,
      //barrierDismissible - Dialog 를 제외한 다른 화면 터치 x
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              // RoundedRectangleBorder - Dialog 화면 모서리 둥글게 조절
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          // title: Column(
          //   children: <Widget>[
          //     new Text("알림"),
          //   ],
          // ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                "게임을 삭제하시겠습니까?",
              ),
            ],
          ),
          actions: <Widget>[
            FlatButton(
              child: Text("확인"),
              onPressed: () {
                setState(() {
                  for (int i = 0; i < 8; i++) {
                    box.deleteAt(index * 8);
                  }
                });
                Navigator.pop(context);
              },
            ),
            FlatButton(
              child: Text("취소"),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  void deleteAll(BuildContext context) {
    showDialog(
      context: context,
      //barrierDismissible - Dialog 를 제외한 다른 화면 터치 x
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.redAccent[200],
          shape:
              // RoundedRectangleBorder - Dialog 화면 모서리 둥글게 조절
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                "모든 게임을 삭제하시겠습니까?",
                style: TextStyle(
                    color: Colors.black,
                    fontSize: MediaQuery.of(context).size.height * 0.02,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                "확인",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: MediaQuery.of(context).size.height * 0.02,
                ),
              ),
              onPressed: () {
                box.clear();
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: Text(
                "취소",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: MediaQuery.of(context).size.height * 0.02,
                ),
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }
}
