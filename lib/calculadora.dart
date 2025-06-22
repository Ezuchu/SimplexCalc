import 'package:flutter/material.dart';
import 'package:simplex_calc/boton.dart';
import 'package:simplex_calc/funcObjetivo.dart';
import 'package:simplex_calc/pantallaGrafico.dart';
import 'package:simplex_calc/inputRestriccion.dart';
import 'package:simplex_calc/inputTermino.dart';
import 'package:simplex_calc/restriccion.dart';
import 'package:simplex_calc/termino.dart';

class Calculadora extends StatefulWidget
{
  const Calculadora({super.key,required this.title});

  final String title;

  @override 
  State<Calculadora> createState() => _CalculadoraState();
}

class _CalculadoraState extends State<Calculadora>
{
  

  final TextEditingController _textController = TextEditingController();

  int _metodo = 1;

  String _optimizacion = "max";

  int _numVariables = 2;

  int _numRestricciones = 1;

  List<InputTermino> _funcion = [InputTermino(),InputTermino()];

  List<InputRestriccion> _restricciones = List.generate(1, (int index){return InputRestriccion(2,InputTermino());});
  

  final List<String> _botones=
  [
    "del","/","X",
    "1","2","3",
    "4","5","6",
    "7","8","9",
    ".","0","="
  ];

  

  void _cambiarOptimizacion()
  {
    this.setState(() {
      _optimizacion = _optimizacion=="max"? "min" : "max";
    });
  }

  void _cambiarVariables()
  {
    setState(() {
      while(_funcion.length < _numVariables)
      {
        _funcion.add(InputTermino());
      }
      while(_funcion.length > _numVariables)
      {
        _funcion.removeLast();
      }
    });
    for(InputRestriccion r in _restricciones)
    {
      r.cambiarVariables(_numVariables);
    }
  }

  void _cambiarRestricciones()
  {
    setState(() {
      while(_restricciones.length < _numRestricciones)
      {
        _restricciones.add(InputRestriccion(_numVariables, InputTermino()));
      }
      while(_restricciones.length > _numRestricciones)
      {
        _restricciones.removeLast();
      }
    });
  }

  void _generarResultado()
  {
    List<Termino> terminosFuncion =[];
    List<Restriccion> restricciones = [];
    for(InputTermino termino in _funcion)
    {
      print(termino.valor);
      terminosFuncion.add(Termino(double.parse(termino.signo+termino.valor)));
    } 
    for(InputRestriccion restriccion in _restricciones)
    {
      
      List<Termino> terminos = [];
      for(InputTermino termino in restriccion.terminos)
      {
        print(termino.valor);
        terminos.add(Termino(double.parse(termino.signo+termino.valor)));
      }
      restricciones.add(Restriccion(terminos,restriccion.igualdad,Termino(double.parse(restriccion.resultado.valor))));
    }
    FuncObjetivo funcion = FuncObjetivo(_numVariables, _optimizacion, terminosFuncion);
    
    if(_metodo == 1 && funcion.numVariables == 2)
    {
      Navigator.of(context).push(MaterialPageRoute(builder: (context)=>PantallaGrafico(funcion: funcion, restricciones: restricciones)));
    }
  }


  @override  
  Widget build(BuildContext context)
  {
    return Scaffold(
      backgroundColor: Color.fromRGBO(109, 129, 150, 1.0),
      body:Center(
        child: Column(spacing: 10,
          children: [Container(
              padding: EdgeInsets.all(25.0),
              margin: EdgeInsets.all(30.0),
              height: 200.0,
              decoration: BoxDecoration(
                color: Color.fromRGBO(173,235,179,0.5),
                borderRadius: BorderRadius.circular(15.0)),
              child: SingleChildScrollView(
                child:Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  spacing: 20,
                  children: 
                  [
                    SingleChildScrollView(scrollDirection: Axis.horizontal,child:Row(children: [Text("Z =",style: TextStyle(fontSize: 24)),
                      ...List.generate(_funcion.length, (int index)
                      {
                        return Row(children: [ElevatedButton(
                          style: ElevatedButton.styleFrom(shape: CircleBorder()),
                          onPressed: () {
                            setState(() {
                              _funcion[index].signo == "+" ? _funcion[index].signo = "-" : _funcion[index].signo = "+";
                            });
                          },
                          child: Container(width: 10,child: Text(_funcion[index].signo)),
                        ), TextField(onChanged: (value) => _funcion[index].valor=value,decoration: InputDecoration(constraints: BoxConstraints(maxWidth: 30))),
                        Text("X$index")]);
                      })]
                      )),
                  ...List.generate(_numRestricciones, (int index)
                  {
                    return SingleChildScrollView(scrollDirection: Axis.horizontal,child: Row(children: [...List.generate(_numVariables, (int index2)
                    {
                      return Row(children: [ElevatedButton(
                          style: ElevatedButton.styleFrom(shape: CircleBorder()),
                          onPressed: () {
                            setState(() {
                              _restricciones[index].terminos[index2].cambiarSigno();
                            });
                          },
                          child: Container(width: 10,child: Text(_restricciones[index].terminos[index2].signo)),
                        ),TextField(onChanged: (value) => _restricciones[index].terminos[index2].cambiarValor(value),decoration: InputDecoration(constraints: BoxConstraints(maxWidth: 30))),
                        Text("X$index2")]);
                    }),DropdownMenu(dropdownMenuEntries: 
                                                [DropdownMenuEntry(value: "=", label: "="),
                                                DropdownMenuEntry(value: "<=", label: "<="),
                                                DropdownMenuEntry(value: ">=", label: ">=")],
                                    initialSelection: "=",
                                    inputDecorationTheme: InputDecorationTheme(
                                      contentPadding: EdgeInsets.symmetric(vertical: 10),
                                      constraints: BoxConstraints.tight(Size.fromWidth(70)),
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(4),)
                                    ),
                                    onSelected: (String? seleccion)
                                      {
                                        setState(() {
                                          _restricciones[index].igualdad = seleccion!;
                                        });
                                      },),
                                      
                                      TextField(onChanged: (value) => _restricciones[index].resultado.cambiarValor(value),decoration: InputDecoration(constraints: BoxConstraints(maxWidth: 30)))]));
                  })
                  ],) 
            )),
        SingleChildScrollView(scrollDirection: Axis.horizontal,child:Row(mainAxisAlignment: MainAxisAlignment.center,
          children: [ DropdownMenu(
              dropdownMenuEntries: 
                [DropdownMenuEntry(value: 1, label: "grafico"),
                DropdownMenuEntry(value: 2, label: "simplex"),
                DropdownMenuEntry(value: 3, label: "Dos fases"),
                ],
              initialSelection: 1,
              onSelected: (int? seleccion){setState(() {
                _metodo = seleccion!;});
                },),
            ElevatedButton(
              onPressed:_cambiarOptimizacion, 
              style: ElevatedButton.styleFrom(padding: EdgeInsets.all(15.0),shape: LinearBorder()),
              child: Container(width: 60,child: Text(_optimizacion),)),
            DropdownMenu(
              dropdownMenuEntries: 
                [DropdownMenuEntry(value: 2, label: "X=2"),
                DropdownMenuEntry(value: 3, label: "X=3"),
                DropdownMenuEntry(value: 4, label: "X=4"),
                DropdownMenuEntry(value: 5, label: "X=5"),],
              initialSelection: 2,
              onSelected: (int? seleccion){setState(() {
                _numVariables = seleccion!;});
                _cambiarVariables();},),
              DropdownMenu(
              dropdownMenuEntries: 
                [DropdownMenuEntry(value: 1, label: "1 Restriccion"),
                DropdownMenuEntry(value: 2, label: "2 Restricciones"),
                DropdownMenuEntry(value: 3, label: "3 Restricciones"),
                DropdownMenuEntry(value: 4, label: "4 Restricciones"),],
              initialSelection: 1,
              onSelected: (int? seleccion){setState(() {
                _numRestricciones = seleccion!;
                _cambiarRestricciones();
              });},)],)),
        Row(mainAxisAlignment: MainAxisAlignment.center,spacing: 40,children: 
        [
          Boton(color: Colors.redAccent,textColor: Colors.black,buttonText: _botones[0]),
          Boton(color: Colors.deepOrange,textColor: Colors.black,buttonText: _botones[1]),
          Boton(color: Colors.orange,textColor: Colors.black,buttonText: _botones[2]),
        ],),
        Row(mainAxisAlignment: MainAxisAlignment.center,spacing: 40,children: 
        [
          Boton(color: Colors.blueAccent,textColor: Colors.white,buttonText: _botones[3]),
          Boton(color: Colors.blueAccent,textColor: Colors.white,buttonText: _botones[4]),
          Boton(color: Colors.blueAccent,textColor: Colors.white,buttonText: _botones[5]),
        ],),
        Row(mainAxisAlignment: MainAxisAlignment.center,spacing: 40,children: 
        [
          Boton(color: Colors.blueAccent,textColor: Colors.white,buttonText: _botones[6]),
          Boton(color: Colors.blueAccent,textColor: Colors.white,buttonText: _botones[7]),
          Boton(color: Colors.blueAccent,textColor: Colors.white,buttonText: _botones[8]),
        ],),
        Row(mainAxisAlignment: MainAxisAlignment.center,spacing: 40,children: 
        [
          Boton(color: Colors.blueAccent,textColor: Colors.white,buttonText: _botones[9]),
          Boton(color: Colors.blueAccent,textColor: Colors.white,buttonText: _botones[10]),
          Boton(color: Colors.blueAccent,textColor: Colors.black,buttonText: _botones[11]),
        ],),
        Row(mainAxisAlignment: MainAxisAlignment.center,spacing: 40,children: 
        [
          Boton(color: Colors.blueAccent,textColor: Colors.white,buttonText: _botones[12]),
          Boton(color: Colors.blueAccent,textColor: Colors.white,buttonText: _botones[13]),
          Boton(color: Colors.orange,textColor: Colors.black,buttonText: _botones[14],buttomTap: _generarResultado,),
        ],),
        ],
        ),)
    );
  }
}