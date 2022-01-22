import 'dart:ui';

import 'package:flame/components.dart';

import '../../hacking_device.dart';
import 'button_base.dart';

class ButtonNextStep extends ButtonBase {
  ButtonNextStep(HackingDevice hackingDevice, Function? onPressed)
      : super(hackingDevice, onPressed as void Function()?);

  @override
  Future<void> load() async {
    buttonSprite = await Sprite.load('button_next_step.png');
    buttonPressedSprite = await Sprite.load('button_next_step_pressed.png');
    super.load();
  }

  @override
  Rect getArea() {
    var width = hackingDevice.gameWidth * 0.089;
    var height = hackingDevice.gameHeight * 0.125;
    var offsetX = hackingDevice.gameWidth * 0.240;
    var offsetY = hackingDevice.gameHeight * 0.038;
    return Rect.fromLTWH(offsetX, offsetY, width, height);
  }

  @override
  void onPressed() {
    hackingDevice.solveNextStep();
  }

  @override
  void update(double t) {
    enabled = !hackingDevice.isShowingInfo! && !hackingDevice.puzzle.simulationFinished;
  }
}
