import 'dart:ui';

import 'package:flame/components.dart';

import '../../hacking_device.dart';
import 'button_base.dart';

class ButtonDone extends ButtonBase {
  ButtonDone(HackingDevice hackingDevice, Function? onPressed) : super(hackingDevice, onPressed as void Function()?);

  @override
  Future<void> load() async {
    buttonSprite = await Sprite.load('button_done.png');
    buttonPressedSprite = await Sprite.load('button_done_pressed.png');
    super.load();
  }

  @override
  Rect getArea() {
    var width = hackingDevice.gameWidth! * 0.089;
    var height = hackingDevice.gameHeight * 0.102;
    var offsetX = hackingDevice.gameWidth! * 0.043;
    var offsetY = hackingDevice.gameHeight * 0.483;
    return Rect.fromLTWH(offsetX, offsetY, width, height);
  }

  @override
  void setAlphaFromStatus() {
    var puzzle = hackingDevice.puzzle;
    paint!.color = Color.fromRGBO(
        0,
        0,
        0,
        puzzle.simulationFinished && !hackingDevice.isShowingInfo! && puzzle.goal == puzzle.output && enabled!
            ? 1.0
            : 0.0);
  }

  @override
  void onPressed() {
    hackingDevice.setUpNextPuzzle();
  }
}
