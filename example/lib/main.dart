import 'dart:convert';
import 'dart:ui' as ui;

import 'package:example/albums.dart';
import 'package:figma_squircle/figma_squircle.dart';
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
      debugShowCheckedModeBanner: false,
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
  final _albums = <(String, String, String, String)>[];

  @override
  void initState() {
    super.initState();
    _loadAlbums();
  }

  void _loadAlbums() {
    final json = jsonDecode(data) as List<dynamic>;
    for (final album in json) {
      final albumMap = album as Map<String, dynamic>;
      _albums.add((
        albumMap['image'] as String,
        albumMap['url'] as String,
        albumMap['name'] as String,
        albumMap['artist'] as String,
      ));
    }
  }

  ui.Image _progBlurTexture() {
    final gradient = ui.Gradient.radial(
      const Offset(1000, 1000),
      750,
      [Colors.white, Colors.black],
    );

    final size = Size.square(2000.0);

    final paint = Paint()..shader = gradient;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    canvas.drawRect(Offset.zero & size, paint);
    return recorder
        .endRecording()
        .toImageSync(size.width.toInt(), size.height.toInt());
  }

  @override
  Widget build(BuildContext context) {
    final cupertinoTheme = CupertinoTheme.of(context);

    return Scaffold(
      backgroundColor: Color(0xFF0D1116),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            const minItemExtent = 192.0;
            final width = constraints.maxWidth;
            final crossAxisCount = (width / minItemExtent).floor();

            return Stack(
              children: [
                ProgressiveBlurWidget.custom(
                  blurTexture: _progBlurTexture(),
                  sigma: 64.0,
                  child: Stack(
                    children: [
                      GridView.builder(
                        clipBehavior: Clip.none,
                        padding: const EdgeInsets.all(192.0),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          crossAxisSpacing: 16.0,
                          mainAxisSpacing: 16.0,
                          childAspectRatio: 1.0,
                        ),
                        itemCount: 45,
                        itemBuilder: (context, index) {
                          final album = _albums.skip(0).elementAt(index);
                          return _AlbumCard(
                            imageUrl: album.$1,
                            redirectUrl: album.$2,
                            title: album.$3,
                            artist: album.$4,
                          );
                        },
                      ),
                      Center(
                        child: Transform.scale(
                          scaleX: 2.0,
                          child: Container(
                            width: 400.0,
                            height: 400.0,
                            decoration: BoxDecoration(
                              gradient: RadialGradient(
                                center: Alignment.center,
                                colors: [
                                  Color(0xFF0D1116),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const FlutterLogo(size: 96.0),
                      const SizedBox(width: 16.0),
                      Text(
                        'progressive_blur',
                        style: cupertinoTheme.textTheme.navLargeTitleTextStyle
                            .copyWith(
                          color: Colors.white,
                          fontSize: 64.0,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _AlbumCard extends StatelessWidget {
  const _AlbumCard({
    super.key,
    required this.imageUrl,
    required this.redirectUrl,
    required this.title,
    required this.artist,
  });

  final String imageUrl;
  final String redirectUrl;
  final String title;
  final String artist;

  @override
  Widget build(BuildContext context) {
    final child = AspectRatio(
      aspectRatio: 1.0,
      child: Image.network(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, _, __) => Container(color: Colors.black),
      ),
    );

    final cupertinoTheme = CupertinoTheme.of(context);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Opacity(
          opacity: 0.135,
          child: Transform.scale(
            scale: 2.0,
            child: ImageFiltered(
              imageFilter: ui.ImageFilter.blur(
                sigmaX: 32.0,
                sigmaY: 32.0,
                tileMode: TileMode.decal,
              ),
              child: child,
            ),
          ),
        ),
        ClipSmoothRect(
          radius: SmoothBorderRadius(
            cornerRadius: 32,
            cornerSmoothing: 0.6,
          ),
          child: ProgressiveBlurWidget(
            linearGradientBlur: const LinearGradientBlur(
              values: [0, 1],
              stops: [0.5, 0.8],
              start: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            sigma: 24.0,
            blurTextureDimensions: 128,
            child: DecoratedBox(
              position: DecorationPosition.foreground,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.center,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black38,
                  ],
                ),
              ),
              child: child,
            ),
          ),
        ),
        Positioned(
          left: 16.0,
          right: 16.0,
          bottom: 16.0,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: cupertinoTheme.textTheme.navLargeTitleTextStyle.copyWith(
                  color: Colors.white,
                  fontSize: 20.0,
                ),
              ),
              Text(
                artist,
                style: cupertinoTheme.textTheme.textStyle.copyWith(
                  color: Colors.white38,
                  fontSize: 14.0,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
