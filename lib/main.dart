import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:punching_machine/splashScreen/SplashScreen.dart';

FlutterLocalNotificationsPlugin notificationsPlugin =
    FlutterLocalNotificationsPlugin();
// final service = FlutterBackgroundService();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  AndroidInitializationSettings androidInitializationSettings =
      const AndroidInitializationSettings("ic_launcher.png");

  DarwinInitializationSettings initializationSettingsDarwin =
      const DarwinInitializationSettings(
    requestAlertPermission: true,
    requestBadgePermission: true,
    requestSoundPermission: true,
  );

  var initialisation = InitializationSettings(
      android: androidInitializationSettings,
      iOS: initializationSettingsDarwin);
  await notificationsPlugin.initialize(
    initialisation,
  );

  // await initialize();

  // DailyAttendence().setlocation();

  runApp(const ProviderScope(child: MyApp()));
}

// Future<void> initializeService() async {
//   const notificationChannelId = 'my_foreground_service';
//   const notificationId = 888;

//   final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
//       FlutterLocalNotificationsPlugin();

//   final AndroidNotificationChannel channel = AndroidNotificationChannel(
//     notificationChannelId,
//     'Foreground Service',
//     description: 'This channel is used for important notifications.',
//     importance: Importance.high,
//   );

//   await flutterLocalNotificationsPlugin
//       .resolvePlatformSpecificImplementation<
//           AndroidFlutterLocalNotificationsPlugin>()
//       ?.createNotificationChannel(channel);

//   service.invoke(
//     'configure',
//     {
//       'isForegroundMode': true,
//       'notificationChannelId': notificationChannelId,
//       'notificationId': notificationId,
//     },
//   );
// }

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    // BackgroundService.setTaskHandler(myTask);
    //service.startService();

    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Punching',
          theme: ThemeData(
            fontFamily: "Poppins",
            scaffoldBackgroundColor: Colors.white,
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            useMaterial3: true,
          ),
          home: const SplashScreen()),
    );
  }
}
