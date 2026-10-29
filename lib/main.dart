import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/game_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Color(0xFFF8F6F2),
    statusBarIconBrightness: Brightness.dark,
    systemNavigationBarColor: Color(0xFFF8F6F2),
    systemNavigationBarIconBrightness: Brightness.dark,
  ));
  runApp(const Game2048App());
}

class Game2048App extends StatelessWidget {
  const Game2048App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '2048',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF8F6F2),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFEDC22E),
          brightness: Brightness.light,
        ),
        fontFamily: 'Roboto',
      ),
      home: const GameScreen(),
    );
  }
}
