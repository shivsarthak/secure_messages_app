import 'package:flutter/material.dart';

const Color primaryColor = Color(0xff5c4df7);
const Color accentColor = Color(0xffb36ae8);
const Color white = Color.fromARGB(255, 226, 227, 255);
const Color black = Color(0xff333333);
const Color lighterGrey = Color.fromARGB(255, 92, 93, 128);
const Color grey = Color(0xff46476a);
const Color darkerGrey = Color.fromARGB(255, 53, 54, 80);
const Color accentGrey = Color(0xffa4afcf);
const LinearGradient primaryGradient = LinearGradient(
    colors: [grey, darkerGrey],
    stops: [0.3, 1],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter);
const LinearGradient secondaryGradient = LinearGradient(colors: [
  Color.fromARGB(255, 84, 70, 231),
  Color.fromARGB(255, 99, 65, 179)
], stops: [
  0,
  1
], begin: Alignment.topLeft, end: Alignment.bottomRight);
