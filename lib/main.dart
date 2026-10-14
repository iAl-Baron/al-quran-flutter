import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'texts_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final bool isDarkMode = prefs.getBool('isDarkMode') ?? false;
  final double fontSize = prefs.getDouble('fontSize') ?? 18.0;

  runApp(QuranApp(initialDarkMode: isDarkMode, initialFontSize: fontSize));
}

class QuranApp extends StatefulWidget {
  final bool initialDarkMode;
  final double initialFontSize;

  const QuranApp({Key? key, required this.initialDarkMode, required this.initialFontSize}) : super(key: key);

  @override
  State<QuranApp> createState() => _QuranAppState();

  static _QuranAppState? of(BuildContext context) => context.findAncestorStateOfType<_QuranAppState>();
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

  void toggleTheme(bool value) async {
    setState(() {
      _isDarkMode = value;
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', value);
  }

  void updateFontSize(double size) async {
    setState(() {
      _fontSize = size;
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('fontSize', size);
  }

  double get fontSize => _fontSize;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'تطبيق القرآن والأدعية والزيارات الشامل',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.teal,
        fontFamily: 'Amiri',
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.teal,
        fontFamily: 'Amiri',
      ),
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: TextsPage(fontSize: _fontSize, toggleTheme: toggleTheme, isDarkMode: _isDarkMode),
    );
  }
}
