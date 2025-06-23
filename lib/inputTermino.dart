import 'package:flutter/material.dart';

class InputTermino
{
  String signo = "+";
  String valor = "";
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