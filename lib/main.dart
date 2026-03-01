import 'package:flutersukabliat/providers/cart_provider.dart';
import 'package:flutersukabliat/providers/favorite_provider.dart';
import 'package:flutersukabliat/providers/product_provider.dart';
import 'package:flutersukabliat/providers/voucher_provider.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'screens/splash/splash_screen.dart';
import 'screens/main_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/admin/admin_dashboard_screen.dart';
import 'theme/app_theme.dart';
import 'services/auth_service.dart';
import 'utils/snackbar_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  AppGlobals.appStart = DateTime.now();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => FavoriteProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => VoucherProvider()),
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
            _showSplash = false;
          });
        },
      );
    }

    // 2. Sau khi Splash kết thúc, Listen Firebase Auth State Changes
    // Nếu có User (Firebase) -> Kiểm tra role: admin -> AdminDashboardScreen, customer -> MainScreen
    // Nếu không -> LoginScreen
    return StreamBuilder<User?>(
      stream: _auth.authStateChanges,
      builder: (context, snapshot) {
        // ⏳ Đang check auth state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            backgroundColor: Colors.white,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/logo1.png',
                    width: 100,
                    errorBuilder: (c, e, s) => const Icon(Icons.chair, size: 100),
                  ),
                  const SizedBox(height: 24),
                  const CircularProgressIndicator(color: Color(0xFFA88860)),
                  const SizedBox(height: 16),
                  const Text('Đang khởi động...', style: TextStyle(color: Colors.grey, fontSize: 14)),
                ],
              ),
            ),
          );
        }

        // ✅ Nếu có User -> Kiểm tra role từ Firestore
        if (snapshot.hasData && snapshot.data != null) {
          return FutureBuilder<String?>(
            future: _auth.getUserRole(snapshot.data!.uid),
            builder: (context, roleSnapshot) {
              // Đang tải role
              if (roleSnapshot.connectionState == ConnectionState.waiting) {
                return Scaffold(
                  backgroundColor: Colors.white,
                  body: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/images/logo1.png',
                          width: 100,
                          errorBuilder: (c, e, s) => const Icon(Icons.chair, size: 100),
                        ),
                        const SizedBox(height: 24),
                        const CircularProgressIndicator(color: Color(0xFFA88860)),
                      ],
                    ),
                  ),
                );
              }

              final role = roleSnapshot.data ?? 'customer';

              // Nếu admin -> AdminDashboardScreen
              if (role == 'admin') {
                return const AdminDashboardScreen();
              }

              // Nếu customer hoặc không có role -> MainScreen
              return const MainScreen();
            },
          );
        }

        // ❌ Nếu không có User -> LoginScreen
        return LoginScreen();
      },
    );
  }
}
