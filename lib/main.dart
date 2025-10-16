import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';

import 'models/user_data_provider.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/welcome_screen.dart';
import 'services/sound_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  final userDataProvider = UserDataProvider();
  await userDataProvider.load();

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: userDataProvider),

        ProxyProvider<UserDataProvider, SoundManager>(
          update: (context, userData, previous) =>
              SoundManager(userDataProvider: userData),
          dispose: (_, soundManager) => soundManager.dispose(),
        ),
      ],
      child: const KelimeApp(),
    ),
  );
}

class KelimeApp extends StatelessWidget {
  const KelimeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Kelime Oyunu',
      theme: ThemeData(primarySwatch: Colors.orange),
      initialRoute: '/',
      routes: {
        '/': (context) => const AuthWrapper(),
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
        '/welcome': (context) => const WelcomeScreen(),
      },
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return const WelcomeScreen();
  }
}
