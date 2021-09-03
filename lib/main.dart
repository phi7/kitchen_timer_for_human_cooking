import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final String title = "Kitchen Timer for human-cooking!";

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: title,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: CountDownTimer(title),
    );
  }
}

class CountDownTimer extends StatefulWidget {
  CountDownTimer(this.title);

  final String title;

  @override
  _CountDownTimerState createState() => _CountDownTimerState();
}

class _CountDownTimerState extends State<CountDownTimer>
    with TickerProviderStateMixin {
  //コントローラの設定
  late AnimationController controller;
  late AnimationController buttoncontroller;

  //画像の用意
  final images = <Image>[
    Image.asset(
      'image/spring.png',
      width: 250,
      height: 250,
      fit: BoxFit.contain,
    ),
    Image.asset(
      'image/spice.png',
      width: 250,
      height: 250,
      fit: BoxFit.contain,
    ),
    Image.asset(
      'image/knife.png',
      width: 250,
      height: 250,
      fit: BoxFit.contain,
    ),
    Image.asset(
      'image/meat.png',
      width: 250,
      height: 250,
      fit: BoxFit.contain,
    )
  ];

  //timeStringは引数を持たない関数？？getはよくわからんが、timeStringを変数のように扱って戻り値を代入している？？
  //isMinutesはDurationクラスのプロパティ。なんかdurationを分になおす。多分切れた秒は無視？
  //.toString()で文字列に変換？str()みたいなものか
  //AnimationControllerクラス型の変数を定義しており（上で。インスタス化は下のinitでされているっぽい）、
  //プロパティにDuration型のdurationを持つようである。
  String get timerString {
    Duration duration = controller.duration! * controller.value;
    return '${duration.inMinutes}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}';
  }

  //returnの後のimageにeroorが出たのでnulを回避するためになんか適当につっこんでおいた。いまいちNullSaftyわからん。
  Image get characterImage {
    Duration duration = controller.duration! * controller.value;
    Image? image;
    if (duration.inMinutes == 2 || duration.inMinutes == 3) {
      image = images[0];
    } else if (duration.inMinutes == 1) {
      image = images[1];
    } else if (duration.inMinutes == 0) {
      if (duration.inSeconds > 0) {
        image = images[2];
      } else {
        image = images[3];
      }
    }
    return image!;
  }

  @override
  void initState() {
    //vsncとdurationはコンストラクタ。ただ、自分でクラスを定義した場合は必ずすべてのコンストラクタの要求する
    //メンバ変数を用意しないといけない気がするのにこれは全部うめなくてもよい。
    //thisはこのクラスをインスタンス化したものっていう意味？
    //vsncはTickerProvider型の名前付き引数。requiredでnullは許されない。
    controller =
        AnimationController(vsync: this, duration: Duration(seconds: 180));
    buttoncontroller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 300));
    super.initState();
    controller.value = 1.0;
  }

  @override
  Widget build(BuildContext context) {
    var isPlaying = false;
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            AnimatedBuilder(
              animation: controller,
              builder: (BuildContext context, Widget? child) {
                return Text(
                  "$timerString",
                  //Theme,ThemeData,textStyle
                  style: Theme.of(context).textTheme.display4,
                );
              },
            ),
            InkWell(
              child: Container(
                width: 250,
                height: 250,
                child: AnimatedBuilder(
                  animation: controller,
                  builder: (BuildContext context, Widget? child) {
                    return characterImage;
                  },
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 30.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  InkWell(
                    child: Container(
                      padding: const EdgeInsets.all(25.0),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.blue,
                      ),
                      child: AnimatedIcon(
                        icon: AnimatedIcons.play_pause,
                        color: Colors.white,
                        size: 50.0,
                        progress: buttoncontroller,
                      ),
                    ),
                    onTap: () async {
                      if (!isPlaying) {
                        await buttoncontroller.forward();
                        isPlaying = true;
                      } else {
                        await buttoncontroller.reverse();
                        isPlaying = false;
                      }

                      if (controller.isAnimating) {
                        controller.stop(canceled: true);
                      } else {
                        controller.reverse(
                            from: controller.value == 0.0
                                ? 1.0
                                : controller.value);
                      }
                    },
                  ),
                  Container(
                    width: 100,
                    height: 100,
                    margin: EdgeInsets.only(left: 20.0),
                    child: InkWell(
                      child: Icon(
                        Icons.cached,
                        color: Colors.white,
                        size: 50.0,
                      ),
                      onTap: () {
                        controller.reset();
                      },
                    ),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
            ),
          ],
        )));
  }
}
