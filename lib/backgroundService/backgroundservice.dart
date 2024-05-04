// import 'dart:async';
// import 'dart:ui';

// import 'package:flutter/material.dart';
// import 'package:flutter_background_service/flutter_background_service.dart';

// Future<void> initialize() async {
//   final service = FlutterBackgroundService();

//   await service.configure(
//       iosConfiguration: IosConfiguration(
//           onBackground: iosbackgroundService, onForeground: onstart),
//       androidConfiguration:
//           AndroidConfiguration(onStart: onstart, isForegroundMode: true));
// }

// @pragma("vm:entry-point")
// Future<bool> iosbackgroundService(ServiceInstance serviceInstance) async {
//   WidgetsFlutterBinding.ensureInitialized();
//   DartPluginRegistrant.ensureInitialized();
//   return true;
// }

// @pragma("vm:entry-point")
// void onstart(ServiceInstance service) async {
//   DartPluginRegistrant.ensureInitialized();
//   service.on("setAsForground").listen((event) {
//     print("running in forground");
//   });
//   service.on("setAsBackground").listen((event) {
//     print("running in background");
//   });
//   Timer.periodic(const Duration(seconds: 2), (timer) {
    
//   });
// }
