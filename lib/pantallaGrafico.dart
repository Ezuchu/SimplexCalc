import 'package:flutter/material.dart';
import 'package:simplex_calc/funcObjetivo.dart';
import 'package:simplex_calc/restriccion.dart';
import 'package:simplex_calc/termino.dart';

class PantallaGrafico extends StatelessWidget
{
  final FuncObjetivo funcion;
  final List<Restriccion> restricciones;
  final List<List<(double,double)>> puntosInterseccion = [];
  final List<(double,double)> vertices = [];
  double minX=0;
  double minY=0;
  double maxX=0;
  double maxY=0;

  PantallaGrafico({super.key, required this.funcion, required this.restricciones})
  {
    for(Restriccion r in restricciones)
    {
      List<(double, double)> puntos = [];
      double x = r.terminos[0].valor;
      double y = r.terminos[1].valor;
      double resultado = r.resultado.valor;
      double x1 = 0;
      double y2 = 0;

      // Calcular puntos de intersección
      if(x != 0)
      {
        x1 = resultado / x;
        puntos.add((x1,0));
      }
      if(y != 0)
      {
        y2 = resultado / y;
        puntos.add((0,y2));
      }

      maxX = x1 > maxX? x1 : maxX;
      maxY = y2 > maxY? y2 : maxY;
      puntosInterseccion.add(puntos);
    }

    generarVertices();
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
          }
        }
        
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
      vertices.add((ap1+bp1,ap2+bp2));
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
        vertices.add((ap1,y1));
      }
    }else
    {
      y1 = y*ap2;
      r = s - y1;
      x1 = r/x;
      if(x1 >= 0)
      {
        vertices.add((x1,ap2));
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
                      painter: _GraficoPainter(puntosInterseccion, funcion.terminos, restricciones,vertices,maxX,maxY)
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
  final double maxX;
  final double maxY;
  late double maximo;

  _GraficoPainter(this.puntosInterseccion, this.terminosFuncion, this.restricciones,this.vertices,this.maxX,this.maxY)
  {
    maximo = maxX > maxY? maxX : maxY;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    // Dibujar ejes
    canvas.drawLine(Offset(0, size.height), Offset(size.height, size.height), paint);
    canvas.drawLine(Offset(0, size.height), Offset(0, 0), paint);

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

        canvas.drawCircle(Offset(x1, size.height - y1),5, paint);
        canvas.drawCircle(Offset(x2, size.height - y2),5, paint);
        canvas.drawLine(Offset(x1, size.height - y1), Offset(x2, size.height - y2), paint);
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
    
    canvas.drawCircle(Offset(x, size.height - y),5, paint);
  }

  void dibujarUnicoPunto((double, double) punto,Canvas canvas, Size size)
  {
    double x = punto.$1 / maximo * size.height;
    double y = punto.$2 / maximo * size.height;
    final paint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(x, size.height - y),5, paint);

    if(x==0)
    {
      canvas.drawLine(Offset(0, size.height - y), Offset(size.height, size.height-y), paint);
    }else
    {
      canvas.drawLine(Offset(x, size.height), Offset(x, 0), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}