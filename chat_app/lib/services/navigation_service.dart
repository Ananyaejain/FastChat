import 'package:chat_app/pages/chat_page.dart';
import 'package:chat_app/pages/home_page.dart';
import 'package:chat_app/pages/login_page.dart';
import 'package:chat_app/pages/register_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';

import '../consts.dart';

class NavigationService{
  late GlobalKey<NavigatorState> _navigationKey;

  final Map<String, Widget Function(BuildContext)> _routes ={
    LoginRoute: (context) => LoginPage(),
    HomePageRoute: (context) => HomePage(),
    RegisterRoute: (context) => RegisterPage(),
  };

  GlobalKey<NavigatorState>? get navigationKey{
    return _navigationKey;
  }

  Map<String, Widget Function(BuildContext)> get routes{
    return _routes;
  }

  NavigationService(){
    _navigationKey = GlobalKey<NavigatorState>();
  }

  void push(MaterialPageRoute route){
    _navigationKey.currentState?.push(route);
  }

  void pushNamed(String routeName){
    _navigationKey.currentState?.pushNamed(routeName);
  }
  void pushReplacementNamed(String routeName){
    _navigationKey.currentState?.pushReplacementNamed(routeName);
  }
  void goBack(){
    _navigationKey.currentState?.pop();
  }
}