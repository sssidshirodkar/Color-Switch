import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import 'my_game.dart';

void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      builder: (context, child) => HomePage(),
      theme: ThemeData.dark(),
    ),
  );
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late MyGame myGame;

  @override
  void initState() {
    super.initState();
    myGame = MyGame();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GameWidget(game: myGame),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ValueListenableBuilder(
                valueListenable: myGame.currentScore,
                builder: (context, value, child) {
                  return Row(
                    children: [
                      Icon(Icons.star, color: Colors.greenAccent, size: 20),
                      SizedBox(width: 5),
                      Text(
                        value.toString(),
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: Column(
                children: [
                  IconButton(
                    onPressed: () {
                      myGame.bgmPlaying.value ? myGame.pauseAudio() : myGame.resumeAudio();
                    },
                    icon: ValueListenableBuilder(valueListenable: myGame.bgmPlaying, builder: (context, value, child) => Icon(value ? Icons.music_off : Icons.music_note),),
                  ),
                  if (!myGame.isGamePaused)
                    IconButton(
                      onPressed: () {
                        setState(() {
                          myGame.pauseGame();
                        });
                      },
                      icon: Icon(Icons.pause),
                    ),
                ],
              ),
            ),
          ),
          if (myGame.isGamePaused)
            Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [Colors.black87, Colors.black12],
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Paused',
                      style: TextStyle(fontSize: 48, color: Colors.white70),
                    ),
                    SizedBox(height: 20),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          myGame.resumeGame();
                        });
                      },
                      icon: Icon(Icons.play_arrow),
                      iconSize: 48,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
