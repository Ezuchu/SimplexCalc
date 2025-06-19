import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:simplex_calc/funcObjetivo.dart';
import 'package:simplex_calc/restriccion.dart';
import 'package:simplex_calc/termino.dart';

class PantallaGrafico extends StatelessWidget
{
  final FuncObjetivo funcion;
  final List<Restriccion> restricciones;
  final List<Restriccion> restriccionesVariables = [];
  final List<List<(double,double)>> puntosInterseccion = [];
  final List<(double,double)> vertices = [];
  final List<(double,double)> puntosFactibles = [];

  double minX=0;
  double minY=0;
  double maxX=0;
  double maxY=0;
  double maximo=10;

  PantallaGrafico({super.key, required this.funcion, required this.restricciones})
  {
    for(Restriccion r in restricciones)
    {
      generarPuntosInterseccion(r);
      
    }
    calcularMaximo();
    if(restriccionesVariables.isNotEmpty)
    {
      for(Restriccion r in restriccionesVariables)
      {
        generarPuntosInterseccioNegativo(r);
        
      }
    }
    vertices.add((0,0));
    generarVertices();
    obtenerSolucionesFactibles();
  }

  void calcularMaximo()
  {
    maximo = maxX > maxY? maxX : maxY;
    
  }

  double calcularPunto(double s, double a, double b)
  {
    double r = s-a;
    
    return (r/b);
  }

  double obtenerY(double y, double s)
  {
    if(y != 0)
    {
      return s/y;
    }
    return -1;
  }

  void sumarVertice((double,double)punto)
  {
    if(!vertices.contains(punto))
    {
      vertices.add(punto);
    }
  }

  void generarPuntosInterseccion(Restriccion r)
  {
    List<(double, double)> puntos = [];
    double x = r.terminos[0].valor;
    double y = r.terminos[1].valor;
    double resultado = r.resultado.valor;
    double x1 = 0;
    double y2 = 0;

    

    if(x >= 0 && y >= 0)
    {
      // Calcular puntos de intersección
      if(x != 0)
      {
        x1 = resultado / x;
        puntos.add((x1,0));
        sumarVertice((x1,0));
      }
      if(y != 0)
      {
        y2 = resultado / y;
        puntos.add((0,y2));
        sumarVertice((0,y2));
      }
      maxX = x1 > maxX? x1 : maxX;
      maxY = y2 > maxY? y2 : maxY;
      puntosInterseccion.add(puntos);
    }else
    {
      restriccionesVariables.add(r);
    }   
  }

  generarPuntosInterseccioNegativo(Restriccion r)
  {
    List<(double, double)> puntos = [];
    double x = r.terminos[0].valor;
    double y = r.terminos[1].valor;
    double resultado = r.resultado.valor;
    double x1 = 0;
    double x2 = 0;
    double y1 = 0;
    double y2 = 0;
    
    
    if(x < 0)
    {
      y1 = resultado/y;
      if(x.abs()< y)
      {
        x2 = maximo;
        y2 = calcularPunto(resultado, x2*x,y);
        print("x2: $x2, y2: $y2");
      }else
      {
        y2 = maximo;
        x2 = calcularPunto(resultado,y2*y1,x);
      }
      
    }else
    {
      x1 = resultado/x;
      y2 = maximo;
      y2 = calcularPunto(resultado, x2*x1, y);
    }

    puntos.add((x1,y1));
    puntos.add((x2,y2));
    sumarVertice((x1,y1));
    
    
    
    puntosInterseccion.add(puntos);
  }

  void generarVertices()
  {
    for (var i = 0; i < restricciones.length-1; i++) {
      Restriccion r1 = restricciones[i];
      double x1 = r1.terminos[0].valor;
      double y1 = r1.terminos[1].valor;
      double s1 = r1.resultado.valor;
      for(var j = i+1; j <= restricciones.length-1;j++)
      {
        Restriccion r2 = restricciones[j];
        double x2 = r2.terminos[0].valor;
        double y2 = r2.terminos[1].valor;
        double s2 = r2.resultado.valor;

        if(puntosInterseccion[i].length < 2 && puntosInterseccion[j].length < 2)
        {
          generarVerticeDosConstantes(i, j);
        }else
        {
          if(puntosInterseccion[i].length < 2 || puntosInterseccion[j].length < 2)
          {
            if(puntosInterseccion[i].length < 2 )
            {
              generarVerticesUnConstante(i, x2, y2, s2);
            }else
            {
              generarVerticesUnConstante(j, x1, y1, s1);
            }
          }else
          {
            generarVertice(x1, x2, y1, y2, s1, s2);
          }
        }
        
      }
    }
  }

  void generarVertice(double x1, double x2, double y1, double y2, double s1, double s2)
  {
    
    double nx1 = x1;
    double ny1 = y1;
    double ns1 = s1;
    double nx2 = x2;
    double ny2 = y2;
    double ns2 = s2;
    if(nx1.abs() != 1)
    {
      double absX1 = nx1.abs();
      nx1 = nx1/absX1; 
      ny1 = ny1/absX1; 
      ns1 = ns1/absX1;
    }
    if(nx2.abs() != 1)
    {
      double absX2 = nx2.abs();
      nx2 = nx2/absX2;
      ny2/= ny2/absX2;
      ns2/= ns2/absX2;
    }
    print("$nx1, $ny1, $ns1");
    print("$nx2, $ny2, $ns2");
    //Ambas x tienen el mismo signo
    if(nx1 == nx2)
    {
      if(ns1 > ns2)
      {
        nx2*=-1;ny2*=-1;ns2*=-1;
      }else
      {
        nx1*=-1;ny1*=-1;ns1*=-1;
      }
    }

    double y = obtenerY(ny1+ny2,ns1+ns2);
    
    if(y >= 0)
    {
      double r = s2 - (y*y2);
      
      double x = r/x2;
      
      if(x>=0)
      {
        sumarVertice((x,y));
      }
    }
  }

  void generarVerticeDosConstantes(int i, int j)
  {
    double ap1 = puntosInterseccion[i][0].$1;
    double ap2 = puntosInterseccion[i][0].$2;
    double bp1 = puntosInterseccion[j][0].$1;
    double bp2 = puntosInterseccion[j][0].$2;
    if(ap1 != bp1 || ap2 != bp2)
    {
      sumarVertice((ap1+bp1,ap2+bp2));
    }
  }

  void generarVerticesUnConstante(int c, double x, double y, double s)
  {
    double ap1 = puntosInterseccion[c][0].$1;
    double ap2 = puntosInterseccion[c][0].$2;
    double x1;
    double r;
    double y1;
    if(ap1 != 0)
    {
      x1 = x*ap1;
      r = s - x1;
      y1 = r/y;
      if(y1 >= 0)
      {
        sumarVertice((ap1,y1));

      }
    }else
    {
      y1 = y*ap2;
      r = s - y1;
      x1 = r/x;
      if(x1 >= 0)
      {
        sumarVertice((x1,ap2));
      }
    }
  }

  obtenerSolucionesFactibles()
  {
    for((double,double) punto in vertices)
    {
      bool valido = true;
      for(Restriccion r in restricciones)
      {
        valido = r.evaluarDosVariables(punto);
      }
      if(valido)
      {
        puntosFactibles.add(punto);
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Gráfico"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [Container(
            padding: const EdgeInsets.all(8.0),
            margin:EdgeInsets.all(32),
            width: double.infinity,
            height: 400,
            decoration: BoxDecoration(
              color: Color.fromRGBO(173,235,179,0.5),
              borderRadius: BorderRadius.circular(15.0)),
            child:SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Función Objetivo:", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  Text(funcion.toString(), style: TextStyle(fontSize: 16)),
                  SizedBox(height: 20),
                  Text("Restricciones:", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  ...restricciones.map((r) => Text(r.toString(), style: TextStyle(fontSize: 16))).toList(),
                  Text("Puntos de Corte:", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  ...puntosInterseccion.map((puntos) => Text("Punto: ()", style: TextStyle(fontSize: 16))).toList(),
                  Text("Gráfico:", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  // Aquí se puede integrar un widget de gráfico, como un CustomPaint o un paquete de gráficos
                  Container(color: Colors.white,padding: EdgeInsets.all(10),margin: EdgeInsets.symmetric(horizontal:350),
                    child:CustomPaint(
                      size: Size(double.infinity, 300),
                      painter: _GraficoPainter(puntosInterseccion, funcion.terminos, restricciones,vertices,puntosFactibles,maximo)
                    ))
                ],
              ),
            )
          )
          ],
        ),
      ),
    );
  }
}

class _GraficoPainter extends CustomPainter {
  final List<List<(double, double)>> puntosInterseccion;
  final List<Termino> terminosFuncion;
  final List<Restriccion> restricciones;
  final List<(double,double)> vertices;
  final List<(double,double)> puntosFactibles;
  int c = 10;
  late double maximo;

  _GraficoPainter(this.puntosInterseccion, this.terminosFuncion, this.restricciones,this.vertices,this.puntosFactibles,double maximo)
  {
    this.maximo = maximo + (maximo*0.1);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    // Dibujar ejes
    canvas.drawLine(Offset(10, size.height-10), Offset(size.height+10, size.height-10), paint);
    canvas.drawLine(Offset(10, size.height-10), Offset(10, 10), paint);

    // Dibujar puntos de interseccion
    for (List<(double,double)> puntos in puntosInterseccion)
    {
      if(puntos.length < 2)
      {
        dibujarUnicoPunto(puntos[0],canvas,size);
      }else
      {
        double x1 = puntos[0].$1 / maximo * size.height;
        double y1 = puntos[0].$2 / maximo * size.height;
        double x2 = puntos[1].$1 / maximo * size.height;
        double y2 = puntos[1].$2 / maximo * size.height;

        /*if(puntos[1].$1 > maximo)
        {
          x2 = size.height;
        }
        if(puntos[1].$2 > maximo)
        {
          y2 = size.height;
        }*/

        canvas.drawCircle(Offset(x1+c, size.height - y1-c),5, paint);
        canvas.drawCircle(Offset(x2+c, size.height - y2-c),5, paint);
        canvas.drawLine(Offset(x1+c, size.height - y1-c), Offset(x2+c, size.height - y2-c), paint);
        canvas.clipRect(Offset.zero & size);
      }

      for((double,double) vertice in vertices)
      {
        dibujarVertice(vertice, canvas, size);
      }
      
    }
    // Aquí se pueden agregar más detalles del gráfico según sea necesario
  }

  void dibujarVertice((double,double)vertice,Canvas canvas, Size size)
  {
    double x = vertice.$1 / maximo * size.height;
    double y = vertice.$2 / maximo * size.height;
    final paint = Paint()
      ..color = Colors.green
      ..style = PaintingStyle.fill;
    
    final paintFact = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    if(puntosFactibles.contains(vertice))
    {
      canvas.drawCircle(Offset(x+c, size.height - y-c),5, paintFact);
    }else
    {
      canvas.drawCircle(Offset(x+c, size.height - y-c),5, paint);
    }
    
  }

  void dibujarUnicoPunto((double, double) punto,Canvas canvas, Size size)
  {
    double x = punto.$1 / maximo * size.height;
    double y = punto.$2 / maximo * size.height;
    final paint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(x+c, size.height - y-c),5, paint);

    if(x==0)
    {
      canvas.drawLine(Offset(0.0+c, size.height - y-c), Offset(size.height, size.height-y), paint);
    }else
    {
      canvas.drawLine(Offset(x+c, size.height-c), Offset(x, 0), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}