import 'dart:ui';

import 'package:flame/sprite.dart';

import '../hacking_device.dart';
import 'device_module_base.dart';

class LightAnimation extends DeviceModuleBase {
  late List<Sprite> sprites;
  int animationIndex = 0;
  double accumulator = 0.0;

  LightAnimation(HackingDevice hackingDevice) : super(hackingDevice);

  @override
  Future<void> load() async {
    sprites = [
      await Sprite.load('empty_space_left_bottom_1.png'),
      await Sprite.load('empty_space_left_bottom_2.png'),
      await Sprite.load('empty_space_left_bottom_3.png'),
      await Sprite.load('empty_space_left_bottom_4.png'),
      await Sprite.load('empty_space_left_bottom_5.png'),
      await Sprite.load('empty_space_left_bottom_6.png'),
    ];
    super.load();
  }

  @override
  void render(Canvas canvas) {
    var width = hackingDevice.gameWidth * 0.089;
    var height = hackingDevice.gameHeight * 0.415;
    var offsetX = hackingDevice.gameWidth * 0.043;
    var offsetY = hackingDevice.gameHeight * 0.585;
    area = Rect.fromLTWH(offsetX, offsetY, width, height);
    sprites[animationIndex].renderRect(canvas, area!);
    super.render(canvas);
  }

  @override
  void update(double t) {
    if (hackingDevice.puzzle.simulationRunning || hackingDevice.isShowingInfo!) return;

    accumulator += t;
    if (accumulator > 0.15) {
      accumulator %= 0.15;
      if ((animationIndex + 1) < sprites.length)
        animationIndex++;
      else
        animationIndex = 0;
    }
  }
}