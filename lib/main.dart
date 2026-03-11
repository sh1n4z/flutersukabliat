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
  // Khởi tạo thời gian bắt đầu app để dùng cho SnackBar helper
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
      theme: AppTheme.ebonyTheme,
      home: const Initializer(),
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
    if (_showSplash) {
      return SplashScreen(
        onFinish: () {
          setState(() {
            _showSplash = false;
          });
        },
      );
    }

    return StreamBuilder<User?>(
      stream: _auth.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator(color: Color(0xFFA88860))),
          );
        }

        if (snapshot.hasData && snapshot.data != null) {
          return FutureBuilder<String?>(
            future: _auth.getUserRole(snapshot.data!.uid),
            builder: (context, roleSnapshot) {
              if (roleSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator(color: Color(0xFFA88860))),
                );
              }

              final role = roleSnapshot.data ?? 'customer';
              if (role == 'admin') {
                return const AdminDashboardScreen();
              }
              return const MainScreen();
            },
          );
        }

        return const LoginScreen();
      },
    );
  }
}
