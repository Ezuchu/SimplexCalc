import 'package:flutter/material.dart';

class Boton extends StatelessWidget
{
  final Color? color;
  final Color? textColor;
  final String buttonText;

  const Boton({this.color,this.textColor,required this.buttonText});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadiusGeometry.circular(20.0),
      child: Container(
        color: color,
        width: 60,
        height: 60,
        child:Center(
          child: Text(buttonText,style: TextStyle(color:textColor),)
        )
      )
    );
  }
}