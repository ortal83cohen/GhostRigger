import 'dart:ui';

import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:ghost_rigger/screens/hacking_device_modules/buttons/button_skip_level.dart';
import 'package:ghost_rigger/screens/hacking_device_modules/doors_animation.dart';

import 'hacking_device_modules/background.dart';
import 'hacking_device_modules/board.dart';
import 'hacking_device_modules/buttons/button_arrow_down.dart';
import 'hacking_device_modules/buttons/button_arrow_up.dart';
import 'hacking_device_modules/buttons/button_done.dart';
import 'hacking_device_modules/buttons/button_exit.dart';
import 'hacking_device_modules/buttons/button_info.dart';
import 'hacking_device_modules/buttons/button_next_step.dart';
import 'hacking_device_modules/buttons/button_ok.dart';
import 'hacking_device_modules/buttons/button_restart.dart';
import 'hacking_device_modules/buttons/button_run.dart';
import 'hacking_device_modules/device_module_base.dart';
import 'hacking_device_modules/display_goal.dart';
import 'hacking_device_modules/display_output.dart';
import 'hacking_device_modules/display_status.dart';
import 'hacking_device_modules/info.dart';
import 'hacking_device_modules/light_animation.dart';
import 'hacking_device_modules/piece.dart';
import 'hacking_device_modules/piece_selector.dart';
import 'models/level_model.dart';
import 'models/piece_model.dart';
import 'models/puzzle_model.dart';

class HackingDevice extends FlameGame with MultiTouchTapDetector, MultiTouchDragDetector {
  late Size screenSize;
  late double gameHeight;
  late double gameWidth;
  late Board board;
  late PieceSelector pieceSelector;
  late Info info;
  late List<DeviceModuleBase?> deviceModules;

  LevelModel level;
  late PuzzleModel puzzle;
  int puzzleNumber = 0;
  int? numberOfPuzzles;
  bool? isShowingInfo;

  void Function() _onExit;
  void Function() _onCompleted;

  HackingDevice(this.level, this._onExit, this._onCompleted) {
    puzzleNumber = 0;
    numberOfPuzzles = level.puzzles.length;
  }

  @override
  Future<void> onLoad() async {
    screenSize = size.toSize();
    gameWidth = 0;
    await setUpNextPuzzle();
    super.onLoad();
  }

  Future<bool> setUpNextPuzzle() async {
    if (level.puzzles.isEmpty) {
      _onCompleted.call();
      return true;
    }

    puzzleNumber++;

    puzzle = level.puzzles.first;
    level.puzzles.remove(puzzle);
    puzzle.clearSolution();

    board = Board(this);
    pieceSelector = PieceSelector(this);
    info = Info(this);
    await info.load();
    deviceModules = [
      Background(this),
      DisplayStatus(this),
      ButtonInfo(this, null),
      ButtonRun(this, null),
      ButtonNextStep(this, null),
      ButtonRestart(this, null),
      ButtonDone(this, null),
      ButtonArrowUp(this, null),
      ButtonArrowDown(this, null),
      ButtonExit(this, _onExit),
      DisplayGoal(this),
      DisplayOutput(this),
      LightAnimation(this),
      board,
      pieceSelector,
    ];
    await board.load();
    puzzle.validCellPositions.forEach((validPosition) {
      board.validCells[validPosition[0]][validPosition[1]] = true;
    });

    var piecesForPieceSelector =
        puzzle.pieces.where((piece) => piece.positionInBoardColumn == -1).map((pieceModel) async {
      Piece piece = Piece(this, pieceModel);
      await piece.load();
      return piece;
    }).toList();
    piecesForPieceSelector.forEach((piece) async {
      Piece piec = await piece;
      pieceSelector.pieces.add(piec);
      piec.isInPieceSelector = true;
      deviceModules.add(piec);
    });

    var piecesForBoard = puzzle.pieces
        .where((pieceModel) => pieceModel.positionInBoardRow != -1)
        .map((pieceModel) => Piece(this, pieceModel))
        .toList();
    piecesForBoard.forEach((piece) {
      board.pieces[piece.positionInBoardRow!][piece.positionInBoardColumn!] = piece;
      piece.isInPieceSelector = false;
      deviceModules.add(piece);
    });

    deviceModules.add(info);
    deviceModules.add(ButtonOK(this, null));
    deviceModules.add(ButtonSkipLevel(this, null));

    if (puzzleNumber == 1) {
      showInfo();
      deviceModules.add(DoorsAnimation(this));
    } else
      hideInfo();

    deviceModules.forEach((element) async {
      await element?.load();
    });
    return false;
  }

  @override
  void render(Canvas canvas) {
    preRender(canvas);
    deviceModules.forEach((module) {
      module!.render(canvas);
    });
    postRender(canvas);
    super.render(canvas);
  }

  void preRender(Canvas canvas) {
    gameHeight = screenSize.height;
    gameWidth = gameHeight * 1.753;
    var mainOffsetX = (screenSize.width - gameWidth) / 2;
    canvas.save();
    canvas.translate(mainOffsetX, 0);
  }

  void postRender(Canvas canvas) {
    canvas.restore();
  }

  @override
  void update(double t) {
    deviceModules.forEach((module) {
      module!.update(t);
    });
    super.update(t);
  }

  @override
  void onTap(int pointerId) {
    print('onTap');

    deviceModules.forEach((module) {
      module!.onTap();
    });
  }

  @override
  void onTapCancel(int pointerId) {
    print('onTapCancel');

    deviceModules.forEach((module) {
      module!.onTapCancel();
    });
  }

  @override
  void onGameResize(Vector2 canvasSize) {
    screenSize = canvasSize.toSize();
      super.onGameResize(canvasSize);
  }
  void clearPuzzleSolution() {
    puzzle.clearSolution();
    board.pieces.forEach((piecesRow) {
      piecesRow.forEach((piece) {
        piece?.isLit = false;
      });
    });
  }

  void solvePuzzle() {
    var pieceModelRows =
        board.pieces.map((piecesRow) => piecesRow.map((piece) => _fromPieceToPieceModel(piece)).toList());
    puzzle.solvePuzzle(pieceModelRows.toList());
    puzzle.visitedPieces.forEach((visitedPiece) {
      board.pieces[visitedPiece.positionInBoardRow!][visitedPiece.positionInBoardColumn!]!.isLit = true;
    });
  }

  void solveNextStep() {
    var pieceModelRows =
        board.pieces.map((piecesRow) => piecesRow.map((piece) => _fromPieceToPieceModel(piece)).toList());
    puzzle.solveNextStep(pieceModelRows.toList());
    puzzle.visitedPieces.forEach((visitedPiece) {
      board.pieces[visitedPiece.positionInBoardRow!][visitedPiece.positionInBoardColumn!]!.isLit = true;
    });
  }

  void showInfo() {
    isShowingInfo = true;
    info.title = level.infoTitle;
    info.text = level.infoDescription;
    info.show = true;
  }

  void hideInfo() {
    isShowingInfo = false;
    info.show = false;
  }

  PieceModel? _fromPieceToPieceModel(Piece? piece) {
    return piece != null
        ? PieceModel(
            positionInBoardColumn: piece.positionInBoardColumn,
            positionInBoardRow: piece.positionInBoardRow,
            arithmeticValue: piece.arithmeticValue,
            arithmeticOperation: piece.arithmeticOperation,
            hastTopCable: piece.hastTopCable,
            hastRightCable: piece.hastRightCable,
            hastBottomCable: piece.hastBottomCable,
            hastLeftCable: piece.hastLeftCable,
            isInOrOut: piece.isInOrOut)
        : null;
  }

  @override
  void onMount() {

  }

  @override
  void onTapDown(int pointerId, TapDownInfo info) {
      print('onTapDown: ${info.raw.globalPosition}');

      var mainOffsetX = (screenSize.width - gameWidth) / 2;
      var tapCorrectedX = info.raw.globalPosition.dx - mainOffsetX;
      var tapCorrectedY = info.raw.globalPosition.dy;
      deviceModules.forEach((module) {
        module?.onTapDown(tapCorrectedX, tapCorrectedY);
      });
  }

  @override
  void onTapUp(int pointerId, TapUpInfo info) {
      print('onTapUp: ${info.raw.globalPosition}');

      var mainOffsetX = (screenSize.width - gameWidth) / 2;
      var tapCorrectedX = info.raw.globalPosition.dx - mainOffsetX;
      var tapCorrectedY = info.raw.globalPosition.dy;
      deviceModules.forEach((module) {
        module?.onTapUp(tapCorrectedX, tapCorrectedY);
      });
  }

  @override
  void onLongTapDown(int pointerId, TapDownInfo info) {

  }

  @override
  void onDragStart(int pointerId, DragStartInfo info) {

  }

  @override
  void onDragUpdate(int pointerId, DragUpdateInfo info) {
    print('_onDragUpdated: ${info.raw.globalPosition}');

    var mainOffsetX = (screenSize.width - gameWidth) / 2;
    var tapCorrectedX = info.raw.globalPosition.dx - mainOffsetX;
    var tapCorrectedY = info.raw.globalPosition.dy;
    deviceModules.forEach((module) {
      module!.onDragUpdate(tapCorrectedX, tapCorrectedY);
    });
  }
  @override
  void onDragEnd(int pointerId, DragEndInfo info) {
    print('_onDragEnded: ${info.raw.velocity}');

    deviceModules.forEach((module) {
      module!.onDragEnd(info.raw.velocity);
    });
  }

  @override
  void onDragCancel(int pointerId) {
    print('_onDragCancelled');

    deviceModules.forEach((module) {
      module!.onDragCancel();
    });
  }
}
