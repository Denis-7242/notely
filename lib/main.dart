import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/note_provider.dart';
import 'services/note_storage.dart';
import 'services/theme_provider.dart';
import 'screens/home_screen.dart';

// main() is async because we need to wait for Hive to be ready
// before showing any UI
Future<void> main() async {
  // Ensures Flutter's engine is ready before we do async work
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize local storage (opens the Hive database)
  await NoteStorage.init();

  runApp(const NotelyApp());
}

class NotelyApp extends StatelessWidget {
  const NotelyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => NoteProvider()..loadNotes(),
        ),
        ChangeNotifierProvider(
          create: (_) => ThemeProvider()..loadTheme(),
        ),
      ],
      // Consumer<ThemeProvider> rebuilds MaterialApp when theme changes
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: 'Notely',
            debugShowCheckedModeBanner: false,
            themeMode: themeProvider.themeMode,
            theme: _buildLightTheme(),
            darkTheme: _buildDarkTheme(),

            // ---- Start Screen ----
            home: const HomeScreen(),
          );
        },
      ),
    );
  }

  // Light Theme
  ThemeData _buildLightTheme() {
    const primaryColor = Color(0xFF6366F1); // Modern Indigo
    const backgroundC = Color(0xFFF8FAFC); // Slate 50
    const surfaceC = Color(0xFFFFFFFF);

    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.light,
        primary: primaryColor,
        surface: surfaceC,
        background: backgroundC,
      ),
      fontFamily: 'Inter', // Modern sans-serif look (fallback to Roboto if not present)
      cardTheme: CardThemeData(
        elevation: 0,
        color: surfaceC,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: Colors.grey.withOpacity(0.1), width: 1),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.grey.withOpacity(0.05),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primaryColor, width: 1.5),
        ),
      ),
      textTheme: const TextTheme(
        headlineSmall: TextStyle(fontWeight: FontWeight.w800, letterSpacing: -0.5),
        titleMedium: TextStyle(fontWeight: FontWeight.w600),
        bodyLarge: TextStyle(height: 1.6),
      ),
    );
  }

  // Dark Theme
  ThemeData _buildDarkTheme() {
    const primaryColor = Color(0xFF818CF8); // Lighter Indigo
    const backgroundC = Color(0xFF0F172A); // Slate 900
    const surfaceC = Color(0xFF1E293B); // Slate 800

    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.dark,
        primary: primaryColor,
        surface: surfaceC,
        background: backgroundC,
      ),
      fontFamily: 'Inter',
      cardTheme: CardThemeData(
        elevation: 0,
        color: surfaceC,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: Colors.white.withOpacity(0.05), width: 1),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primaryColor, width: 1.5),
        ),
      ),
      textTheme: const TextTheme(
        headlineSmall: TextStyle(fontWeight: FontWeight.w800, letterSpacing: -0.5),
        titleMedium: TextStyle(fontWeight: FontWeight.w600),
        bodyLarge: TextStyle(height: 1.6),
      ),
    );
  }
}