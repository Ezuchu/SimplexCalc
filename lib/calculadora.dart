import 'package:flutter/material.dart';

class Calculadora extends StatefulWidget
{
  const Calculadora({super.key,required this.title});

  final String title;

  @override 
  State<Calculadora> createState() => _CalculadoraState();
}

class _CalculadoraState extends State<Calculadora>
{
  final OverlayPortalController _metodoController = OverlayPortalController();

  final List<String> _metodos = ["Simplex","Gran M"];

  @override  
  Widget build(BuildContext context)
  {
    return Scaffold(
      backgroundColor: Color.fromRGBO(109, 129, 150, 1.0),
      body:Center(
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(15.0),
              margin: EdgeInsets.all(25.0),
              height: 200.0,
              decoration: BoxDecoration(
                color: Color.fromRGBO(173,235,179,0.5),
                borderRadius: BorderRadius.circular(15.0)
              )
            )
          ],
        ),)
    );
  }
}