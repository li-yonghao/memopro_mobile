import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'screens/home_screen.dart';
import 'services/memo_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await MemoService.instance.initialize();
  runApp(const MemoProApp());
}

class MemoProApp extends StatefulWidget {
  const MemoProApp({super.key});

  static final GlobalKey<_MemoProAppState> appKey = GlobalKey<_MemoProAppState>();

  @override
  State<MemoProApp> createState() => _MemoProAppState();
}

class _MemoProAppState extends State<MemoProApp> {
  ThemeMode _themeMode = ThemeMode.light;

  @override
  void initState() {
    super.initState();
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final isDark = await MemoService.instance.getIsDarkMode();
    setState(() {
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    });
  }

  void toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    });
    MemoService.instance.setIsDarkMode(_themeMode == ThemeMode.dark);
  }

  ThemeMode get themeMode => _themeMode;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MemoPro',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _themeMode,
      home: HomeScreen(toggleTheme: toggleTheme),
    );
  }
}
