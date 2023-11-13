import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_shaders/flutter_shaders.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData.dark(),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  late final AnimationController animationController;
  late final AnimationController animationController2;

  late final Animation<double> scaleAnimation;
  late final Animation<double> rotationAnimation;

  @override
  void initState() {
    super.initState();
    animationController = AnimationController.unbounded(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    animationController2 = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    final curv = CurvedAnimation(
      parent: animationController2,
      curve: Curves.easeInOut,
    );
    scaleAnimation = Tween(begin: 4.0, end: 1.0).animate(curv);
    rotationAnimation = Tween(begin: 0.485398, end: 0.0).animate(curv);

    Timer.periodic(const Duration(milliseconds: 60), (timer) {
      if (_isHover) {
        animationController.value = animationController.value + 0.5;
      } else {
        animationController.value = animationController.value + 0.3;
      }
    });
  }

  bool _isHover = false;

  void _changeButtonBackground(bool isHover) {
    setState(() {
      _isHover = isHover;
      if (_isHover) {
        animationController2.forward();
      } else {
        animationController2.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    const multiplier = 2.0;
    const width = 200.0 * multiplier;
    const height = 60.0 * multiplier;

    return Center(
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(8 * multiplier),
        ),
        clipBehavior: Clip.antiAlias,
        child: Material(
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              Positioned.fill(
                child: AnimatedBuilder(
                  animation: Listenable.merge(
                      [animationController, scaleAnimation, rotationAnimation]),
                  builder: (BuildContext context, Widget? child) {
                    final blur = Tween(begin: 8.0, end: 0.01)
                        .animate(animationController2);
                    return ImageFiltered(
                      imageFilter: ImageFilter.blur(
                        sigmaX: blur.value,
                        sigmaY: blur.value,
                      ),
                      child: Transform.scale(
                        scale: scaleAnimation.value,
                        origin: const Offset(0.5, 0.5),
                        alignment: Alignment.center,
                        child: Transform.rotate(
                          angle: rotationAnimation.value,
                          child: ShaderBuilder(
                            (context, shader, child) {
                              return AnimatedSampler(
                                (image, size, canvas) {
                                  final width0 = size.width;
                                  final height0 = size.height;
                                  // Set the values for resolution and iTime
                                  shader.setFloat(0, width0);
                                  shader.setFloat(1, height0);
                                  shader.setFloat(2, animationController.value);

                                  var center = Offset(width0 / 2, height0 / 2);

                                  canvas.drawRect(
                                    Rect.fromCenter(
                                      center: center,
                                      width: width0,
                                      height: height0,
                                    ),
                                    Paint()..shader = shader,
                                  );
                                },
                                child: const SizedBox(
                                  width: width,
                                  height: height,
                                ),
                              );
                            },
                            assetKey: 'shaders/star_field.frag',
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              // Button with hover effect
              Positioned.fill(
                child: InkWell(
                  onHover: (isHover) {
                    _changeButtonBackground(isHover);
                  },
                  onTap: () {},
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8 * multiplier),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2),
                        width: 2 * multiplier,
                        strokeAlign: BorderSide.strokeAlignInside,
                      ),
                    ),
                    width: width,
                    height: height,
                    child: Center(
                      child: Text(
                        'Galaxy button!',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20 * multiplier,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
