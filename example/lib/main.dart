import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:progressive_blur/progressive_blur.dart';

Future<void> main() async {
  await ProgressiveBlurWidget.precache();
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.from(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.purple,
          brightness: Brightness.dark,
        ),
      ),
      home: const MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  var _sigma = 0.0;
  var _startStop = 0.0;
  var _endStop = 1.0;

  @override
  Widget build(BuildContext context) {
    const dimensions = 360.0;

    final child = Image.network(
      'https://f4.bcbits.com/img/a2879035121_10.jpg',
      width: dimensions,
      height: dimensions,
      fit: BoxFit.cover,
    );

    final cupertinoTheme = CupertinoTheme.of(context);

    return Scaffold(
      backgroundColor: const Color.fromRGBO(13, 17, 22, 1.0),
      appBar: AppBar(
        title: const Text('Example'),
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 24.0,
                    height: dimensions,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: const [Colors.white, Colors.black],
                        stops: [_startStop, _endStop],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: dimensions + 48.0,
                    child: RotatedBox(
                      quarterTurns: 1,
                      child: RangeSlider(
                        values: RangeValues(_startStop, _endStop),
                        min: 0,
                        max: 1,
                        onChanged: (values) {
                          _startStop = values.start;
                          _endStop = values.end;
                          setState(() {});
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 128.0),
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Opacity(
                        opacity: 0.175,
                        child: Transform.scale(
                          scale: 1.125,
                          child: ImageFiltered(
                            imageFilter: ImageFilter.blur(
                              sigmaX: 32.0,
                              sigmaY: 32.0,
                              tileMode: TileMode.decal,
                            ),
                            child: child,
                          ),
                        ),
                      ),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(32.0),
                        child: ProgressiveBlurWidget(
                          linearGradientBlur: LinearGradientBlur(
                            values: [0, 1],
                            stops: [_startStop, _endStop],
                            start: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                          sigma: _sigma,
                          blurTextureDimensions: 1024,
                          child: child,
                        ),
                      ),
                      Positioned(
                        left: 24.0,
                        right: 24.0,
                        bottom: 24.0,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Space Train',
                              style: cupertinoTheme
                                  .textTheme.navLargeTitleTextStyle
                                  .copyWith(
                                color: Colors.white,
                                fontSize: 32.0,
                              ),
                            ),
                            Text(
                              'Spiral Drive',
                              style: cupertinoTheme.textTheme.textStyle
                                  .copyWith(color: Colors.white38),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Slider(
            value: _sigma,
            min: 0,
            max: 128,
            onChanged: (value) {
              _sigma = value;
              setState(() {});
            },
          ),
        ],
      ),
    );
  }
}
