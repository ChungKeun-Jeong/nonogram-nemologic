import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:home_learn/user_nemo.dart';
import 'package:sqflite/sqflite.dart' as sql;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final dir = await sql.getDatabasesPath();
  Hive.init(dir);
  await Hive.openBox('nemoData'); // DataBase 이름이 nemoData
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyAppHome(),
    ),
  );
}

class MyAppHome extends StatelessWidget {
  const MyAppHome({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 화면 가로 고정
    SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft]);

    // 상단바 없애기
    SystemChrome.setEnabledSystemUIOverlays([]);

    var box = Hive.box('nemoData');

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        // 배경 화면 추가
        decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage("images/AI_background.png"), fit: BoxFit.fill),
        ),
        child: Column(
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(
                top: MediaQuery.of(context).size.height * 0.313,
              ),
            ),
            Container(
              child: Card(
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.5,
                  height: MediaQuery.of(context).size.height * 0.5,
                  child: Ink(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: ExactAssetImage("images/AI_function_button.png"),
                        fit: BoxFit.fill,
                      ),
                    ),
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          // 화면 전환
                          context,
                          MaterialPageRoute(builder: (context) => UserNemo()),
                        );
                      },
                      // 번지는 효과 초록색, 투명도 0.3
                      splashColor: Colors.lightGreenAccent.withOpacity(0.3),
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
