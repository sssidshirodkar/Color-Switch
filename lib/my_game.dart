import 'package:color_switch_game/circle_rotator.dart';
import 'package:color_switch_game/color_switcher.dart';
import 'package:color_switch_game/ground.dart';
import 'package:color_switch_game/player.dart';
import 'package:color_switch_game/star_component.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/cupertino.dart';

class MyGame extends FlameGame
    with TapCallbacks, HasCollisionDetection /*, HasDecorator*/ {
  late Player mPlayer;
  final List<Color> gameColors;
  final ValueNotifier<int> currentScore = ValueNotifier<int>(0);
  final ValueNotifier<bool> bgmPlaying = ValueNotifier<bool>(true);

  final double gapBetweenSets = 250.0;
  double outerRotatorSize = 250.0;
  double innerRotatorSize = 230.0;

  MyGame({
    this.gameColors = const [
      Color(0xFFFC309B),
      Color(0xFF7D31E7),
      Color(0xFF03C9FD),
      Color(0xFFE0B107),
    ],
  }) : super(
         camera: CameraComponent.withFixedResolution(width: 600, height: 1000),
       );

  @override
  Color backgroundColor() => const Color(0xFF2F2741);

  @override
  Future<void> onLoad() async {
    super.onLoad();
    // decorator = PaintDecorator.blur(0);
    await FlameAudio.bgm.initialize();
    await Flame.images.loadAll([
      'tap_finger.png',
      'star.png',
    ]);
    await FlameAudio.audioCache.loadAll([
      'bgm.mp3',
      'hit.wav',
      'pickup.wav',
    ]);
  }

  void pauseAudio() {
    FlameAudio.bgm.pause();
    bgmPlaying.value = false;
  }

  void resumeAudio() {
    FlameAudio.bgm.resume();
    bgmPlaying.value = true;
  }

  @override
  void onMount() {
    // debugMode = true;
    super.onMount();
    _initializeGame();
  }

  @override
  update(double dt) {
    super.update(dt);

    final cameraY = camera.viewfinder.position.y;
    final playerY = mPlayer.position.y;
    // Make the camera follow the player only when the player is above the camera i.e. only when player is moving up
    if (playerY < cameraY) {
      camera.viewfinder.position = mPlayer.position;
    }
  }

  @override
  void onTapUp(TapUpEvent event) {
    super.onTapUp(event);
    mPlayer.jump();
  }

  void _initializeGame() {
    currentScore.value = 0;
    outerRotatorSize = 250.0;
    innerRotatorSize = 230.0;
    _gameComponents.clear();
    camera.viewfinder.position = Vector2.zero();
    // camera.viewfinder.zoom = 0.3;
    world.add(Ground(position: Vector2(0, 400)));
    world.add(mPlayer = Player(position: Vector2(0, 350)));
    generateGameComponents(Vector2(0, 0));
    FlameAudio.bgm.play('bgm.mp3', volume: 0.10);
  }

  final List<PositionComponent> _gameComponents = [];

  void addComponentToGame(PositionComponent component) {
    _gameComponents.add(component);
    world.add(component);
  }

  void generateGameComponents(Vector2 generateFromPosition) {
    addComponentToGame(CircleRotator(position: generateFromPosition + Vector2(0, 0 * gapBetweenSets), size: Vector2(outerRotatorSize, outerRotatorSize)));
    addComponentToGame(StarComponent(position: generateFromPosition + Vector2(0, 0 * gapBetweenSets), size: Vector2(30, 30)));
    addComponentToGame(ColorSwitcher(position: generateFromPosition + Vector2(0, gapBetweenSets), size: Vector2(30, 30)));

    addComponentToGame(CircleRotator(position: generateFromPosition + Vector2(0, -2 * gapBetweenSets), size: Vector2(outerRotatorSize, outerRotatorSize)));
    addComponentToGame(StarComponent(position: generateFromPosition + Vector2(0, -2 * gapBetweenSets), size: Vector2(30, 30)));
    addComponentToGame(ColorSwitcher(position: generateFromPosition + Vector2(0, -gapBetweenSets), size: Vector2(30, 30)));

    addComponentToGame(
      CircleRotator(position: generateFromPosition + Vector2(0, -4 * gapBetweenSets), size: Vector2(outerRotatorSize, outerRotatorSize)),
    );
    addComponentToGame(
      CircleRotator(position: generateFromPosition + Vector2(0, -4 * gapBetweenSets), size: Vector2(innerRotatorSize, innerRotatorSize)),
    );
    addComponentToGame(StarComponent(position: generateFromPosition + Vector2(0, -4 * gapBetweenSets), size: Vector2(30, 30)));
    addComponentToGame(ColorSwitcher(position: generateFromPosition + Vector2(0, -3 * gapBetweenSets), size: Vector2(30, 30)));
  }

  void gameOver() {
    FlameAudio.bgm.stop();
    bgmPlaying.value = false;
    for (var element in world.children) {
      element.removeFromParent();
    }
    _initializeGame();
  }

  bool get isGamePaused => paused;

  void pauseGame() {
    FlameAudio.bgm.pause();
    bgmPlaying.value = false;
    // decorator = PaintDecorator.blur(5);
    pauseEngine();
  }

  void resumeGame() {
    resumeEngine();
    FlameAudio.bgm.resume();
    bgmPlaying.value = true;
    // decorator = PaintDecorator.blur(0);
  }

  void incrementScore() {
    currentScore.value += 1;
  }

  void reduceRotatorSizes() {
    outerRotatorSize = outerRotatorSize - 2;
    innerRotatorSize = innerRotatorSize - 2;
  }

  void addNextGameComponentsIfNeeded(StarComponent currentStarComponent) {
    final allStarComponents = _gameComponents.whereType<StarComponent>();
    for(int i = 0; i < allStarComponents.length; i++) {
      if(allStarComponents.elementAt(i) == currentStarComponent && i == allStarComponents.length - 2) {
        generateGameComponents(allStarComponents.last.position + Vector2(0, -600));
        garbageCollectGameComponents(currentStarComponent);
        reduceRotatorSizes();
        break;
      }
    }
  }

  void garbageCollectGameComponents(StarComponent currentStarComponent) {
    if(_gameComponents.length <= 20) {
      return;
    }
    for (int i = 0; i < _gameComponents.length; i++) {
      if(_gameComponents[i] == currentStarComponent && i >= 20){
        // if current star is 20th or beyond, remove all components before it
        removeComponentsUpToIndex(i - 10);
        break;
      }
    }
  }

  void removeComponentsUpToIndex(int n) {
    for (int i = 0; i < n; i++) {
      _gameComponents[i].removeFromParent();
    }
    _gameComponents.removeRange(0, n);
  }
}
