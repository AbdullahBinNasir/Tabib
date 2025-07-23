import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:device_preview/device_preview.dart';
import 'package:tabib/screens/home/home_screen.dart';

import 'firebase_options.dart';
import 'core/theme/app_theme.dart';
import 'providers/auth_provider.dart';

import 'screens/home/splashscreen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/pharmacy/pharmacy_dashboard.dart';
import 'screens/pharmacy/Pharmacy_orders.dart';
import 'screens/pharmacy/add_medicine_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    DevicePreview(
      enabled: !kReleaseMode, // only enable in debug or profile mode
      builder: (context) => const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => AuthProvider())],
      child: MaterialApp(
        useInheritedMediaQuery: true,
        locale: DevicePreview.locale(context),
        builder: DevicePreview.appBuilder,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        title: 'Tabib',
        home: const TabibHMSSplashScreen(),
        routes: {
          '/login': (context) => const Login(),
          '/pharmacy': (context) => const PharmacyDashboard(),
          '/pharmacy-orders': (context) => const OrderManagementPage(),
          '/add-medicine': (context) => const AddMedicineScreen(),
                    '/home': (context) => const HomeScreen(),

        },
      ),
    );
  }
}
