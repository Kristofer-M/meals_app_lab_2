import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:permission_handler/permission_handler.dart';
import 'firebase_options.dart';
import 'screens/home_screen.dart';
import 'screens/favorites_screen.dart';
import 'services/notification_service.dart';
import 'services/notification_service.dart';
import 'services/api_service.dart';
import 'package:timezone/timezone.dart' as tz;

Future<void> scheduleRandomMealNotification() async {
  final api = ApiService();
  final meal = await api.randomMeal();
  
  // Schedule for 10 seconds from now (for testing)
  final now = tz.TZDateTime.now(tz.local);
  final testTime = now.add(const Duration(seconds: 20));
  
  print('System time NOW: $now');
  print('Will notify at: $testTime');
  
  await NotificationService().scheduleDailyNotification(
    id: 0,
    title: 'Daily Recipe',
    body: 'Try today\'s recipe: ${meal.name}',
    hour: testTime.hour,
    minute: testTime.minute,
    second: testTime.second
  );
}



void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize Firebase Messaging
  final messaging = FirebaseMessaging.instance;
  await messaging.requestPermission();
  await Permission.notification.request();

  // Initialize notifications
  await NotificationService().init();
  

  await scheduleRandomMealNotification();
  await NotificationService().debugStatus();
  print('Notification should be displayed at ${tz.TZDateTime.now(tz.local).add(const Duration(seconds: 20))}');

  
  await NotificationService().showTestNotification();

  runApp(const MealsApp());
}

class MealsApp extends StatelessWidget {
  const MealsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Meals App',
      theme: ThemeData(primarySwatch: Colors.teal),
      home: const MainScreen(),
    );
  }
}

// MainScreen with Bottom Navigation
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [const HomeScreen(), const FavoritesScreen()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.star), label: 'Favorites'),
        ],
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}
