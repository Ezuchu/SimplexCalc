
import 'dart:ui';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:simplex_calc/funcObjetivo.dart';
import 'package:simplex_calc/restriccion.dart';
import 'package:simplex_calc/termino.dart';

typedef PuntoRestriccion = (List<(double,double)> puntos, Restriccion r);

class PantallaGrafico extends StatelessWidget
{
  final FuncObjetivo funcion;
  final List<Restriccion> restricciones;
  final List<Restriccion> restriccionesVariables = [];
  final List<List<(double,double)>> puntosInterseccion = [];
  final List<PuntoRestriccion> puntosRestriccion = [];
  final List<(double,double)> vertices = [];
  final List<(double,double)> puntosFactibles = [];
  final List<double> soluciones = [];
  double solucionOptima = 0;
  List<(double,double)> puntosOptimos = [];
  bool noAcotado = false;
  bool degenerada = false;

  double maxX=0;
  double maxY=0;
  double maximo=10;

  double minVerx=0;
  double minVery=0;
  double maxVerx=0;
  double maxVery=0;

  PantallaGrafico({super.key, required this.funcion, required this.restricciones})
  {
    int contAcotado = 0;
    for(Restriccion r in restricciones)
    {
      generarPuntosInterseccion(r);
      if(r.igualdad == ">=")
      {
        contAcotado++;
      }  
    }
    noAcotado = contAcotado == restricciones.length? true : false;

    calcularPuntoMaximo();

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
    if(noAcotado)
    {
      ordenarSolucionesNoAcotada();
    }else
    {
      ordenarSoluciones();
    }
    calcularSoluciones();
    vertices.toSet().toList();
  }

  void calcularPuntoMaximo()
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
      puntosRestriccion.add((puntos,r)); 
    }else
    {
      restriccionesVariables.insert(0,r);
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
      x2 = maximo;
      y2 = calcularPunto(resultado, x2*x,y);

    }else
    {
      x1 = resultado/x;
      y2 = maximo;
      x2 = calcularPunto(resultado, y2*y, x);

    }

    puntos.add((x1,y1));
    puntos.add((x2,y2));
    sumarVertice((x1,y1));
    
    
    
    puntosInterseccion.insert(0,puntos);
    puntosRestriccion.add((puntos,r));
  }

  void generarVertices()
  {
    
    
    for (var i = 0; i < puntosRestriccion.length-1; i++) {
      
      Restriccion r1 = puntosRestriccion[i].$2;
      List<(double,double)>puntos1 = puntosRestriccion[i].$1;
      double x1 = r1.terminos[0].valor;
      double y1 = r1.terminos[1].valor;
      double s1 = r1.resultado.valor;
      for(var j = i+1; j <= puntosRestriccion.length-1;j++)
      {
        
        Restriccion r2 = puntosRestriccion[j].$2;
        List<(double,double)>puntos2 = puntosRestriccion[j].$1;
        double x2 = r2.terminos[0].valor;
        double y2 = r2.terminos[1].valor;
        double s2 = r2.resultado.valor;

        if(puntos1.length < 2 && puntos2.length < 2)
        {

          generarVerticeDosConstantes(puntos1, puntos2);

        }else
        {
          if(puntos1.length < 2 || puntos2.length < 2)
          {
            if(puntos1.length < 2 )
            {
              generarVerticesUnConstante(puntos1, x2, y2, s2);
            }else
            {
              generarVerticesUnConstante(puntos2, x1, y1, s1);
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
      ny2 = ny2/absX2;
      ns2 = ns2/absX2;
    }

    
    
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

  void generarVerticeDosConstantes(List<(double,double)> puntos1, List<(double,double)> puntos2)
  {
    double ap1 = puntos1.first.$1;
    double ap2 = puntos1.first.$2;
    double bp1 = puntos2.first.$1;
    double bp2 = puntos2.first.$2;
    if(ap1 != bp1 || ap2 != bp2)
    {
      sumarVertice((ap1+bp1,ap2+bp2));
    }
  }

  void generarVerticesUnConstante(List<(double,double)> punto, double x, double y, double s)
  {
    double ap1 = punto[0].$1;
    double ap2 = punto[0].$2;
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
      if(!puntosFactibles.contains(punto))
      {
        for(Restriccion r in restricciones)
        {
          valido = r.evaluarDosVariables(punto);
          if(!valido){break;}
        }
        if(valido)
        {
          puntosFactibles.add(punto);
        }
      }else
      {
        degenerada = true;
      }
    }
  }

  void ordenarSolucionesNoAcotada()
  {
    puntosFactibles.sort((a, b) => a.$1.compareTo(b.$1));
  }

  void ordenarSoluciones()
  {
    

    // Ordenar los vértices en sentido antihorario respecto al centroide
    if (puntosFactibles.length > 2) {
      // Calcular el centroide
      double cx = 0, cy = 0;
      for (var p in puntosFactibles) {
        cx += p.$1;
        cy += p.$2;
      }
      cx /= puntosFactibles.length;
      cy /= puntosFactibles.length;

      // Ordenar por ángulo respecto al centroide
      puntosFactibles.sort((a, b) {
        double angleA = atan2(a.$2 - cy, a.$1 - cx);
        double angleB = atan2(b.$2 - cy, b.$1 - cx);
        return angleA.compareTo(angleB);
      });
      
    }
  }  

  void calcularSoluciones()
  {
    for(int i = 0; i < puntosFactibles.length; i++)
    {
      List<double> variables = [puntosFactibles[i].$1,puntosFactibles[i].$2];
      double solucion = funcion.calcularSolucion(variables);
      soluciones.add(solucion);
      
    }
    
    if(funcion.optimizacion == "max")
    {
      obtenerMaximo();
    }else
    {
      obtenerMinimo();
    }
  }

  void obtenerMaximo()
  {
    double max = 0;
    List<(double,double)> optimos=[];
    for(int i = 0; i < soluciones.length; i++)
    {
      if(soluciones[i]==max)
      {
        optimos.add(puntosFactibles[i]);
      }
      if(soluciones[i] > max)
      {
        max=soluciones[i];
        optimos.clear();
        optimos.add(puntosFactibles[i]);
      }
    }
    solucionOptima = max;
    puntosOptimos = optimos;
  }

  void obtenerMinimo()
  {
    double min = double.infinity;
    List<(double,double)> optimos=[];
    for(int i = 0; i < soluciones.length; i++)
    {
      if(soluciones[i]==min)
      {
        optimos.add(puntosFactibles[i]);
      }
      if(soluciones[i] < min)
      {
        min=soluciones[i];
        optimos.clear();
        optimos.add(puntosFactibles[i]);
      }
    }
    solucionOptima = min;
    puntosOptimos = optimos;
  }

  String mostrarTipoSolucion()
  {
    if(puntosOptimos.isEmpty)
    {
      return "No existe solucion optima";
    }
    String resultado = "Se obtuvo la siguiente solución optima ";
    resultado += puntosOptimos.length == 1? "única ": "múltiple ";
    if(noAcotado)
    {
      if(funcion.optimizacion == "max")
      {
        puntosOptimos.clear();
        return "No se pudo obtener una solución factible de la región no acotada";
      }
      resultado += "no acotada ";
    }
    if(degenerada){
      resultado += "degenerada";
    }
    resultado += ":";
    return resultado;
  }

  List<Widget> listaRestricciones()
  {
    List<Widget> lista = [];
    int cont = 1;
    for(Restriccion r in restricciones)
    {
      if(!restriccionesVariables.contains(r))
      {
        lista.add(Text("R$cont: ${r.toString()}", style: TextStyle(fontSize: 16)));
        cont++;
      }
    }
    for(Restriccion r in restriccionesVariables)
    {
      lista.add(Text("R$cont: ${r.toString()}", style: TextStyle(fontSize: 16)));
      cont++;
    }
    return lista;
  }

  List<Widget> listaPuntos()
  {
    List<Widget> lista = [];
    int cont = 1;
    for(List<(double,double)> puntos in puntosInterseccion)
    {
      String resultado = "R$cont: ";
      for((double,double) punto in puntos)
      {
        resultado += "P(${punto.$1.toStringAsFixed(2)},${punto.$2.toStringAsFixed(2)}) ";
      }
      lista.add(Text(resultado,style: TextStyle(fontSize: 16)));
      cont++;
    }
    return lista;
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
                  ...listaRestricciones(),
                  Text("Puntos de Corte:", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  ...listaPuntos(),
                  Text("Gráfico:", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  // Aquí se puede integrar un widget de gráfico, como un CustomPaint o un paquete de gráficos
                  Container(color: Colors.white,padding: EdgeInsets.all(10),margin: EdgeInsets.symmetric(horizontal:10,vertical: 100),
                    child:CustomPaint(
                      size: Size(double.infinity, 300),
                      painter: _GraficoPainter(puntosInterseccion, funcion.terminos, restricciones,vertices,puntosFactibles,maximo,noAcotado)
                    )),
                  Text("Vertices:",style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  ...List.generate(puntosFactibles.length, (int index)
                  {
                    String texto = "P${index+1}(${puntosFactibles[index].$1.toStringAsFixed(2)},${puntosFactibles[index].$2.toStringAsFixed(2)}): ";
                    texto = "$texto${soluciones[index].toStringAsFixed(2)}";
                    if(soluciones[index]==solucionOptima)
                    {
                      return Text(texto, style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold));
                    }
                    return Text(texto, style: TextStyle(fontSize: 16));
                  }),
                  Text("Conclusión:",style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  Text(mostrarTipoSolucion(),style: TextStyle(fontSize: 16)),
                  ...List.generate(puntosOptimos.length, (int index)
                  {
                    String resultado = "x1: ${puntosOptimos[index].$1.toStringAsFixed(2)}   ";
                    resultado += "x2: ${puntosOptimos[index].$2.toStringAsFixed(2)}   ";
                    resultado += "Z: ${solucionOptima.toStringAsFixed(2)}";
                    return Text(resultado,style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold));
                  })
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
  late bool noAcotado;

  _GraficoPainter(this.puntosInterseccion, this.terminosFuncion, this.restricciones,this.vertices,this.puntosFactibles,double maximo,this.noAcotado)
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
    }
    for((double,double) vertice in vertices)
    {
      dibujarVertice(vertice, canvas, size);
    }

    for(int i = 0; i < puntosFactibles.length;i++)
    {
      if(i != puntosFactibles.length-1)
      {
        dibujarRectaArea(puntosFactibles[i],puntosFactibles[i+1],canvas,size);
      }else if(!noAcotado)
      {
        dibujarRectaArea(puntosFactibles[i],puntosFactibles[0],canvas,size);
      }
      anotarCoordenada(i+1,puntosFactibles[i].$1,puntosFactibles[i].$2,canvas,size);
    }
    
    
  }

  void anotarCoordenada(int i, double x, double y,Canvas canvas,Size size)
  {
    double px = x/maximo*size.height;
    double py = y/maximo*size.height;

    final paint = TextPainter
    (
      text: TextSpan(text:"P$i",style:TextStyle(color:Colors.purple,fontSize: 16,fontWeight: FontWeight.bold)),
      textDirection: TextDirection.ltr
    );
    paint.layout(maxWidth: size.height);
    paint.paint(canvas, Offset(px+c, size.height-py-(c*3)));
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

  dibujarRectaArea((double , double ) p1, (double , double ) p2,Canvas canvas, Size size)
  {
    final paint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;
      
      
    double x1 = p1.$1/maximo*size.height;
    double x2 = p2.$1/maximo*size.height;
    double y1 = p1.$2/maximo*size.height;
    double y2 = p2.$2/maximo*size.height;

    canvas.drawLine(Offset(x1+c, size.height-y1-c), Offset(x2+c, size.height-y2-c), paint);
    
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
      canvas.drawLine(Offset(0.0+c, size.height - y-c), Offset(size.height+c, size.height-y-c), paint);
    }else
    {
      canvas.drawLine(Offset(x+c, size.height-c), Offset(x+c, 0.0-c), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}