import 'dart:io';
import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: 'Flutter Demo', home: FlameDemo());
  }
}

class FlameDemo extends StatelessWidget {
  FlameDemo({super.key});

  final game = GameManager();

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;

    return Scaffold(
        appBar: AppBar(
            backgroundColor: Colors.blue,
            title: Column(
              children: [
                const Text('Flame Demo'),
                // スマホの時だけパフォーマンス表示が可能
                // PerformanceOverlay.allEnabled(),
                Text('ProcessInfo.Rss ${ProcessInfo.currentRss}'),
                // const Text()
              ],
            )),
        body: Center(
            child: SizedBox(
          height: min(screenSize.height, screenSize.width),
          width: min(screenSize.height, screenSize.width),
          child: GameWidget(
            game: game,
          ),
        )
        )
    );
  }
}

class GameManager extends FlameGame {
  final Enemy _enemy = Enemy();

  @override
  Future<void> onLoad() async {
    super.onLoad();
    await add(_enemy);
  }
}

class Enemy extends SpriteComponent with HasGameRef {
  final effect = MoveToEffect(Vector2(200, 200), EffectController(duration: 0));
  double totaldt = 0;
  double lifetime = 0;
  Enemy() : super(size: Vector2.all(64.0));

  @override
  Future<void> onLoad() async {
    super.onLoad();
    sprite = await gameRef.loadSprite('enemy.png');
    await add(effect);
    anchor = Anchor.center;
  }

  @override
  void update(double dt) {
    totaldt += dt;
    lifetime += dt;
    if (totaldt > 3.0) {
      totaldt -= 3.0;
      // gameRef.add(Ballet(position:position, direction: 0));
      // gameRef.add(Ballet(position:position, direction: 0.5 * pi));
      // gameRef.add(Ballet(position:position, direction: 1 * pi ));
      // gameRef.add(Ballet(position:position, direction: 1.5  * pi));
    }

    if (lifetime > 5) {
      removeFromParent();
    }
  }
}

class Ballet extends SpriteComponent with HasGameRef {
  static int count = 0;
  double totaldt = 0;
  double lifetime = 0;
  late double direction;
  double spd = 20.0;

  Ballet({required position, required this.direction})
      : super(size: Vector2.all(16.0)) {
    Ballet.count++;
  }

  @override
  Future<void> onLoad() async {
    super.onLoad();
    anchor = Anchor.center;
    sprite = await gameRef.loadSprite('ballet.png');
    final effect =
        RotateEffect.to(this.direction, EffectController(duration: 0));
    await add(effect);
    final move = MoveToEffect(Vector2(200, 200), EffectController(duration: 0));
    await add(move);
    position = Vector2(200, 200);
    await add(MoveToEffect(forward(), EffectController(duration: 0)));
  }

  @override
  void update(double dt) {
    totaldt += dt;
    lifetime += dt;
    if (totaldt > 1.0) {
      totaldt -= 1.0;
      final move = MoveToEffect(forward(), EffectController(duration: 0));
      add(move);
    }
    if (lifetime > 10) {
      remove(this);
    }
  }
  Vector2 forward() {
    return Vector2(
        position.x + spd * sin(direction), y + spd * -cos(direction));
  }
}
