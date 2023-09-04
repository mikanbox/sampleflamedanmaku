import 'dart:io';
import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'dart:async' as async;


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

class FlameDemo extends StatefulWidget {
  @override
  State<FlameDemo> createState() => _FlameDemo();

}


class _FlameDemo extends State<FlameDemo> {
  final game = GameManager();
  int count = Ballet.count;
  int rss = 0;

  @override
  void initState() {
    super.initState();
   async.Timer.periodic(const Duration(seconds: 1), updateMetrics);
  }

  void updateMetrics(async.Timer timer) {
    setState(() {
      count =  Ballet.count;
      rss = ProcessInfo.currentRss;
    });
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;

    return Scaffold(
        appBar: AppBar(
            backgroundColor: Colors.blue,
            title: Column(
              children: [
                // const Text('Flame Demo'),
                // スマホの時だけパフォーマンス表示が可能
                // PerformanceOverlay.allEnabled(),
                Text('ProcessInfo.Rss ${rss}'),
                Text('Ballet count ${count}'),
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
    if (totaldt > 0.2) {
      totaldt -= 0.2;
      for(int i =0; i < 64;i++) {
        gameRef.add(Ballet(position:position, direction: i * 0.156125 * pi));
      }
    }
  }
}

class Ballet extends SpriteComponent with HasGameRef {
  static int count = 0;
  double totaldt = 0;
  double lifetime = 0;
  late double direction;
  double spd = 4.0;

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
    // if (totaldt > 0.3) {
    //   totaldt -= 0.3;
      final move = MoveToEffect(forward(), EffectController(duration: 0));
      add(move);
    // }
    if (lifetime > 2) {
      removeFromParent();
    }
  }
  Vector2 forward() {
    return Vector2(
        position.x + spd * sin(direction), y + spd * -cos(direction));
  }
  @override
  void onRemove() {
    Ballet.count--;
  }
}
