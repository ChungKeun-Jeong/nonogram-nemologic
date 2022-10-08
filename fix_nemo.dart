import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';

// 네모로직 수정
class FixNemo extends StatefulWidget {
  final int index;

  FixNemo({required this.index});

  @override
  _FixNemoState createState() => _FixNemoState(index: index);
}

class _FixNemoState extends State<FixNemo> {
  final int index;
  final key = GlobalKey();
  var box = Hive.box('nemoData');
  int chooseColor = 1; // 1은 검은색 0은 흰색
  String gameName = '';
  late var op;
  late var changeMap;
  late var originalMap;
  late var col;

  _FixNemoState({required this.index}) {
    op = List.generate(
        box.getAt(index * 8 + 2) * box.getAt(index * 8 + 3), (index) => 0.0);
    originalMap = box.getAt(index * 8 + 1);
    col = List.generate(box.getAt(index * 8 + 2) * box.getAt(index * 8 + 3),
        (index) => Colors.white);
    for (int i = 0;
        i < box.getAt(index * 8 + 2) * box.getAt(index * 8 + 3);
        i++) {
      if (originalMap[i] == 1)
        col[i] = Colors.black;
      else if (originalMap[i] == 0) col[i] = Colors.white;
    }
    changeMap = List.generate(
        box.getAt(index * 8 + 2) * box.getAt(index * 8 + 3), (index) => 0);
    for (int i = 0;
        i < box.getAt(index * 8 + 2) * box.getAt(index * 8 + 3);
        i++) {
      changeMap[i] = originalMap[i];
    }
  }

  // 가운데 부분 버튼
  Widget click(BuildContext context, int num) {
    final med = MediaQuery.of(context);
    return SizedBox(
      //width: med.size.width * 0.046875,
      //height: med.size.height * 0.07109,
      child: Ink(
        decoration: BoxDecoration(
          color: col[num],
          border: Border.all(width: 1, color: Colors.black),
        ),
        child: GestureDetector(
          child: Opacity(
            opacity: op[num],
            child: Icon(
              Icons.stop,
              size: med.size.height * 0.1,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  // 버튼을 눌렀을 때 이벤트처리
  void tapedEvent(PointerEvent event) {
    final RenderBox box = key.currentContext!.findRenderObject() as RenderBox;
    final result = BoxHitTestResult();
    Offset local = box.globalToLocal(event.position);
    if (box.hitTest(result, position: local)) {
      for (final hit in result.path) {
        final target = hit.target;
        if (target is _Foo) {
          setState(() {
            // 검은색 버튼을 누른 후에 버튼 눌렀을 때
            if (chooseColor == 1) {
              // 누른 버튼이 검은색이 아니면
              if (col[target.index] != Colors.black) {
                col[target.index] = Colors.black;
                changeMap[target.index] = 1;
              }
            }

            // 하얀색 버튼을 누른 후에 버튼 눌렀을 때
            else if (chooseColor == 0) {
              // 누른 버튼이 하얀색 버튼이 아니면
              if (col[target.index] != Colors.white) {
                col[target.index] = Colors.white;
                changeMap[target.index] = 0;
              }
            }
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final med = MediaQuery.of(context);
    return KeyboardDismisser(
      gestures: [GestureType.onTap, GestureType.onPanUpdateDownDirection],
      child: Listener(
        onPointerDown: tapedEvent,
        onPointerMove: tapedEvent,
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
                  height: med.size.height * 0.08,
                  child: Text(
                    '게임 수정',
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
                Row(
                  children: <Widget>[
                    SizedBox(
                      width: med.size.width * 0.05,
                      height: med.size.height * 0.1,
                    ),
                    SizedBox(
                      width: med.size.width * 0.5,
                      height: med.size.height * 0.1,
                      child: Text(
                        '${box.getAt(index * 8)} ( ${box.getAt(index * 8 + 2)} X ${box.getAt(index * 8 + 3)} )',
                        style: TextStyle(
                          fontSize: med.size.height * 0.04,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: med.size.width * 0.05,
                      height: med.size.height * 0.1,
                    ),
                    SizedBox(
                      width: med.size.width * 0.046875,
                      height: med.size.height * 0.07109,
                      child: Ink(
                        decoration: BoxDecoration(
                          color: Colors.black,
                          border: Border.all(width: 1, color: Colors.black),
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(0),
                          onTap: () {
                            chooseColor = 1;
                          },
                        ),
                      ),
                    ),
                    SizedBox(
                      width: med.size.width * 0.046875,
                      height: med.size.height * 0.07109,
                      child: Ink(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(width: 1, color: Colors.black),
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(0),
                          onTap: () {
                            chooseColor = 0;
                          },
                        ),
                      ),
                    ),
                    SizedBox(
                      width: med.size.width * 0.05,
                      height: med.size.height * 0.1,
                    ),
                    SizedBox(
                      width: med.size.width * 0.08,
                      height: med.size.height * 0.08,
                      child: RaisedButton(
                        child: Text(
                          '저장',
                          style: TextStyle(fontSize: med.size.height * 0.03),
                          textAlign: TextAlign.center,
                        ),
                        onPressed: () {
                          setState(() {
                            box.putAt(index * 8 + 1, changeMap);
                            fixFinish(context);
                          });
                        },
                      ),
                    ),
                    SizedBox(
                      width: med.size.width * 0.05,
                      height: med.size.height * 0.1,
                    ),
                    SizedBox(
                      width: med.size.width * 0.08,
                      height: med.size.height * 0.08,
                      child: RaisedButton(
                        child: Text(
                          '이름 변경',
                          style: TextStyle(fontSize: med.size.height * 0.03),
                          textAlign: TextAlign.center,
                        ),
                        onPressed: () {
                          setState(() {
                            changeGameName(context, index);
                          });
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  width: med.size.width,
                  height: med.size.height * 0.03,
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Column(
                      children: <Widget>[
                        SizedBox(
                          width: med.size.width * 0.15,
                          height: med.size.height * 0.47,
                        ),
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
                    SizedBox(
                      width: med.size.width * 0.1390625,
                      height: med.size.height * 0.5,
                    ),
                    SizedBox(
                      width: med.size.width * 0.421875,
                      height: med.size.height * 0.63981,
                      child: GridView.builder(
                        key: key,
                        // 버튼 개수
                        itemCount:
                            box.getAt(index * 8 + 2) * box.getAt(index * 8 + 3),
                        // 여백 0
                        padding: EdgeInsets.all(0),
                        // 스크롤 방지
                        physics: NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          // 가로 한 줄
                          crossAxisCount: box.getAt(index * 8 + 2),
                          // 가로 세로 비율
                          childAspectRatio:
                              med.size.width / med.size.height / 1.51,
                          // 가로 여백, 세로 여백
                          crossAxisSpacing: 0.0,
                          mainAxisSpacing: 0.0,
                        ),
                        itemBuilder: (context, index) {
                          return Foo(
                            index: index,
                            child: click(context, index),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 게임 이름 수정
  Future changeGameName(BuildContext context, int index) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      // dialog is dismissible with a tap on the barrier
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('수정할 게임 이름'),
          content: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Row(
              children: [
                new Expanded(
                    child: new TextField(
                  autofocus: true,
                  maxLength: 20,
                  decoration:
                      new InputDecoration(labelText: 'Game Name', hintText: ''),
                  onChanged: (value) {
                    gameName = value;
                  },
                ))
              ],
            ),
          ),
          actions: [
            FlatButton(
              child: Text('확인'),
              onPressed: () {
                setState(() {
                  box.putAt(index * 8, gameName);
                  Navigator.of(context).pop(context);
                });
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

  void fixFinish(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Colors.green[200],
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            content: new Text(
              "수정되었습니다.   :)",
              style: TextStyle(
                  color: Colors.black,
                  fontSize: MediaQuery.of(context).size.height * 0.05,
                  fontWeight: FontWeight.bold),
            ),
          );
        });
  }
}

class Foo extends SingleChildRenderObjectWidget {
  late final int index;

  Foo({Widget? child, required this.index, Key? key})
      : super(child: child, key: key);

  @override
  _Foo createRenderObject(BuildContext context) {
    return _Foo()..index = index;
  }

  @override
  void updateRenderObject(BuildContext context, _Foo renderObject) {
    renderObject..index = index;
  }
}

class _Foo extends RenderProxyBox {
  //int index;
  //int? index;
  late int index;
}
