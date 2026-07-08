import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'core/routing/router.dart';
import 'core/theme/app_theme.dart';

void main() async {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables from .env file
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint("Warning: Could not load .env file: $e");
  }

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'OneBasket',
      debugShowCheckedModeBanner: false,
      
      // Routing configuration
      routerConfig: router,
      
      // Theme architecture configuration
      theme: OBTheme.lightTheme,
      darkTheme: OBTheme.darkTheme,
      themeMode: ThemeMode.system, // Respect system light/dark settings
    );
  }
}
