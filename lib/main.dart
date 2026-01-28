import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'providers/app_provider.dart';
import 'screens/live_screen.dart';
import 'screens/local_screen.dart';
import 'screens/settings_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 🔥 Listen to theme changes
    return Consumer<AppProvider>(
      builder: (context, provider, child) {
        return MaterialApp(
          title: 'Illegal Littering Detector',
          debugShowCheckedModeBanner: false,

          // 🌙 Dynamic Theme Mode
          themeMode:
              provider.isDarkMode ? ThemeMode.dark : ThemeMode.light,

          // ☀️ Light Theme
          theme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.light,
            textTheme: GoogleFonts.robotoFlexTextTheme(
              ThemeData.light().textTheme,
            ),
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.teal,
              brightness: Brightness.light,
            ),
            appBarTheme: AppBarTheme(
              centerTitle: true,
              titleTextStyle: GoogleFonts.robotoFlex(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ),

          // 🌑 Dark Theme
          darkTheme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.dark,
            textTheme: GoogleFonts.robotoFlexTextTheme(
              ThemeData.dark().textTheme,
            ),
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.teal,
              brightness: Brightness.dark,
            ),
            appBarTheme: AppBarTheme(
              centerTitle: true,
              backgroundColor: const Color(0xFF1E1E1E),
              titleTextStyle: GoogleFonts.robotoFlex(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            scaffoldBackgroundColor: const Color(0xFF121212),
          ),

          home: const MainLayout(),
        );
      },
    );
  }
}

// ==========================================================
// MAIN LAYOUT (UNCHANGED)
// ==========================================================

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    LiveScreen(),
    LocalScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.sensors),
            label: "Detector",
          ),
          NavigationDestination(
            icon: Icon(Icons.photo_library),
            label: "Gallery",
          ),
          NavigationDestination(
            icon: Icon(Icons.settings),
            label: "Settings",
          ),
        ],
      ),
    );
  }
}
