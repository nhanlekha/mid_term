import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mid_term/data/firebase_service/firestor.dart';
import 'package:provider/provider.dart';

import 'auth/mainpage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: FirebaseOptions(
          apiKey: "AIzaSyCMyQrimyw-SPNssMMVf4yl1avE15Adogg",
          authDomain: "mid-term-14678.firebaseapp.com",
          projectId: "mid-term-14678",
          storageBucket: "mid-term-14678.appspot.com",
          messagingSenderId: "811917722570",
          appId: "1:811917722570:web:223b9c36bada2392464533",
          measurementId: "G-9QKYQ3JKH2"
          // Your web Firebase config options
          ),
    );
  } else {
    await Firebase.initializeApp();
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        StreamProvider.value(
          value: Firebase_Firestor().user,
          initialData: null,
          catchError: (context, error) => null,
        ),
      ],
      child: const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: ScreenUtilInit(designSize: Size(375, 812), child: MainPage()),
      ),
    );
  }
}
