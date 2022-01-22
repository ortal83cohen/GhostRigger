import 'package:flutter/widgets.dart';

import '../hacking_device.dart';

abstract class DeviceModuleBase {
  bool isLoaded = false;
  final HackingDevice hackingDevice;
  Rect? area;

  DeviceModuleBase(this.hackingDevice);

  @mustCallSuper
  void render(Canvas canvas) {
    if (!isLoaded) {
      print("${this.toString()} not Loaded");
    }
    // assert(isLoaded);
  }

  void update(double t);

  @mustCallSuper
  Future<void> load() async {
    isLoaded = true;
  }

  void onTapDown(double dX, double dY) {}

  void onTapUp(double dX, double dY) {}

  void onTap() {}

  void onTapCancel() {}

  void onDragUpdate(double dX, double dY) {}

  void onDragEnd(Velocity velocity) {}

  void onDragCancel() {}
}
