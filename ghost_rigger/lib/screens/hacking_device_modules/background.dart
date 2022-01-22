import 'dart:ui';

import 'package:flame/sprite.dart';

import '../hacking_device.dart';
import 'device_module_base.dart';

class Background extends DeviceModuleBase {
  late Sprite mainSprite;
  late Sprite leftSprite;
  late Sprite rightSprite;

  Background(HackingDevice hackingDevice) : super(hackingDevice);

  @override
  Future<void> load() async {
    mainSprite = await Sprite.load('main.png');
    leftSprite = await Sprite.load('left.png');
    rightSprite = await Sprite.load('right.png');
    super.load();
  }

  @override
  void render(Canvas canvas) {
    mainSprite.renderRect(canvas, Rect.fromLTWH(0, 0, hackingDevice.gameWidth, hackingDevice.gameHeight));

    var leftWidth = hackingDevice.gameHeight * 0.363;
    leftSprite.renderRect(canvas, Rect.fromLTWH(1 - leftWidth, 0, leftWidth, hackingDevice.gameHeight));

    var rightWidth = hackingDevice.gameHeight * 0.383;
    rightSprite.renderRect(canvas, Rect.fromLTWH(hackingDevice.gameWidth - 1, 0, rightWidth, hackingDevice.gameHeight));
    super.render(canvas);
  }

  @override
  void update(double t) {
    // Nothing to update here
  }
}