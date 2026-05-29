import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'screens/home_screen.dart';
import 'models/file_manager_state.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  runApp(
    ChangeNotifierProvider(
      create: (_) => FileManagerState(),
      child: const XFileApp(),
    ),
  );
}

class XFileApp extends StatelessWidget {
  const XFileApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'XFile',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF1A1A2E),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFE94560),
          secondary: Color(0xFF533483),
          surface: Color(0xFF16213E),
          onPrimary: Colors.white,
          onSurface: Color(0xFFEAEAEA),
        ),
        textTheme: GoogleFonts.robotoTextTheme(ThemeData.dark().textTheme),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF16213E),
          foregroundColor: Color(0xFFEAEAEA),
          elevation: 0,
        ),
        cardTheme: const CardThemeData(
          color: Color(0xFF16213E),
          elevation: 0,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
