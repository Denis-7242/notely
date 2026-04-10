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
    const primaryColor = Color(0xFF4F6EF7); // Modern indigo-blue

    return ThemeData(
      useMaterial3: true, // Use the latest Material Design
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.light,
        primary: primaryColor,
        background: const Color(0xFFF8F9FE),
        surface: Colors.white,
      ),
      fontFamily: 'Roboto',
      // Rounded cards by default
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      // Rounded input fields
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
      ),
    );
  }

  // Dark Theme
  ThemeData _buildDarkTheme() {
    const primaryColor = Color(0xFF7B93FF); // Lighter blue for dark mode

    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.dark,
        primary: primaryColor,
        background: const Color(0xFF0F1117),
        surface: const Color(0xFF1C1F2E),
      ),
      fontFamily: 'Roboto',
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
      ),
    );
  }
}