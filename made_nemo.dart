import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'dart:typed_data';
import 'dart:async';
import 'dart:math';

import 'package:permission_handler/permission_handler.dart';
import 'package:screenshot/screenshot.dart';
import 'package:image/image.dart' as im;
import 'package:image_gallery_saver/image_gallery_saver.dart';

// 네모로직 만든거 게임 시작
class MadeNemo extends StatefulWidget {
  final int index;

  MadeNemo({required this.index});

  @override
  _MadeNemoState createState() => _MadeNemoState(index: index);
}

class _MadeNemoState extends State<MadeNemo> {
  final int index; // DB에 저장되어 있는 순서
  final key = GlobalKey();
  var box = Hive.box('nemoData'); // Database
  int chooseColor = 1; // 0 : White / 1 : Black / 2 : X 표시
  int finishColor =
      0; // 0 : black / 1 : blue / 2 : yellow / 3 : pink / 4 : green / 5 : cyan
  int undoCount = 0; // 뒤로가기 버튼 눌린 횟수
  int redoCount = 0; // 되돌리기 버튼 눌린 횟수
  List<int> undoIndex = []; // 뒤로가기 눌렀을 때 수정해야하는 인덱스
  List<int> undoColor = []; // 뒤로가기 눌렀을 때 바꿀 색
  List<int> redoIndex = []; // 되돌리기 눌렀을 때 수정해야하는 인덱스
  List<int> redoColor = []; // 되돌리기 눌렀을 때 바꿀 색
  ScreenshotController screenshotController =
      ScreenshotController(); // 화면 캡처할 때 필요한거
  var decoFinish = false; // 게임 끝나고 완성본 색칠하는게 끝나면 true
  var lock = false; // 게임 끝나면 true
  late Uint8List _imageFile; // 캡처한 image, 화면 전체 캡처
  late var op; // op(투명도) 0 = X 이모티콘 안보임 , op(투명도) 1 = X 이모티콘 보임
  late var userMap; // 유저가 칠한 곳
  late var correctMap; // 정답
  late var col; // 게임부분 버튼 색깔
  late var leftOp; // 왼쪽에 버튼 투명도
  late var topOp; // 위쪽에 버튼 투명도
  late var leftNum; // 게임 왼쪽에 들어갈 숫자
  late var leftMaxNum; // 게임 왼쪽에 들어갈 숫자 한줄에 들어갈 최대 개수
  late var topNum; // 게임 위에 들어갈 숫자
  late var topMaxNum; // 게임 왼쪽에 들어갈 숫자 한줄에 들어갈 최대 개수
  late var mapWidth; // 게임 부분 가로
  late var mapHeight; // 게임 부분 세로
  late int nameNumber; // 파일 이름 _뒤에 숫자
  late var fileName; // 스크린샷 파일 이름

  _MadeNemoState({required this.index}) {
    fileName = box.getAt(index * 8);
    correctMap = box.getAt(index * 8 + 1);
    mapWidth = box.getAt(index * 8 + 2);
    mapHeight = box.getAt(index * 8 + 3);
    leftNum = box.getAt(index * 8 + 4);
    leftMaxNum = box.getAt(index * 8 + 5);
    topNum = box.getAt(index * 8 + 6);
    topMaxNum = box.getAt(index * 8 + 7);

    op = List.generate(mapWidth * mapHeight, (index) => 0.0);
    col = List.generate(mapWidth * mapHeight, (index) => Colors.white);
    userMap = List.generate(mapWidth * mapHeight, (index) => 0);
    leftOp = List.generate(mapHeight * leftMaxNum, (index) => 1.0);
    topOp = List.generate(mapWidth * topMaxNum, (index) => 1.0);
  }

  // 눌러야 하는 버튼
  Widget click(BuildContext context, int num) {
    final med = MediaQuery.of(context);
    return SizedBox(
      child: Ink(
        decoration: BoxDecoration(
          color: col[num],
          // 게임 종료하면 테두리 없어짐
          border: lock ? null : Border.all(width: 1, color: Colors.black),
        ),
        child: GestureDetector(
          child: Opacity(
            opacity: op[num],
            // 평소에는 투명하게 있다가 오른쪽 x 버튼 누르고 누르면 X 모양 아이콘 보임
            child: Icon(
              Icons.clear,
              size: med.size.height * 0.5 / mapWidth,
              color: Colors.black,
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
        if (target is _Foo && decoFinish == false) {
          // 게임이 종료되면 lock = true / 버튼 못 누름
          if (lock == false) {
            setState(() {
              // 검은색 버튼을 누른 후에 버튼 눌렀을 때
              if (chooseColor == 1) {
                // 누른 버튼이 검은색이 아니면
                if (col[target.index] != Colors.black) {
                  undoColor.add(findColor(target.index));
                  undoIndex.add(target.index);
                  op[target.index] = 0.0;
                  col[target.index] = Colors.black;
                  userMap[target.index] = 1;
                  undoCount++;
                }
              }
              // X 버튼을 누른 후에 버튼 눌렀을 때
              else if (chooseColor == 2) {
                // 누른 버튼이 X 버튼이 아니면
                if (op[target.index] != 1.0) {
                  undoColor.add(findColor(target.index));
                  undoIndex.add(target.index);
                  op[target.index] = 1.0;
                  col[target.index] = Colors.white;
                  userMap[target.index] = 0;
                  undoCount++;
                }
              }
              // 하얀색 버튼을 누른 후에 버튼 눌렀을 때
              else if (chooseColor == 0) {
                // 누른 버튼이 하얀색 버튼이 아니면
                if (col[target.index] != Colors.white &&
                    op[target.index] != 1.0) {
                  undoColor.add(findColor(target.index));
                  undoIndex.add(target.index);
                  op[target.index] = 0.0;
                  col[target.index] = Colors.white;
                  userMap[target.index] = 0;
                  undoCount++;
                }
                // 누른 버튼이 x 버튼이면
                else if (col[target.index] == Colors.white &&
                    op[target.index] == 1.0) {
                  undoColor.add(findColor(target.index));
                  undoIndex.add(target.index);
                  op[target.index] = 0.0;
                  undoCount++;
                }
              }
            });

            // 새로운 버튼을 누르면 redo 초기화
            redoCount = 0;
            redoColor.clear();
            redoIndex.clear();

            // 게임 종료 검사
            finishCheck();
          }

          // 게임 종료후에 완성품에 클릭 가능
          else if (lock == true) {
            setState(() {
              if (correctMap[target.index] == 1) {
                if (finishColor == 0)
                  col[target.index] = Colors.black;
                else if (finishColor == 1)
                  col[target.index] = Colors.blue;
                else if (finishColor == 2)
                  col[target.index] = Colors.yellow;
                else if (finishColor == 3)
                  col[target.index] = Colors.pink;
                else if (finishColor == 4)
                  col[target.index] = Colors.green;
                else if (finishColor == 5) col[target.index] = Colors.cyan;
              }
            });
          }
        }
      }
    }
  }

  // 캡처
  void _capture() async {
    // 저장 공간 권한 주기
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      // 저장 공간 권한이 없으면 권한 달라고 요청함
      await Permission.storage.request();
    }

    // 권한 있는지 확인 - granted(권한o)
    //Map<Permission, PermissionStatus> permissions = await [
    //  Permission.location,
    //  Permission.storage,
    //].request();
    //print(permissions[Permission.storage]);

    if (await Permission.storage.isPermanentlyDenied) {
      // 유저가 권한을 거부하였을 경우 앱설정으로 진입
      openAppSettings();
    }

    print("START CAPTURE");
    decoFinish = true;
    nameNumber = Random().nextInt(100000);

    screenshotController.capture().then((var image) async {
      // 캡처한 이미지를 _imageFile 에 넣음
      _imageFile = image as Uint8List;

      var med = MediaQuery.of(context);

      // 캡처된 전체 이미지 가운데만 나오게 자르기
      var img = im.decodeImage(_imageFile) as im.Image;
      var x = (med.size.width * 0.11 +
              (med.size.width * 0.375 / mapWidth * leftMaxNum)) *
          med.devicePixelRatio;
      var y = med.size.height * 0.39128 * med.devicePixelRatio;
      var w = med.size.width * 0.375 * med.devicePixelRatio;
      var h = med.size.height *
          0.56872 /
          mapWidth *
          mapHeight *
          med.devicePixelRatio;

      var croppedImage =
          im.copyCrop(img, x.toInt(), y.toInt(), w.toInt(), h.toInt());

      // croppedImage 는 타입이 Image / 그걸 Uint8List 로 바꿔줌
      Uint8List imageRaw = Uint8List.fromList(im.encodePng(croppedImage));

      ImageGallerySaver.saveImage(Uint8List.fromList(imageRaw),
          quality: 100, name: '$fileName' + '_' + '$nameNumber');
    });

    print("FINISH CAPTURE");
  }

  // 뒤로가기 , 되돌리기 할 때 바꿔야할 색 찾기
  int findColor(int index) {
    int color = 0;
    if (col[index] == Colors.black)
      color = 1;
    else if (col[index] == Colors.white) {
      if (op[index] == 1.0)
        color = 2;
      else if (op[index] == 0.0) color = 0;
    }
    return color;
  }

  // 게임이 끝났는지 검사
  void finishCheck() {
    int num = 0;
    for (int i = 0; i < mapWidth * mapHeight; i++) {
      if (correctMap[i] == userMap[i])
        num++;
      else
        break;
    }

    if (num == mapWidth * mapHeight) {
      lock = true;
      correctAnswer(context);
      for (int i = 0; i < mapHeight * leftMaxNum; i++) leftOp[i] = 0.0;
      for (int i = 0; i < mapWidth * topMaxNum; i++) topOp[i] = 0.0;
      for (int i = 0; i < mapWidth * mapHeight; i++) op[i] = 0.0;
    }
  }

  // 위쪽에 숫자부분
  Widget topNumber(BuildContext context, String string, int num) {
    final med = MediaQuery.of(context);
    double top = med.size.height * 0.1 / mapWidth;
    return SizedBox(
      child: Padding(
        padding: EdgeInsets.all(med.size.height * 0.02 / mapWidth),
        child: Opacity(
          opacity: topOp[num],
          child: Ink(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(topOp[num]),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(0),
              child: Padding(
                padding: EdgeInsets.only(top: top),
                child: Text(
                  string,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: med.size.height * 0.25 / mapWidth,
                    decoration:
                        topOp[num] == 1.0 ? null : TextDecoration.lineThrough,
                    decorationThickness: med.size.height * 0.05 / mapWidth,
                    decorationColor: Colors.black,
                  ),
                ),
              ),
              onTap: () {
                if (lock == false) {
                  setState(() {
                    if (topOp[num] == 1.0)
                      topOp[num] = 0.5;
                    else
                      topOp[num] = 1.0;
                  });
                } else
                  print(" ");
              },
            ),
          ),
        ),
      ),
    );
  }

  // 왼쪽에 숫자부분
  Widget leftNumber(BuildContext context, String string, int num) {
    final med = MediaQuery.of(context);
    double top = med.size.height * 0.1 / mapWidth;
    return SizedBox(
      child: Padding(
        padding: EdgeInsets.all(med.size.height * 0.02 / mapWidth),
        child: Opacity(
          opacity: leftOp[num],
          child: Ink(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(leftOp[num]),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(0),
              child: Padding(
                padding: EdgeInsets.only(top: top),
                child: Text(
                  string,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: med.size.height * 0.25 / mapWidth,
                    decoration:
                        leftOp[num] == 1.0 ? null : TextDecoration.lineThrough,
                    decorationThickness: med.size.height * 0.05 / mapWidth,
                    decorationColor: Colors.black,
                  ),
                ),
              ),
              onTap: () {
                if (lock == false) {
                  setState(() {
                    if (leftOp[num] == 1.0)
                      leftOp[num] = 0.5;
                    else
                      leftOp[num] = 1.0;
                  });
                } else
                  print(" ");
              },
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final med = MediaQuery.of(context);
    return Screenshot(
      controller: screenshotController,
      child: Listener(
        onPointerDown: tapedEvent,
        onPointerMove: tapedEvent,
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          body: Column(
            children: <Widget>[
              SizedBox(
                width: med.size.width,
                height: med.size.height * 0.05,
              ),
              SizedBox(
                height: med.size.height * 0.34128 -
                    (med.size.height * 0.56872 / mapWidth * topMaxNum),
              ),
              Row(
                children: <Widget>[
                  SizedBox(
                    width: med.size.width * 0.11 +
                        (med.size.width * 0.375 / mapWidth * leftMaxNum),
                  ),

                  // 위쪽 숫자 부분
                  SizedBox(
                    width: med.size.width * 0.375,
                    height: med.size.height * 0.56872 / mapWidth * topMaxNum,
                    child: GridView.builder(
                      itemCount: mapWidth * topMaxNum,
                      padding: EdgeInsets.all(0),
                      physics: NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
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
                        return topNum[index] == 0
                            ? SizedBox()
                            : topNumber(
                                context, topNum[index].toString(), index);
                      },
                    ),
                  ),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      SizedBox(
                        height: med.size.height * 0.385,
                      ),

                      // 뒤로가기 버튼
                      SizedBox(
                          width: med.size.width * 0.11,
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

                  // 왼쪽 숫자 부분
                  SizedBox(
                    width: med.size.width * 0.375 / mapWidth * leftMaxNum,
                    height: med.size.height * 0.56872 / mapWidth * mapHeight,
                    child: GridView.builder(
                      itemCount: mapHeight * leftMaxNum,
                      padding: EdgeInsets.all(0),
                      physics: NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        // 가로 한 줄
                        crossAxisCount: leftMaxNum,
                        // 가로 세로 비율
                        childAspectRatio:
                            med.size.width / med.size.height / 1.51,
                        // 가로 여백, 세로 여백
                        crossAxisSpacing: 0.0,
                        mainAxisSpacing: 0.0,
                      ),
                      itemBuilder: (context, index) {
                        return leftNum[index] == 0
                            ? SizedBox()
                            : leftNumber(
                                context, leftNum[index].toString(), index);
                      },
                    ),
                  ),

                  // 클릭하는 부분
                  SizedBox(
                    width: med.size.width * 0.375,
                    height: med.size.height * 0.56872,
                    child: GridView.builder(
                      key: key,
                      // 버튼 개수
                      itemCount: mapWidth * mapHeight,
                      // 여백 0
                      padding: EdgeInsets.all(0),
                      // 스크롤 방지
                      physics: NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
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

                  Column(
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          if (!lock)
                            SizedBox(
                              width: med.size.width * 0.03,
                            ),

                          // 뒤로가기 버튼
                          if (!lock)
                            SizedBox(
                              width: med.size.width * 0.046875,
                              height: med.size.height * 0.07109,
                              child: Ink(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border:
                                      Border.all(width: 1, color: Colors.black),
                                ),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(0),
                                  child: Icon(
                                    Icons.undo,
                                    size: med.size.height * 0.05,
                                    color: Colors.black,
                                  ),
                                  onTap: () {
                                    if (undoCount > 0) {
                                      setState(() {
                                        // 뒤로갈 버튼이 검은색일 때
                                        if (undoColor.last == 1) {
                                          redoIndex.add(undoIndex.last);
                                          redoColor
                                              .add(findColor(undoIndex.last));
                                          op[undoIndex.last] = 0.0;
                                          col[undoIndex.last] = Colors.black;
                                          userMap[undoIndex.last] = 1;
                                          redoCount++;
                                        }
                                        // 뒤로갈 버튼이 X일 때
                                        else if (undoColor.last == 2) {
                                          redoIndex.add(undoIndex.last);
                                          redoColor
                                              .add(findColor(undoIndex.last));
                                          op[undoIndex.last] = 1.0;
                                          col[undoIndex.last] = Colors.white;
                                          userMap[undoIndex.last] = 0;
                                          redoCount++;
                                        }
                                        // 뒤로갈 버튼이 하얀색일 때
                                        else if (undoColor.last == 0) {
                                          redoIndex.add(undoIndex.last);
                                          redoColor
                                              .add(findColor(undoIndex.last));
                                          op[undoIndex.last] = 0.0;
                                          col[undoIndex.last] = Colors.white;
                                          userMap[undoIndex.last] = 0;
                                          redoCount++;
                                        }

                                        // 뒤로가기 List 마지막 요소는 제거
                                        undoCount--;
                                        undoColor.removeAt(undoCount);
                                        undoIndex.removeAt(undoCount);
                                      });
                                    }
                                  },
                                ),
                              ),
                            ),

                          if (!lock)
                            SizedBox(
                              width: med.size.width * 0.02,
                            ),

                          // 되돌리기 버튼
                          if (!lock)
                            SizedBox(
                              width: med.size.width * 0.046875,
                              height: med.size.height * 0.07109,
                              child: Ink(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border:
                                      Border.all(width: 1, color: Colors.black),
                                ),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(0),
                                  child: Icon(
                                    Icons.redo,
                                    size: med.size.height * 0.05,
                                    color: Colors.black,
                                  ),
                                  onTap: () {
                                    if (redoCount > 0) {
                                      setState(() {
                                        // 검은색일 때
                                        if (redoColor.last == 1) {
                                          undoColor
                                              .add(findColor(redoIndex.last));
                                          undoIndex.add(redoIndex.last);
                                          undoCount++;
                                          op[redoIndex.last] = 0.0;
                                          col[redoIndex.last] = Colors.black;
                                          userMap[redoIndex.last] = 1;
                                        }
                                        // X일 때
                                        else if (redoColor.last == 2) {
                                          undoColor
                                              .add(findColor(redoIndex.last));
                                          undoIndex.add(redoIndex.last);
                                          undoCount++;
                                          op[redoIndex.last] = 1.0;
                                          col[redoIndex.last] = Colors.white;
                                          userMap[redoIndex.last] = 0;
                                        }
                                        // 하얀색일 때
                                        else if (redoColor.last == 0) {
                                          undoColor
                                              .add(findColor(redoIndex.last));
                                          undoIndex.add(redoIndex.last);
                                          undoCount++;
                                          op[redoIndex.last] = 0.0;
                                          col[redoIndex.last] = Colors.white;
                                          userMap[redoIndex.last] = 0;
                                        }
                                        redoCount--;
                                        redoColor.removeAt(redoCount);
                                        redoIndex.removeAt(redoCount);
                                      });
                                    }
                                  },
                                ),
                              ),
                            ),

                          if (!lock)
                            SizedBox(
                              width: med.size.width * 0.05,
                            ),

                          if (lock && !decoFinish)
                            SizedBox(
                              width: med.size.width * 0.096875,
                            ),

                          // 캡쳐
                          if (lock && !decoFinish)
                            SizedBox(
                              width: med.size.width * 0.046875,
                              height: med.size.height * 0.07109,
                              child: Ink(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border:
                                      Border.all(width: 1, color: Colors.black),
                                ),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(0),
                                  child: Icon(
                                    Icons.camera_alt_outlined,
                                    size: med.size.height * 0.05,
                                    color: Colors.black,
                                  ),
                                  onTap: () {
                                    setState(() {
                                      decoFinish = true;
                                    });
                                    _capture();
                                    Timer timer =
                                        new Timer(new Duration(seconds: 1), () {
                                      setState(() {
                                        decoFinish = false;
                                      });
                                    });
                                    print(timer);
                                  },
                                ),
                              ),
                            ),

                          if (lock && !decoFinish)
                            SizedBox(
                              width: med.size.width * 0.05,
                            ),

                          // 다시하기 버튼
                          if (!decoFinish)
                            SizedBox(
                              width: med.size.width * 0.046875,
                              height: med.size.height * 0.07109,
                              child: Ink(
                                decoration: BoxDecoration(
                                  color: Colors.redAccent,
                                  border:
                                      Border.all(width: 1, color: Colors.black),
                                ),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(0),
                                  child: Icon(
                                    Icons.restart_alt,
                                    size: med.size.height * 0.05,
                                    color: Colors.black,
                                  ),
                                  onTap: () {
                                    FlutterDialog();
                                  },
                                ),
                              ),
                            ),
                        ],
                      ),
                      SizedBox(
                        height: med.size.height * 0.2,
                      ),
                      Row(
                        children: <Widget>[
                          if (!lock)
                            SizedBox(
                              width: med.size.width * 0.05,
                            ),

                          // 아래 검은색 버튼
                          if (!lock)
                            SizedBox(
                              width: med.size.width * 0.046875,
                              height: med.size.height * 0.07109,
                              child: Ink(
                                decoration: BoxDecoration(
                                  color: Colors.black,
                                  border:
                                      Border.all(width: 1, color: Colors.black),
                                ),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(0),
                                  onTap: () {
                                    chooseColor = 1;
                                  },
                                ),
                              ),
                            ),

                          if (!lock)
                            SizedBox(
                              width: med.size.width * 0.02,
                            ),

                          // 아래 X 버튼
                          if (!lock)
                            SizedBox(
                              width: med.size.width * 0.046875,
                              height: med.size.height * 0.07109,
                              child: Ink(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border:
                                      Border.all(width: 1, color: Colors.black),
                                ),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(0),
                                  child: Icon(
                                    Icons.clear,
                                    size: med.size.height * 0.05,
                                    color: Colors.black,
                                  ),
                                  onTap: () {
                                    chooseColor = 2;
                                  },
                                ),
                              ),
                            ),

                          if (!lock)
                            SizedBox(
                              width: med.size.width * 0.02,
                            ),

                          // 아래 하얀색 버튼
                          if (!lock)
                            SizedBox(
                              width: med.size.width * 0.046875,
                              height: med.size.height * 0.07109,
                              child: Ink(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border:
                                      Border.all(width: 1, color: Colors.black),
                                ),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(0),
                                  onTap: () {
                                    chooseColor = 0;
                                  },
                                ),
                              ),
                            ),

                          if (lock && !decoFinish)
                            SizedBox(
                              width: med.size.width * 0.05,
                            ),

                          // 아래 검은색 버튼
                          if (lock && !decoFinish)
                            SizedBox(
                              width: med.size.width * 0.046875,
                              height: med.size.height * 0.07109,
                              child: Ink(
                                decoration: BoxDecoration(
                                  color: Colors.black,
                                ),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(0),
                                  onTap: () {
                                    finishColor = 0;
                                    print(finishColor);
                                  },
                                ),
                              ),
                            ),

                          if (lock && !decoFinish)
                            SizedBox(
                              width: med.size.width * 0.02,
                            ),

                          // 파란색 버튼
                          if (lock && !decoFinish)
                            SizedBox(
                              width: med.size.width * 0.046875,
                              height: med.size.height * 0.07109,
                              child: Ink(
                                decoration: BoxDecoration(
                                  color: Colors.blue,
                                ),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(0),
                                  onTap: () {
                                    finishColor = 1;
                                  },
                                ),
                              ),
                            ),

                          if (lock && !decoFinish)
                            SizedBox(
                              width: med.size.width * 0.02,
                            ),

                          // 아래 노란색 버튼
                          if (lock && !decoFinish)
                            SizedBox(
                              width: med.size.width * 0.046875,
                              height: med.size.height * 0.07109,
                              child: Ink(
                                decoration: BoxDecoration(
                                  color: Colors.yellow,
                                ),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(0),
                                  onTap: () {
                                    finishColor = 2;
                                  },
                                ),
                              ),
                            ),
                        ],
                      ),
                      if (lock && !decoFinish)
                        SizedBox(
                          height: med.size.height * 0.03,
                        ),
                      Row(
                        children: <Widget>[
                          if (lock && !decoFinish)
                            SizedBox(
                              width: med.size.width * 0.05,
                            ),

                          // 아래 핑크색 버튼
                          if (lock && !decoFinish)
                            SizedBox(
                              width: med.size.width * 0.046875,
                              height: med.size.height * 0.07109,
                              child: Ink(
                                decoration: BoxDecoration(
                                  color: Colors.pink,
                                ),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(0),
                                  onTap: () {
                                    finishColor = 3;
                                  },
                                ),
                              ),
                            ),

                          if (lock && !decoFinish)
                            SizedBox(
                              width: med.size.width * 0.02,
                            ),

                          // 초록색 버튼
                          if (lock && !decoFinish)
                            SizedBox(
                              width: med.size.width * 0.046875,
                              height: med.size.height * 0.07109,
                              child: Ink(
                                decoration: BoxDecoration(
                                  color: Colors.green,
                                ),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(0),
                                  onTap: () {
                                    finishColor = 4;
                                  },
                                ),
                              ),
                            ),

                          if (lock && !decoFinish)
                            SizedBox(
                              width: med.size.width * 0.02,
                            ),

                          // 아래 cyan 색 버튼
                          if (lock && !decoFinish)
                            SizedBox(
                              width: med.size.width * 0.046875,
                              height: med.size.height * 0.07109,
                              child: Ink(
                                decoration: BoxDecoration(
                                  color: Colors.cyan,
                                ),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(0),
                                  onTap: () {
                                    finishColor = 5;
                                  },
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void FlutterDialog() {
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
                "게임을 다시 시작하시겠습니까?",
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
                setState(() {
                  lock = false;
                  for (int i = 0; i < mapWidth * mapHeight; i++) {
                    col[i] = Colors.white;
                    userMap[i] = 0;
                    op[i] = 0.0;
                  }
                  for (int i = 0; i < mapHeight * leftMaxNum; i++)
                    leftOp[i] = 1.0;
                  for (int i = 0; i < mapWidth * topMaxNum; i++) topOp[i] = 1.0;

                  chooseColor = 1;
                  undoCount = 0;
                  undoColor.clear();
                  undoIndex.clear();
                  redoCount = 0;
                  redoColor.clear();
                  redoIndex.clear();
                });
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

void correctAnswer(BuildContext context) {
  showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.green[200],
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          content: new Text(
            "정답입니다.   :)",
            style: TextStyle(
                color: Colors.black,
                fontSize: MediaQuery.of(context).size.height * 0.05,
                fontWeight: FontWeight.bold),
          ),
        );
      });
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
  late int index;
}
