# nonogram-nemologic
Flutter 앱 개발 - 노노그램(네모로직)<br>
직접 게임을 만들고 수정할 수 있게 관리자 모드를 포함하고 있습니다.
<br><br>
## Flutter
구글에서 출시한 프레임워크로 Dart라는 언어를 사용합니다.

* 장점 : 동일한 코드로 iOS, 안드로이드, 웹 모두에서 사용할 수 있습니다.
* 단점 : 업데이트가 잦아 최신 버전에서는 현재 코드가 작동하지 않을 수도 있습니다.
    - 저의 코드는 2021년 12월 기준으로 작성되었습니다.
    - pubspec.yaml 파일에서 버전을 확인할 수 있습니다.
<br><br>

## Database (HIVE)
앱을 종료해도 게임에 대한 데이터를 유지하기 위해서 로컬 Database가 필요합니다.<br>
그래서 NoSQL 기반의 Database인 HIVE를 사용했습니다.
<br><br>

## 실행 화면 (관리자 모드)
![ezgif com-gif-maker](https://user-images.githubusercontent.com/107621795/194687211-969caba7-c18c-4834-a4e6-5e76f35bc73f.gif)
1. 비밀번호를 입력해서 관리자 모드에 들어간다.
2. 게임 만들기 버튼을 누른다.
3. 가로, 세로 크기를 입력한다.
4. 정답 모양을 화면에 그린다.
5. 이름을 입력 후에 저장한다.
6. 완성된 게임은 이름과 정답 모양을 수정할 수 있다.

<br><br>

## 실행 화면 (게임)
![ezgif com-gif-maker (1)](https://user-images.githubusercontent.com/107621795/194687216-fd41de69-c845-4088-9426-66c3ec5b0e03.gif)
1. 왼쪽과 위에 있는 숫자를 보고 정답 모양을 맞추는 것이 목표다.
2. undo, redo, reset 버튼을 사용할 수 있다.
3. 게임을 클리어 하면 카메라 버튼을 눌러서 결과 이미지를 저장할 수 있다.
