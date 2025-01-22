import 'package:flutter/material.dart';
import 'package:pairplay/auth/auth.dart';
import 'package:pairplay/auth/login_or_register.dart';
import 'package:pairplay/pages/guide_page.dart';
import 'package:pairplay/pages/home_page.dart';
import 'package:pairplay/pages/multi_page.dart';
import 'package:pairplay/pages/settings_page.dart';
import 'package:pairplay/pages/single_page.dart';
import 'package:pairplay/pages/store_page.dart';
import 'package:pairplay/pages/users_page.dart';
import 'package:pairplay/providers/pair_play_provider.dart';
import 'package:pairplay/theme/dark_mode.dart';
import 'package:pairplay/theme/light_mode.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart'; 
import 'firebase_options.dart'; 

final navigatorKey = GlobalKey<NavigatorState>(); 
final rootScaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>(); 

void main() async{

  // Initialize Firebase 
  WidgetsFlutterBinding.ensureInitialized(); 
  await Firebase.initializeApp(options:DefaultFirebaseOptions.currentPlatform);

  // Running App with the Provider 
  runApp(
    MultiProvider(providers: [
      ChangeNotifierProvider(create: (_)=> PairPlayProvider())
    ], child: const MyApp()));
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      scaffoldMessengerKey: rootScaffoldMessengerKey,
      home: AuthPage(), 
      theme: lightMode, 
      darkTheme: darkMode,
      routes: {
        '/login_register_page': (context) => const LoginOrRegister(), 
        '/home_page': (context) => HomePage(), 
        '/users_page': (context) => UsersPage(), 
        '/single_page': (context) => SinglePage(), 
        '/multi_page': (context) => MultiPage(), 
        '/settings_page': (context) => SettingsPage(), 
        '/store_page': (context) => StorePage(), 
        '/guide_page': (context) => GuidePage(), 

      }
    ); 
  }
} 



