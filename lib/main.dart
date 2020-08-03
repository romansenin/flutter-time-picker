import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:review/ArcChooser.dart';

void main() {
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitDown,
    DeviceOrientation.portraitUp,
  ]);
  runApp(new MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      theme: new ThemeData(
        primarySwatch: Colors.red,
      ),
      debugShowCheckedModeBanner: false,
      home: new Scaffold(
        backgroundColor: Colors.blue,
        body: new TimePicker(),
      ),
    );
  }
}

class TimePicker extends StatefulWidget {
  TimePicker({Key key}) : super(key: key);

  @override
  _TimePickerState createState() => new _TimePickerState();
}

class _TimePickerState extends State<TimePicker> with TickerProviderStateMixin {
  final PageController pageControl = new PageController(
    initialPage: 2,
    keepPage: false,
    viewportFraction: 0.2,
  );

  List<String> hours = List<String>();
  List<String> minutes = List<String>();
  List<String> periods = List<String>();

  int slideValue = 200;
  int lastAnimPosition = 2;

  AnimationController animation;

  List<ArcItem> arcItems = List<ArcItem>();

  ArcItem badArcItem;
  ArcItem ughArcItem;
  ArcItem okArcItem;
  ArcItem goodArcItem;

  Color startColor;
  Color endColor;

  @override
  void initState() {
    super.initState();

    for (var i = 1; i <= 12; i++) {
      hours.add("$i");
    }

    for (var i = 1; i <= 59; i++) {
      minutes.add("$i");
    }

    periods.add("AM");
    periods.add("PM");

    badArcItem = ArcItem("BAD", [Color(0xFFfe0944), Color(0xFFfeae96)], 0.0);
    ughArcItem = ArcItem("UGH", [Color(0xFFF9D976), Color(0xfff39f86)], 0.0);
    okArcItem = ArcItem("OK", [Color(0xFF21e1fa), Color(0xff3bb8fd)], 0.0);
    goodArcItem = ArcItem("GOOD", [Color(0xFF3ee98a), Color(0xFF41f7c7)], 0.0);

    arcItems.add(badArcItem);
    arcItems.add(ughArcItem);
    arcItems.add(okArcItem);
    arcItems.add(goodArcItem);

    startColor = Color(0xFF21e1fa);
    endColor = Color(0xff3bb8fd);

    animation = new AnimationController(
      value: 0.0,
      lowerBound: 0.0,
      upperBound: 400.0,
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..addListener(() {
        setState(() {
          slideValue = animation.value.toInt();

          double ratio;

          if (slideValue <= 100) {
            ratio = animation.value / 100;
            startColor =
                Color.lerp(badArcItem.colors[0], ughArcItem.colors[0], ratio);
            endColor =
                Color.lerp(badArcItem.colors[1], ughArcItem.colors[1], ratio);
          } else if (slideValue <= 200) {
            ratio = (animation.value - 100) / 100;
            startColor =
                Color.lerp(ughArcItem.colors[0], okArcItem.colors[0], ratio);
            endColor =
                Color.lerp(ughArcItem.colors[1], okArcItem.colors[1], ratio);
          } else if (slideValue <= 300) {
            ratio = (animation.value - 200) / 100;
            startColor =
                Color.lerp(okArcItem.colors[0], goodArcItem.colors[0], ratio);
            endColor =
                Color.lerp(okArcItem.colors[1], goodArcItem.colors[1], ratio);
          } else if (slideValue <= 400) {
            ratio = (animation.value - 300) / 100;
            startColor =
                Color.lerp(goodArcItem.colors[0], badArcItem.colors[0], ratio);
            endColor =
                Color.lerp(goodArcItem.colors[1], badArcItem.colors[1], ratio);
          }
        });
      });

    animation.animateTo(slideValue.toDouble());
  }

  @override
  Widget build(BuildContext context) {
    var textStyle = new TextStyle(
        color: Colors.white, fontSize: 24.00, fontWeight: FontWeight.bold);

    return Container(
      margin: MediaQuery.of(context).padding,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Stack(
              alignment: AlignmentDirectional.bottomCenter,
              children: <Widget>[
                ArcChooser(hours)
                  ..arcSelectedCallback = (int pos, ArcItem item) {
                    int animPosition = pos - 2;
                    if (animPosition > 3) {
                      animPosition = animPosition - 4;
                    }

                    if (animPosition < 0) {
                      animPosition = 4 + animPosition;
                    }

                    if (lastAnimPosition == 3 && animPosition == 0) {
                      animation.animateTo(4 * 100.0);
                    } else if (lastAnimPosition == 0 && animPosition == 3) {
                      animation.forward(from: 4 * 100.0);
                      animation.animateTo(animPosition * 100.0);
                    } else if (lastAnimPosition == 0 && animPosition == 1) {
                      animation.forward(from: 0.0);
                      animation.animateTo(animPosition * 100.0);
                    } else {
                      animation.animateTo(animPosition * 100.0);
                    }

                    lastAnimPosition = animPosition;
                  },
                Padding(
                  padding: const EdgeInsets.all(28.0),
                  child: Material(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25.0)),
                    elevation: 8.0,
                    child: GestureDetector(
                      onTap: () {
                        print("Clicked save button!");
                      },
                      child: Container(
                          width: 150.0,
                          height: 50.0,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                                colors: [Color(0xFFc9c9c9), Color(0xFFc9c9c9)]),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'SAVE',
                            style: textStyle,
                          )),
                    ),
                  ),
                )
              ]),
        ],
      ),
    );
  }
}
