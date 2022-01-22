import 'dart:ui';

import 'package:flame/components.dart';

import '../../hacking_device.dart';
import 'button_base.dart';

class ButtonSkipLevel extends ButtonBase {
  ButtonSkipLevel(HackingDevice hackingDevice, Function? onPressed)
      : super(hackingDevice, onPressed as void Function()?);

  @override
  Future<void> load() async {
    buttonSprite = await Sprite.load('button_skip_level.png');
    buttonPressedSprite = await Sprite.load('button_skip_level_pressed.png');
    super.load();
  }

  @override
  Rect getArea() {
    var width = hackingDevice.gameWidth! * 0.25;
    var height = hackingDevice.gameWidth! * 0.062;
    var offsetX = hackingDevice.gameWidth! * 0.52;
    var offsetY = hackingDevice.gameHeight * 0.783;
    return Rect.fromLTWH(offsetX, offsetY, width, height);
  }

  @override
  void setAlphaFromStatus() {
    paint!.color = Color.fromRGBO(0, 0, 0, enabled! ? 1.0 : 0.0);
  }

  @override
  void update(double t) {
    enabled = hackingDevice.isShowingInfo;
  }

  @override
  void onPressed() async {
    while (!await hackingDevice.setUpNextPuzzle()) {}
  }
}
