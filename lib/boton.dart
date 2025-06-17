import 'package:flutter/material.dart';

class Boton extends StatelessWidget
{
  final Color? color;
  final Color? textColor;
  final String buttonText;
  final buttomTap;

  const Boton({this.color,this.textColor,required this.buttonText,this.buttomTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(onTap: buttomTap,
      child: Padding(padding: EdgeInsets.all(1),
        child:ClipRRect(
          borderRadius: BorderRadiusGeometry.circular(20.0),
          child: Container(
            color: color,
            width: 60,
            height: 60,
            child:Center(
              child: Text(buttonText,style: TextStyle(color:textColor),)
            )
        )
      ))
    );
  }
}