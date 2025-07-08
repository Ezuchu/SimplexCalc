import 'package:flutter/material.dart';
import 'package:simplex_calc/calculadora.dart';


//Ejecuta la aplicación
void main() {
  runApp(const MyApp());
}


//Ruta de la aplicacion
class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const Calculadora(title: 'Flutter Demo Home Page'),
    );
  }
}
