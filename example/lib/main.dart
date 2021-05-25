import 'package:flutter/material.dart';
import 'package:flutter_pudding/flutter_pudding.dart';

typedef TestPuddingTypeClickCallback = void Function(PuddingType type);

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Pudding',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'flutter_pudding 效果测试'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              _initItemTypeWidget(PuddingType.TOAST, (puddingType) {
                Pudding.create(context, type: puddingType)
                  ..setContent("关公面前耍大刀,蠢~")
                  ..setBackgroundColor(Colors.green)
                  ..setElevation(PuddingElevation(elevation: 0))
                  ..show();
              }),
              _initItemTypeWidget(PuddingType.DEFAULT, (puddingType) {
                Pudding.create(context, type: puddingType)
                  ..setContent(
                      "君不见黄河之水天上来，奔流到海不复回。君不见高堂明镜悲白发，朝如青丝暮成雪。人生得意须尽欢，莫使金樽空对月。天生我材必有用，千金散尽还复来。烹羊宰牛且为乐，会须一饮三百杯。岑夫子，丹丘生，将进酒，杯莫停。与君歌一曲，请君为我倾耳听。钟鼓馔玉不足贵，但愿长醉不复醒。古来圣贤皆寂寞，惟有饮者留其名。陈王昔时宴平乐，斗酒十千恣欢谑。主人何为言少钱，径须沽取对君酌。五花马，千金裘，呼儿将出换美酒，与尔同销万古愁。")
                  ..setBackgroundColor(Colors.redAccent)
                  //PuddingType.DEFAULT的最大行数必须 <=3
                  ..setMaxLines(3)
                  ..show();
              })
            ],
          ),
        ));
  }

  Widget _initItemTypeWidget(
    PuddingType type,
    TestPuddingTypeClickCallback onClick,
  ) {
    return TextButton(
        style: ButtonStyle(
            //水波纹扩散颜色
            overlayColor: MaterialStateProperty.all(Colors.black12),
            foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
            backgroundColor: MaterialStateProperty.all<Color>(Colors.blue)),
        onPressed: () => onClick(type),
        child: Text("测试类型：${type.toString()}"));
  }
}
