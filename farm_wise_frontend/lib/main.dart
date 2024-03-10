import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:farm_wise_frontend/screens/signup_screen.dart';

import 'screens/buyer/buyer_home_screen.dart';
import 'screens/login_screen.dart';
// import 'screens/seller_add_item_screen.dart';
import 'screens/seller/seller_home_screen.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(const MyApp());
}

final GoRouter _router = GoRouter(
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      builder: (context, state) {
        return const SplashScreen();
      },
    ),
    GoRoute(
      path: '/login_screen',
      builder: (context, state) {
        return const LoginScreen();
      },
    ),
    GoRoute(
      path: '/signup_screen',
      builder: (context, state) {
        return const SignupScreen();
      },
    ),
    GoRoute(
      path: '/seller_home_screen',
      builder: (context, state) {
        return const SellerHomeScreen();
      },
    ),
    GoRoute(
      path: '/buyer_home_screen',
      builder: (context, state) {
        return const BuyerHomeScreen();
      },
    ),
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(0, 27, 156, 115),
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData.dark(useMaterial3: true), // standard dark theme
      themeMode: ThemeMode.system,
      // theme: ThemeData(
      //   colorScheme: ColorScheme.fromSeed(
      //     seedColor: const Color.fromARGB(0, 27, 156, 115),
      //   ),
      //   useMaterial3: true,
      // ),
      routerConfig: _router,
    );
  }
}

// class RootPage extends StatelessWidget {
//   const RootPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return const LoginScreen();
//   }
// }
