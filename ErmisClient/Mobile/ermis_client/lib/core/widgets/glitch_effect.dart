import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

final _random = Random();

MaterialAccentColor _getRandomColor() => [
      Colors.blueAccent,
      Colors.redAccent,
      Colors.greenAccent,
    ][_random.nextInt(3)];

class GlithEffect extends StatefulWidget {
  final Widget? child;

  final Duration? glitchDuration;
  final Duration? repeatInterval;

  const GlithEffect({
    super.key,
    this.child,
    this.glitchDuration,
    this.repeatInterval,
  });

  @override
  State<GlithEffect> createState() => _GlithEffectState();
}

class _GlithEffectState extends State<GlithEffect>
    with SingleTickerProviderStateMixin {
  GlitchController? _controller;
  late Timer _timer;

  @override
  void initState() {
    _controller = GlitchController(
      duration: widget.glitchDuration ?? const Duration(milliseconds: 400),
    );

    _timer = Timer.periodic(
      widget.repeatInterval ?? const Duration(seconds: 3),
      (_) {
        _controller!
          ..reset()
          ..forward();
      },
    );
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _timer.cancel();
    _controller!.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
        animation: _controller!,
        builder: (_, __) {
          var color = _getRandomColor().withValues(alpha: 0.5);
          if (!_controller!.isAnimating) {
            return widget.child!;
          }
          return Stack(
            children: [
              if (_random.nextBool()) _clipedChild,
              Transform.translate(
                offset: randomOffset,
                child: ShaderMask(
                  shaderCallback: (Rect bounds) {
                    return LinearGradient(
                      colors: <Color>[
                        color,
                        color,
                      ],
                    ).createShader(bounds);
                  },
                  blendMode: BlendMode.srcATop,
                  child: _clipedChild,
                ),
              ),
            ],
          );
        });
  }

  Offset get randomOffset => Offset(
        (_random.nextInt(10) - 5).toDouble(),
        (_random.nextInt(10) - 5).toDouble(),
      );
  Widget get _clipedChild => ClipPath(
        clipper: GlitchClipper(),
        child: widget.child,
      );
}

class GlitchClipper extends CustomClipper<Path> {
  final deltaMax = 15;
  final min = 3;

  @override
  getClip(Size size) {
    var path = Path();
    var y = randomStep;
    while (y < size.height) {
      var yRandom = randomStep;
      var x = randomStep;

      while (x < size.width) {
        var xRandom = randomStep;
        path.addRect(
          Rect.fromPoints(
            Offset(x, y.toDouble()),
            Offset(x + xRandom, y + yRandom),
          ),
        );
        x += randomStep * 2;
      }
      y += yRandom;
    }

    path.close();
    return path;
  }

  double get randomStep => min + _random.nextInt(deltaMax).toDouble();

  @override
  bool shouldReclip(covariant CustomClipper oldClipper) => true;
}

class GlitchController extends Animation<int?>
    with
        AnimationEagerListenerMixin,
        AnimationLocalListenersMixin,
        AnimationLocalStatusListenersMixin {
  GlitchController({this.duration});

  Duration? duration;
  List<Timer> _timers = [];

  @override
  bool isAnimating = false;

  late AnimationStatus _status;
  int? _value;

  void forward() {
    isAnimating = true;
    var oneStep = (duration!.inMicroseconds / 3).round();
    _status = AnimationStatus.forward;
    _timers = [
      Timer(
        Duration(microseconds: oneStep),
        () => setValue(1),
      ),
      Timer(
        Duration(microseconds: oneStep * 2),
        () => setValue(2),
      ),
      Timer(
        Duration(microseconds: oneStep * 3),
        () => setValue(3),
      ),
      Timer(
        Duration(microseconds: oneStep * 4),
        () {
          _status = AnimationStatus.completed;
          isAnimating = false;
          notifyListeners();
        },
      ),
    ];
  }

  void setValue(int value) {
    _value = value;
    notifyListeners();
  }

  void reset() {
    _status = AnimationStatus.dismissed;
    _value = 0;
  }

  @override
  void dispose() {
    for (var timer in _timers) {
      timer.cancel();
    }
    super.dispose();
  }

  @override
  AnimationStatus get status => _status;

  @override
  int? get value => _value;
}
