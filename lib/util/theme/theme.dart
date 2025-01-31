
import 'package:flexmerchandiser/util/theme/elevatedbutton_theme.dart';
import 'package:flexmerchandiser/util/theme/text_theme.dart';
import 'package:flutter/material.dart';

class TAppTheme{

  TAppTheme._();


// lIGHT THeme
  static ThemeData lightTheme =  ThemeData(
    useMaterial3: true,
    fontFamily: 'Poppins',
    brightness: Brightness.light,
    primaryColor: Colors.blue,
    scaffoldBackgroundColor: Colors.white,
    textTheme: TTextTheme.lightTextTheme,
    elevatedButtonTheme: TElevatedbuttonTheme.lightElevatedButtonTheme,

  );


   static ThemeData darkTheme =  ThemeData(
    useMaterial3: true,
    fontFamily: 'Poppins',
    brightness: Brightness.dark,
    primaryColor: Colors.blue,
    scaffoldBackgroundColor: Colors.black,
    textTheme: TTextTheme.darkTextTheme,
    elevatedButtonTheme: TElevatedbuttonTheme.darkElevatedButtonTheme,
   );



}