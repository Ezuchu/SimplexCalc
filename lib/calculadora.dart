import 'package:flutter/material.dart';
import 'package:simplex_calc/PantallaSimplex.dart';
import 'package:simplex_calc/algoritmoDosFases.dart';
import 'package:simplex_calc/algoritmoSimplex.dart';
import 'package:simplex_calc/boton.dart';
import 'package:simplex_calc/funcObjetivo.dart';
import 'package:simplex_calc/pantallaDosFases.dart';
import 'package:simplex_calc/pantallaGrafico.dart';
import 'package:simplex_calc/inputRestriccion.dart';
import 'package:simplex_calc/inputTermino.dart';
import 'package:simplex_calc/restriccion.dart';
import 'package:simplex_calc/termino.dart';


//Pantalla de la interfaz de inicio
class Calculadora extends StatefulWidget
{
  const Calculadora({super.key,required this.title});

  final String title;

  @override 
  State<Calculadora> createState() => _CalculadoraState();
}

//Control de estado de la interfaz
class _CalculadoraState extends State<Calculadora>
{
  //Se establecen parametros por defecto
  
  int _metodo = 1;

  String _optimizacion = "max";

  int _numVariables = 2;

  int _numRestricciones = 1;

  List<InputTermino> _funcion = [InputTermino(),InputTermino()];

  List<InputRestriccion> _restricciones = List.generate(1, (int index){return InputRestriccion(2,InputTermino());});

  late TextEditingController controlador;

  late InputTermino terminoActual;

  
  @override   
  void initState() {
    super.initState();
    controlador = _funcion[0].controller;
    terminoActual = _funcion[0];
  }


  final List<String> _botones=
  [
    "del","C","X",
    "1","2","3",
    "4","5","6",
    "7","8","9",
    ".","0","="
  ];

  
  //Cambia el tipo de optimizacion de la funcion objetivo
  void _cambiarOptimizacion()
  {
    this.setState(() {
      _optimizacion = _optimizacion=="max"? "min" : "max";
    });
  }

  //Reduce o aumenta el numero de variables en las ecuaciones
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

  //Reduce o aumenta el numero de restricciones
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

  
  void _mostrarError(String mensaje)
  {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Error'),
        content: Text(mensaje),
        backgroundColor: Colors.blueGrey,
        actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('OK'),
        ),
        ],
      ),
    );
  }

  
  void _generarResultado()
  {
    
    List<Termino> terminosFuncion =[];
    List<Restriccion> restricciones = [];

    try {
      //Convierte las cadenas de entrada a datos validos para calculos reales
      for (InputTermino termino in _funcion) {
        terminosFuncion.add(Termino(double.parse(termino.signo + termino.valor)));
      }

      for (InputRestriccion restriccion in _restricciones) {
        List<Termino> terminos = [];
        for (InputTermino termino in restriccion.terminos) {
          terminos.add(Termino(double.parse(termino.signo + termino.valor)));
        }
        restricciones.add(Restriccion(
          terminos,
          restriccion.igualdad,
          Termino(double.parse(restriccion.resultado.valor))));
      }

    } catch (e) {
      _mostrarError("Por favor, ingrese solo números válidos en todos los campos.");
      return;
    }

    FuncObjetivo funcion = FuncObjetivo(_numVariables, _optimizacion, terminosFuncion);

    //Seleccion de metodo
    switch(_metodo)
    {
      //Grafico
      case 1: if(funcion.numVariables == 2)
            {
              Navigator.of(context).push(MaterialPageRoute(builder: (context)=>PantallaGrafico(funcion: funcion, restricciones: restricciones)));
            }else
            {
              _mostrarError("Por favor, ingrese solo 2 variables para trabajar con el metodo grafico");
              return;
            }break;
      
      //Simplex -> Si solo existen restricciones menor que
      case 2: if(validoSimplex(restricciones))
            {
              AlgoritmoSimplex simplex = AlgoritmoSimplex(funcion, restricciones);
              simplex.resolver();
              Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => PantallaSimplex(simplex: simplex)
              ));
            }
            else//Dos Fases -> Si no es válido para simplex
            {
              AlgoritmoDosFases dosFases = AlgoritmoDosFases(funcion, restricciones);
              dosFases.resolver();
              Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => PantallaDosFases(dosFases: dosFases)
              ));
            }break;
    }
    

  }

  bool validoSimplex(List<Restriccion> restricciones)
  {
    for(Restriccion restriccion in restricciones)
    {
      if(restriccion.igualdad != "<=")
      {
        return false;
      }
    }
    return true;
  }

  //Controla las funciones de los botones
  void presionarBoton(String valor)
  {
    String texto = terminoActual.valor;

    switch(valor)
    {
      case "del": texto = terminoActual.valor.substring(0,texto.length-1);break;
      case "C": texto ="";break;
      default:texto+=valor;
    }
    terminoActual.valor = texto;
    controlador.text = terminoActual.valor;
    
  }

  //Constructor de pantalla
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
                        //Entrada de funcion objetivo
                        return Row(children: [ElevatedButton(
                          style: ElevatedButton.styleFrom(shape: CircleBorder()),
                          //Botones de Signos
                          onPressed: () {
                            setState(() {
                              _funcion[index].signo == "+" ? _funcion[index].signo = "-" : _funcion[index].signo = "+";
                            });
                          },
                          child: Container(width: 10,child: Text(_funcion[index].signo)),
                        ), 
                        //Campo de entrada de variable x
                        TextField(
                            controller: _funcion[index].controller,
                            focusNode: _funcion[index].focusNode,
                            onTap: () => setState(() {
                              controlador = _funcion[index].controller;
                              terminoActual = _funcion[index];
                            }),
                            readOnly: true,
                            enableInteractiveSelection: false,
                            decoration: InputDecoration(constraints: BoxConstraints(maxWidth: 30))),
                        Text("X${index+1}")]);

                      })]
                      )),

                      //Apartado de restricciones
                  ...List.generate(_numRestricciones, (int index)
                  {
                    return SingleChildScrollView(scrollDirection: Axis.horizontal,child: Row(children: [...List.generate(_numVariables, (int index2)
                    {
                      return Row(children: [ElevatedButton(
                          style: ElevatedButton.styleFrom(shape: CircleBorder()),
                          //Botones de signos
                          onPressed: () {
                            setState(() {
                              _restricciones[index].terminos[index2].cambiarSigno();
                            });
                          },

                          child: Container(width: 10,child: Text(_restricciones[index].terminos[index2].signo)),
                        ),

                        //Campo de entrada
                        TextField(
                          controller: _restricciones[index].terminos[index2].controller,
                          focusNode: _restricciones[index].terminos[index2].focusNode,
                          onTap: ()=> setState(() {
                            controlador = _restricciones[index].terminos[index2].controller;
                            terminoActual = _restricciones[index].terminos[index2];
                          }),
                          readOnly: true,
                          enableInteractiveSelection: false,
                          decoration: InputDecoration(constraints: BoxConstraints(maxWidth: 30))),
                        Text("X${index2+1}")]);

                    }),SizedBox(width: 10,),

                    //Seleccion de igualdad o desigualdad
                    DropdownMenu(dropdownMenuEntries: 
                                                [DropdownMenuEntry(value: "=", label: "="),
                                                DropdownMenuEntry(value: "<=", label: "<="),
                                                DropdownMenuEntry(value: ">=", label: ">=")],
                                    initialSelection: "=",
                                    inputDecorationTheme: InputDecorationTheme(
                                      contentPadding: EdgeInsets.symmetric(vertical: 10,horizontal: 5),
                                      constraints: BoxConstraints.tight(Size.fromWidth(80)),
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(4),)
                                    ),
                                    onSelected: (String? seleccion)
                                      {
                                        setState(() {
                                          _restricciones[index].igualdad = seleccion!;
                                        });
                                      },),

                                      //Campo de resultado
                                      TextField(
                                        controller: _restricciones[index].resultado.controller,
                                        focusNode: _restricciones[index].resultado.focusNode,
                                        onTap: ()=> setState(() {
                                          controlador = _restricciones[index].resultado.controller;
                                          terminoActual = _restricciones[index].resultado;
                                        }),
                                        readOnly: true,
                                        enableInteractiveSelection: false,
                                        onChanged: (value) => _restricciones[index].resultado.cambiarValor(value),
                                        decoration: InputDecoration(constraints: BoxConstraints(maxWidth: 40)))]));
                  })
                  ],) 
            )),
        //Apartado inferior
        SingleChildScrollView(scrollDirection: Axis.horizontal,child:Row(mainAxisAlignment: MainAxisAlignment.center,
          children:
            //Selector de metodo de resolución
            [ DropdownMenu(
              dropdownMenuEntries: 
                [DropdownMenuEntry(value: 1, label: "Grafico"),
                DropdownMenuEntry(value: 2, label: "Simplex-DosFases")],
              initialSelection: 1,
              onSelected: (int? seleccion){setState(() {
                _metodo = seleccion!;});
                },),
            
            //Boton de cambio de optimización
            ElevatedButton(
              onPressed:_cambiarOptimizacion, 
              style: ElevatedButton.styleFrom(padding: EdgeInsets.all(15.0),shape: LinearBorder(), backgroundColor: Color.fromRGBO(109, 129, 150, 1.0)),
              child: Container(width: 60,child: Text(_optimizacion),)),

            //Selector de variables
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

              //Selector de restricciones
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

        //Apartado de botones
        Row(mainAxisAlignment: MainAxisAlignment.center,spacing: 40,children: 
        [
          Boton(color: Colors.redAccent,textColor: Colors.black,buttonText: _botones[0], buttomTap: ()=> presionarBoton(_botones[0])),
          Boton(color: Colors.deepOrange,textColor: Colors.black,buttonText: _botones[1], buttomTap: ()=> presionarBoton(_botones[1])),
          Boton(color: Colors.orange,textColor: Colors.black,buttonText: _botones[2]),
        ],),
        Row(mainAxisAlignment: MainAxisAlignment.center,spacing: 40,children: 
        [
          Boton(color: Colors.blueAccent,textColor: Colors.white,buttonText: _botones[3], buttomTap: ()=> presionarBoton(_botones[3])),
          Boton(color: Colors.blueAccent,textColor: Colors.white,buttonText: _botones[4], buttomTap: ()=> presionarBoton(_botones[4])),
          Boton(color: Colors.blueAccent,textColor: Colors.white,buttonText: _botones[5], buttomTap: ()=> presionarBoton(_botones[5])),
        ],),
        Row(mainAxisAlignment: MainAxisAlignment.center,spacing: 40,children: 
        [
          Boton(color: Colors.blueAccent,textColor: Colors.white,buttonText: _botones[6], buttomTap: ()=> presionarBoton(_botones[6])),
          Boton(color: Colors.blueAccent,textColor: Colors.white,buttonText: _botones[7], buttomTap: ()=> presionarBoton(_botones[7])),
          Boton(color: Colors.blueAccent,textColor: Colors.white,buttonText: _botones[8], buttomTap: ()=> presionarBoton(_botones[8])),
        ],),
        Row(mainAxisAlignment: MainAxisAlignment.center,spacing: 40,children: 
        [
          Boton(color: Colors.blueAccent,textColor: Colors.white,buttonText: _botones[9], buttomTap: ()=> presionarBoton(_botones[9])),
          Boton(color: Colors.blueAccent,textColor: Colors.white,buttonText: _botones[10], buttomTap: ()=> presionarBoton(_botones[10])),
          Boton(color: Colors.blueAccent,textColor: Colors.white,buttonText: _botones[11], buttomTap: ()=> presionarBoton(_botones[11])),
        ],),
        Row(mainAxisAlignment: MainAxisAlignment.center,spacing: 40,children: 
        [
          Boton(color: Colors.blueAccent,textColor: Colors.white,buttonText: _botones[12], buttomTap: ()=> presionarBoton(_botones[12])),
          Boton(color: Colors.blueAccent,textColor: Colors.white,buttonText: _botones[13], buttomTap: ()=> presionarBoton(_botones[13])),
          Boton(color: Colors.orange,textColor: Colors.black,buttonText: _botones[14],buttomTap: _generarResultado,),
        ],),
        ],
        ),)
    );
  }
}