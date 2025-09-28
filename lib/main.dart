import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:kbv_bar/ui/bar_ui.dart';
import 'package:provider/provider.dart';
import 'app_theme.dart';
import 'firebase_options.dart';
import 'providers/app_provider.dart';

//TODO: Admin Bereich schöner, Website (mobile Version)


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AppProvider(),
      child: MaterialApp(
        title: 'KBV Kassen App',
        theme: AppTheme.theme,
        debugShowCheckedModeBanner: false,
        home: const BarSelectionScreen(),
      ),
    );
  }
}

