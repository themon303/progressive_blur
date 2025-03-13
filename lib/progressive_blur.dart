import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_shaders/flutter_shaders.dart';

class ProgressiveBlur extends StatelessWidget {
  const ProgressiveBlur({
    super.key,
    required this.blurTexture,
    required this.sigma,
    required this.child,
  });

  static const _shaderAssetKey =
      'packages/progressive_blur/lib/shaders/progressive_blur.frag';

  static Future<void> precache() {
    return ShaderBuilder.precacheShader(_shaderAssetKey);
  }

  final ui.Image blurTexture;
  final double sigma;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final devicePixelRatio = MediaQuery.devicePixelRatioOf(context);

    return ShaderBuilder(
      (context, shader, child) {
        return AnimatedSampler(
          (image, size, canvas) {
            final scaledSize = size * devicePixelRatio;

            // First do X-axis pass
            final firstPassRecorder = ui.PictureRecorder();
            final firstPassCanvas = Canvas(firstPassRecorder);

            shader.setImageSampler(0, image); // child_texture
            shader.setImageSampler(1, blurTexture); // blur_texture

            shader.setFloat(0, scaledSize.width); // child_size.x
            shader.setFloat(1, scaledSize.height); // child_size.y
            shader.setFloat(2, sigma); // blur_sigma
            shader.setFloat(3, 0.0); // blur_direction

            final paint = Paint()..shader = shader;
            firstPassCanvas.drawRect(Offset.zero & scaledSize, paint);

            final firstPassPicture = firstPassRecorder.endRecording();
            final firstPassImage = firstPassPicture.toImageSync(
              scaledSize.width.toInt(),
              scaledSize.height.toInt(),
            );

            // // Then do Y-axis pass
            shader.setImageSampler(0, firstPassImage); // child_texture
            shader.setFloat(3, 1.0); // blur_direction

            canvas.scale(1 / devicePixelRatio);
            canvas.drawRect(Offset.zero & scaledSize, paint);

            firstPassPicture.dispose();
            firstPassImage.dispose();
          },
          enabled: true,
          child: child!,
        );
      },
      assetKey: _shaderAssetKey,
      child: child,
    );
  }
}
