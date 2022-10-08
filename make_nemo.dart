import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';

// 네모로직 만들기
class MakeNemo extends StatefulWidget {
  const MakeNemo({Key? key}) : super(key: key);

  @override
  _MakeNemo createState() => _MakeNemo();
}

class _MakeNemo extends State<MakeNemo> {
  String gameName = ''; // 게임 이름
  late List<Color> col = <Color>[]; // 버튼 색깔
  late List<int> map = []; // 관리자가 만든 맵
  late List<double> op = []; // 기능은 없는데 없애면 터치안먹음
  int chooseColor = 1; // 1 : black , 2 : white
  int mapWidth = 0, mapHeight = 0; // 맵 가로, 세로 사이즈
  int leftMaxNum = 0, topMaxNum = 0; // 게임 왼쪽, 위에 들어갈 숫자 최대 개수
  late List<int> leftNum = []; // 게임 왼쪽에 들어갈 숫자
  late List<int> topNum = []; // 게임 위에 들어갈 숫자

  // textfield에 입력된 값 가져오기 위해서 필요함
  TextEditingController textController1 = new TextEditingController();
  TextEditingController textController2 = new TextEditingController();

  var determineSize = false; // true -> 정답 부분 클릭할 수 있게 나옴
  final key = GlobalKey();

  // leftTopNumber 찾는 함수
  void findNumber() {
    mapWidth = int.parse(textController1.text);
    mapHeight = int.parse(textController2.text);

    if (mapWidth % 2 == 0)
      leftMaxNum = mapWidth ~/ 2.toInt();
    else
      leftMaxNum = ((mapWidth / 2) - 0.5 + 1).toInt();

    if (mapHeight % 2 == 0)
      topMaxNum = mapHeight ~/ 2.toInt();
    else
      topMaxNum = ((mapHeight / 2) - 0.5 + 1).toInt();
  }

  // 눌러야 하는 버튼
  Widget click(BuildContext context, int num) {
    final med = MediaQuery.of(context);
    return SizedBox(
      //width: med.size.width * 0.046875,
      //height: med.size.height * 0.07109,
      child: Ink(
        decoration: BoxDecoration(
          color: col[num],
          // 게임 종료하면 테두리 없어짐
          border: Border.all(width: 1, color: Colors.black),
        ),
        child: GestureDetector(
          child: Opacity(
            opacity: determineSize ? op[num] : 1,
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
    if (determineSize == true) {
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
                  map[target.index] = 1;
                }
              }

              // 하얀색 버튼을 누른 후에 버튼 눌렀을 때
              else if (chooseColor == 0) {
                // 누른 버튼이 하얀색 버튼이 아니면
                if (col[target.index] != Colors.white) {
                  col[target.index] = Colors.white;
                  map[target.index] = 0;
                }
              }
            });
          }
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
                  height: med.size.height * 0.1,
                  child: Text(
                    '게임 만들기',
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(
                      width: med.size.width * 0.1,
                      height: med.size.height * 0.1,
                    ),
                    Text(
                      '사이즈 (가로 X 세로)  :  ',
                      style: TextStyle(
                        fontSize: med.size.height * 0.04,
                      ),
                    ),
                    SizedBox(
                      width: med.size.width * 0.06,
                      height: med.size.height * 0.065,
                      child: TextField(
                        controller: textController1,
                        maxLength: 2,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        inputFormatters: [
                          WhitelistingTextInputFormatter(RegExp('[0-9]')),
                        ],
                        decoration: InputDecoration(
                          //border: OutlineInputBorder(),
                          counterText: '',
                        ),
                      ),
                    ),
                    Column(
                      children: <Widget>[
                        SizedBox(
                          width: med.size.width * 0.03,
                          height: med.size.height * 0.018,
                        ),
                        Text(
                          '   X   ',
                          style: TextStyle(
                            fontSize: med.size.height * 0.03,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      width: med.size.width * 0.06,
                      height: med.size.height * 0.065,
                      child: TextField(
                        controller: textController2,
                        maxLength: 2,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        inputFormatters: [
                          WhitelistingTextInputFormatter(RegExp('[0-9]')),
                        ],
                        decoration: InputDecoration(
                          counterText: '',
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
                          '확인',
                          style: TextStyle(fontSize: med.size.height * 0.03),
                          textAlign: TextAlign.center,
                        ),
                        onPressed: () {
                          setState(() {
                            findNumber();
                            determineSize = true;
                            chooseColor = 1;
                            col.clear();
                            map.clear();
                            op.clear();
                            leftNum.clear();
                            topNum.clear();
                            for (int i = 0; i < mapWidth * mapHeight; i++) {
                              col.add(Colors.white);
                              map.add(0);
                              op.add(0.0);
                            }
                            //for (int i = 0; i < leftMaxNum * mapHeight; i++) {
                            //  leftNum.add(0);
                            //}
                            //for (int i = 0; i < mapWidth * topMaxNum; i++) {
                            //  topNum.add(0);
                            //}
                          });
                        },
                      ),
                    ),
                    SizedBox(
                      width: med.size.width * 0.05,
                      height: med.size.height * 0.1,
                    ),
                    if (determineSize)
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
                    if (determineSize)
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
                    if (determineSize)
                      SizedBox(
                        width: med.size.width * 0.08,
                        height: med.size.height * 0.08,
                        child: RaisedButton(
                          child: Text('저장',
                              style:
                                  TextStyle(fontSize: med.size.height * 0.03),
                              textAlign: TextAlign.center),
                          onPressed: () {
                            _saveNemoDialog(context);
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
                          height: med.size.height * 0.45,
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
                    if (determineSize)
                      SizedBox(
                        width: med.size.width * 0.421875,
                        height: med.size.height * 0.63981,
                        child: GridView.builder(
                          key: key,
                          // 버튼 개수
                          itemCount: mapWidth * mapHeight,
                          // 여백 0
                          padding: EdgeInsets.all(0),
                          // 스크롤 방지
                          physics: NeverScrollableScrollPhysics(),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            // 가로 한 줄
                            crossAxisCount: mapWidth,
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

  // 게임 다 만들고 이름 물어보는 창
  // 확인 누르면 게임 데이터 저장
  Future _saveNemoDialog(BuildContext context) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      // dialog is dismissible with a tap on the barrier
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('게임 이름'),
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
                  leftNum.clear();
                  topNum.clear();

                  int leftSequence = 0;
                  int topSequence = 0;

                  // 왼쪽에 들어갈 숫자 찾기
                  for (int i = 0; i < mapHeight; i++) {
                    // 왼쪽에 들어갈 숫자 임시 저장
                    var leftBuf = List.generate(leftMaxNum, (index) => 0);

                    for (int j = 0; j < mapWidth; j++) {
                      if (j > 0 && map[i * mapWidth + j] == 0) {
                        leftSequence++;
                        if (j > 0 && map[i * mapWidth + j - 1] == 0) {
                          leftSequence--;
                        }
                      } else if (map[i * mapWidth + j] == 1) {
                        leftBuf[leftSequence] = leftBuf[leftSequence] + 1;
                      }
                    }

                    if (map[i * mapWidth + mapWidth - 1] == 0) leftSequence--;
                    for (int i = 0; i < leftMaxNum - leftSequence - 1; i++) {
                      leftNum.add(0);
                    }
                    for (int i = 0; i <= leftSequence; i++) {
                      leftNum.add(leftBuf[i]);
                    }
                    leftBuf.clear();
                    leftSequence = 0;
                  }

                  // 위쪽에 들어갈 숫자 찾기
                  for (int i = 0; i < mapWidth; i++) {
                    // 위에 들어갈 숫자 임시 저장
                    var topBuf = List.generate(topMaxNum, (index) => 0);

                    for (int j = 0; j < mapHeight; j++) {
                      if (j > 0 && map[j * mapWidth + i] == 0) {
                        topSequence++;
                        if (j > 0 && map[(j - 1) * mapWidth + i] == 0) {
                          topSequence--;
                        }
                      } else if (map[j * mapWidth + i] == 1) {
                        topBuf[topSequence] = topBuf[topSequence] + 1;
                      }
                    }

                    if (map[mapWidth * (mapHeight - 1) + i] == 0) topSequence--;
                    for (int i = 0; i < topMaxNum - topSequence - 1; i++) {
                      topNum.add(0);
                    }
                    for (int i = 0; i <= topSequence; i++) {
                      topNum.add(topBuf[i]);
                    }
                    topBuf.clear();
                    topSequence = 0;
                  }

                  // 위에서 구한 topNum 배열 순서가 잘못되어서 밑에서 수정
                  var topBuf =
                      List.generate(mapWidth * topMaxNum, (index) => 0);
                  var topSequence1 = 0;
                  var topSequence2 = 0;
                  for (int i = 0; i < mapWidth * topMaxNum; i++) {
                    if (topSequence2 == topMaxNum) {
                      topSequence2 = 0;
                      topSequence1++;
                    }
                    topBuf[topSequence1 + mapWidth * topSequence2] = topNum[i];
                    topSequence2++;
                  }
                  topNum = topBuf;
                });

                var box = Hive.box('nemoData');
                box.add(gameName);
                box.add(map);
                box.add(mapWidth);
                box.add(mapHeight);
                box.add(leftNum);
                box.add(leftMaxNum);
                box.add(topNum);
                box.add(topMaxNum);

                //print(box.valuesBetween());

                // db에 저장되어있는 데이터 다 삭제
                //box.clear();
                //print(box.length);

                Navigator.of(context).pop(context);
                Navigator.of(context).pop(context);
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
