import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'texts_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  runApp(QuranApp(
    initialDarkMode: prefs.getBool('isDarkMode') ?? false,
    initialFontSize: prefs.getDouble('fontSize') ?? 18.0,
  ));
}

class QuranApp extends StatefulWidget {
  final bool initialDarkMode;
  final double initialFontSize;

  const QuranApp({
    Key? key,
    required this.initialDarkMode,
    required this.initialFontSize,
  }) : super(key: key);

  @override
  State<QuranApp> createState() => _QuranAppState();

  static _QuranAppState? of(BuildContext context) =>
      context.findAncestorStateOfType<_QuranAppState>();
}

class _QuranAppState extends State<QuranApp> {
  late bool _isDarkMode;
  late double _fontSize;

  @override
  void initState() {
    super.initState();
    _isDarkMode = widget.initialDarkMode;
    _fontSize = widget.initialFontSize;
  }

  Future<void> toggleTheme(bool value) async {
    setState(() => _isDarkMode = value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', value);
  }

  Future<void> updateFontSize(double size) async {
    setState(() => _fontSize = size);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('fontSize', size);
  }

  double get fontSize => _fontSize;

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'تطبيق القرآن والأدعية والزيارات الشامل',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.light,
          colorSchemeSeed: Colors.teal,
        ),
        darkTheme: ThemeData(
          brightness: Brightness.dark,
          colorSchemeSeed: Colors.teal,
        ),
        themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
        home: TextsPage(
          fontSize: _fontSize,
          toggleTheme: toggleTheme,
          isDarkMode: _isDarkMode,
        ),
      );
}
