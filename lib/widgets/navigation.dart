import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mid_term/data/firebase_service/firestor.dart';
import 'package:mid_term/data/firebase_service/user_list.dart';
import 'package:mid_term/data/model/usermodel.dart';
import 'package:mid_term/helpers/color.dart';
import 'package:mid_term/helpers/extensions.dart';

import '../screen/add_screen.dart';
import '../screen/explore.dart';
import '../screen/home.dart';
import '../screen/profile_screen.dart';
import '../screen/reelsScreen.dart';

class Navigations_Screen extends StatefulWidget {
  const Navigations_Screen({super.key});

  @override
  State<Navigations_Screen> createState() => _Navigations_ScreenState();
}

int _currentIndex = 0;

class _Navigations_ScreenState extends State<Navigations_Screen> {
  late PageController pageController;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  UserModel? user;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // logout();
    //   final data = {
    //     'email': 'email',
    //   'username': 'username',
    //   'bio': 'bio',
    //   'profile': 'profile',
    //   'followers': [],
    //   'following': [],
    // };
    //
    //   addProductDetails(data,'124hufdhiusfhgfs');
    pageController = PageController();
  }

  // Future addProductDetails(
  //     Map<String, dynamic> productInfoMap, String id) async {
  //
  //   return await FirebaseFirestore.instance
  //       .collection("Product")
  //       .doc(id)
  //       .set(productInfoMap);
  // }

  Future<void> logout() async {
    try {
      await FirebaseAuth.instance.signOut();
      print("Đăng xuất thành công!");
    } catch (e) {
      print("Lỗi khi đăng xuất: $e");
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    pageController.dispose();
  }

  onPageChanged(int page) {
    setState(() {
      _currentIndex = page;
    });
  }

  navigationTapped(int page) {
    pageController.jumpToPage(page);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      initialData: null,
      stream: UserService().userModelStream,
      builder: (context, snapshot) {
        return Scaffold(
          bottomNavigationBar: SizedBox(
            height: 70,
            child: BottomNavigationBar(
              backgroundColor: ColorData.backGroundColorTextField,
              type: BottomNavigationBarType.fixed,
              selectedItemColor: Colors.black,
              unselectedItemColor: Colors.grey,
              currentIndex: _currentIndex,
              onTap: navigationTapped,
              items: [
                const BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: '',
                ),
                const BottomNavigationBarItem(
                  icon: Icon(Icons.search),
                  label: '',
                ),
                const BottomNavigationBarItem(
                  icon: Icon(Icons.camera),
                  label: '',
                ),
                BottomNavigationBarItem(
                  icon: Image.asset(
                    'images/instagram-reels-icon.png',
                    height: 20.h,
                  ),
                  label: '',
                ),
                const BottomNavigationBarItem(
                  icon: Icon(Icons.person),
                  label: '',
                ),
              ],
            ),
          ),
          body: PageView(
            controller: pageController,
            onPageChanged: onPageChanged,
            children: [
              HomeScreen(),
              ExploreScreen(),
              AddScreen(),
              ReelScreen(),
              ProfileScreen(
                Uid: _auth.currentUser!.uid,
              ),
            ],
          ),
        );
      },
    );
  }
}
