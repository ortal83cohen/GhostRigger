import 'dart:ui';

import 'package:flame/components.dart';

import '../../hacking_device.dart';
import 'button_base.dart';

class ButtonExit extends ButtonBase {
  ButtonExit(HackingDevice hackingDevice, Function onPressed) : super(hackingDevice, onPressed as void Function()?);

  @override
  Future<void> load() async {
    buttonSprite = await Sprite.load('button_exit.png');
    buttonPressedSprite = await Sprite.load('button_exit_pressed.png');
    super.load();
  }

  @override
  Rect getArea() {
    var width = hackingDevice.gameWidth! * 0.111;
    var height = hackingDevice.gameHeight * 0.125;
    var offsetX = hackingDevice.gameWidth! * 0.846;
    var offsetY = hackingDevice.gameHeight * 0.038;
    return Rect.fromLTWH(offsetX, offsetY, width, height);
  }
}
