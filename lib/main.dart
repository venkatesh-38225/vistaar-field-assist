import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:media_store_plus/media_store_plus.dart';
import 'package:re_kyc_mobile_app/models/login_details_hive_store.dart';
import 'package:re_kyc_mobile_app/screens/login_screens/splash_screen.dart';
import 'package:re_kyc_mobile_app/route_observer.dart';
import 'package:re_kyc_mobile_app/screens/sarfaesi/sarfaesi.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Initialize MediaStore before anything else
  await MediaStore.ensureInitialized();
  MediaStore.appFolder = "Legal Notice";

  await Hive.initFlutter();
  Hive.registerAdapter<LoginDetails>(LoginDetailsAdapter());

  AndroidOptions getAndroidOptions() => const AndroidOptions(
    encryptedSharedPreferences: true,
  );

  FlutterSecureStorage secureStorage = FlutterSecureStorage(
    aOptions: getAndroidOptions(),
  );

  final encryptionKey = await secureStorage.read(key: 'hiveStorage');
  if (encryptionKey != null) {
    final userKey = base64Url.decode(encryptionKey);
    await Hive.openBox(
      'hiveStorage',
      encryptionCipher: HiveAesCipher(userKey),
    );
    await Hive.openBox(
      'userDetails',
      encryptionCipher: HiveAesCipher(userKey),
    );
  } else {
    final key = Hive.generateSecureKey();
    await secureStorage.write(
      key: 'hiveStorage',
      value: base64UrlEncode(key),
    );
    final encryptionKey = await secureStorage.read(key: 'hiveStorage');
    final userKey = base64Url.decode(encryptionKey!);
    await Hive.openBox(
      'hiveStorage',
      encryptionCipher: HiveAesCipher(userKey),
    );
    await Hive.openBox(
      'userDetails',
      encryptionCipher: HiveAesCipher(userKey),
    );
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: Get.key,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
      navigatorObservers: [routeObserver,sarfaesiRouteObserver],
    );
  }
}