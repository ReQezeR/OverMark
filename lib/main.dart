import 'package:admob_flutter/admob_flutter.dart';
import 'package:flutter/material.dart';
import 'package:OverMark/pages/main_page.dart';
import 'package:OverMark/themes/dark_theme.dart';
import 'package:OverMark/themes/light_theme.dart';
import 'package:flutter/services.dart';
import 'package:theme_provider/theme_provider.dart';

void main() {
   SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
    systemNavigationBarColor: Colors.black,
    statusBarColor: Colors.black38,
  ));
  WidgetsFlutterBinding.ensureInitialized();
  Admob.initialize();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ThemeProvider(
      saveThemesOnChange: true,
      loadThemeOnInit: true,
      defaultThemeId: 'dark_theme', 
      themes: [
        customLightTheme(),
        customDarkTheme(),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'OverMark',
        color: Colors.black,
        home: ThemeConsumer(
          child: MainPage(title: 'OverMark'),
        ),
      ),
    );
  }
}