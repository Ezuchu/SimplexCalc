import 'package:flutter/material.dart';


//Clase para la entrada de terminos de coeficiente en formato texto
class InputTermino
{
  String signo = "+";
  String valor = "";

  //Controladores para modificar valores
  late TextEditingController controller;
  final FocusNode focusNode = FocusNode();

  InputTermino()
  {
    controller = TextEditingController();
  }

  void cambiarSigno()
  {
    signo == "+"? signo = "-" : signo = "+"; 
  }

  void cambiarValor(String nuevoValor)
  {
    print("valor: $valor, nuevoValor: $nuevoValor");
    valor = nuevoValor;
  }
}