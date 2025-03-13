import 'package:flutter/material.dart';
import 'package:progressive_blur/progressive_blur.dart';

Future<void> main() async {
  await ProgressiveBlurWidget.precache();
  runApp(const App());
}

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  var _sigma = 0.0;
  var _startStop = 0.0;
  var _endStop = 1.0;

  @override
  Widget build(BuildContext context) {
    const dimensions = 800.0;

    final child = Padding(
      padding: const EdgeInsets.all(128.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32.0),
        child: Image.network(
          'https://images.pexels.com/photos/147411/italy-mountains-dawn-daybreak-147411.jpeg?cs=srgb&dl=pexels-pixabay-147411.jpg&fm=jpg',
          width: dimensions,
          height: dimensions,
          fit: BoxFit.cover,
        ),
      ),
    );

    return MaterialApp(
      theme: ThemeData.from(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.purple,
          brightness: Brightness.dark,
        ),
      ),
      home: Scaffold(
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
                    const SizedBox(width: 32.0),
                    ProgressiveBlurWidget(
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
      ),
    );
  }
}
