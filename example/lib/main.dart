import 'dart:ui' as ui;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:progressive_blur/progressive_blur.dart';

Future<void> main() async {
  await ProgressiveBlur.precache();
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

  ui.Image _createBlurTexture() {
    final recorder = ui.PictureRecorder();
    final canvas = ui.Canvas(recorder);

    final gradient =
        ui.Gradient.linear(const Offset(0, 0), const Offset(0, 1000), <Color>[
      Colors.black,
      Colors.white,
    ], [
      _startStop,
      _endStop,
    ]);

    final paint = ui.Paint()..shader = gradient;
    canvas.drawRect(Offset.zero & const Size(1000, 1000), paint);

    final picture = recorder.endRecording();
    final image = picture.toImageSync(1000, 1000);

    return image;
  }

  @override
  Widget build(BuildContext context) {
    final child = Image.network(
      'https://images.pexels.com/photos/147411/italy-mountains-dawn-daybreak-147411.jpeg?cs=srgb&dl=pexels-pixabay-147411.jpg&fm=jpg',
      width: 600,
      height: 600,
      fit: BoxFit.cover,
    );

    // final child = AnimatedChildWidget();

    return MaterialApp(
      theme: ThemeData.from(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.purple,
          brightness: Brightness.dark,
        ),
      ),
      home: Scaffold(
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
                      height: 600.0,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.white, Colors.black],
                          stops: [_startStop, _endStop],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 648.0,
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
                    const SizedBox(width: 64.0),
                    ProgressiveBlur(
                      blurTexture: _createBlurTexture(),
                      sigma: _sigma,
                      child: child,
                    ),
                    const SizedBox(width: 32.0),
                    NaiveProgressiveBlur(
                      sigma: _sigma,
                      startStop: _startStop,
                      endStop: _endStop,
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

class NaiveProgressiveBlur extends StatelessWidget {
  const NaiveProgressiveBlur({
    super.key,
    required this.sigma,
    required this.startStop,
    required this.endStop,
    required this.child,
  });

  final double sigma;
  final double startStop;
  final double endStop;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: Stack(
        clipBehavior: Clip.antiAlias,
        fit: StackFit.passthrough,
        alignment: Alignment.bottomCenter,
        children: <Widget>[
          child,
          ImageFiltered(
            imageFilter: ImageFilter.blur(
              sigmaX: sigma,
              sigmaY: sigma,
            ),
            child: ShaderMask(
              shaderCallback: (rect) {
                return LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black, Colors.black.withOpacity(0)],
                  stops: [startStop, endStop],
                ).createShader(rect);
              },
              blendMode: BlendMode.dstOut,
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}

class AnimatedChildWidget extends StatefulWidget {
  const AnimatedChildWidget({super.key});

  @override
  State<AnimatedChildWidget> createState() => _AnimatedChildWidgetState();
}

class _AnimatedChildWidgetState extends State<AnimatedChildWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: 240.0,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Transform.scale(
            scale: 1 + _animation.value * 0.5,
            child: child,
          );
        },
        child: const Icon(
          Icons.favorite,
          size: 160.0,
          color: Colors.red,
        ),
      ),
    );
  }
}
