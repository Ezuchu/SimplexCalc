import 'package:flutter/material.dart';
import 'package:simplex_calc/funcObjetivo.dart';
import 'package:simplex_calc/restriccion.dart';
import 'package:simplex_calc/termino.dart';

class PantallaGrafico extends StatelessWidget
{
  final FuncObjetivo funcion;
  final List<Restriccion> restricciones;
  final List<List<(double,double)>> puntosInterseccion = [];

  PantallaGrafico({super.key, required this.funcion, required this.restricciones})
  {
    for(Restriccion r in restricciones)
    {
      List<(double, double)> puntos = [];
      double x = r.terminos[0].valor;
      double y = r.terminos[1].valor;
      double resultado = r.resultado.valor;

      // Calcular puntos de intersección
      double x1 = resultado / x;
      double y2 = resultado / y;

      puntos.add((x1,0));
      puntos.add((0,y2));
      puntosInterseccion.add(puntos);
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
                  ...puntosInterseccion.map((puntos) => Text("Punto: (${puntos[0].$1}, ${puntos[0].$2}) y (${puntos[1].$1}, ${puntos[1].$2})", style: TextStyle(fontSize: 16))).toList(),
                  Text("Gráfico:", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  // Aquí se puede integrar un widget de gráfico, como un CustomPaint o un paquete de gráficos
                  Container(color: Colors.white,padding: EdgeInsets.all(10),margin: EdgeInsets.symmetric(horizontal:350),
                    child:CustomPaint(
                      size: Size(double.infinity, 300),
                      painter: _GraficoPainter(puntosInterseccion, funcion.terminos, restricciones)
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

  _GraficoPainter(this.puntosInterseccion, this.terminosFuncion, this.restricciones);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    // Dibujar ejes
    canvas.drawLine(Offset(0, size.height), Offset(size.width, size.height), paint);
    canvas.drawLine(Offset(0, size.height), Offset(0, 0), paint);

    

    // Aquí se pueden agregar más detalles del gráfico según sea necesario
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}