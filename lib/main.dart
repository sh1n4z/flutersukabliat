import 'package:flutersukabliat/providers/cart_provider.dart';
import 'package:flutersukabliat/providers/favorite_provider.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'screens/splash_screen.dart';
import 'screens/main_screen.dart';
import 'screens/login_screen.dart';
import 'theme/app_theme.dart';
import 'services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => FavoriteProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Ebony Furniture',
      theme: AppTheme.ebonyTheme, // Đảm bảo sử dụng theme Luxury của Ebony
      home: const Initializer(), // Startup screen bắt đầu từ đây
    );
  }
}

class Initializer extends StatefulWidget {
  const Initializer({super.key});

  @override
  State<Initializer> createState() => _InitializerState();
}

class _InitializerState extends State<Initializer> {
  bool _showSplash = true;
  final AuthService _auth = AuthService();

  @override
  Widget build(BuildContext context) {
    // 1. Hiển thị SplashScreen đầu tiên khi bật app
    if (_showSplash) {
      return SplashScreen(
        onFinish: () {
          setState(() {
            _showSplash = false; // Khi Splash chạy xong (onFinish), tắt nó đi
          });
        },
      );
    }

    // 2. Sau khi Splash kết thúc, kiểm tra Login
    // Nếu có User (Firebase) -> Vào MainScreen (Home)
    // Nếu không -> Vào LoginScreen
    if (_auth.currentUser != null) {
      return const MainScreen();
    } else {
      return const LoginScreen();
    }
  }
}
