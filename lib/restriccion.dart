import 'package:simplex_calc/ecuacionLineal.dart';
import 'package:simplex_calc/termino.dart';

class Restriccion implements EcuacionLineal
{
  List<Termino> terminos = [];
  String igualdad = "=";
  late Termino resultado;

  Restriccion(this.terminos,this.igualdad,this.resultado);

  @override
  String toString() {
    String resultado = "";
    int x = 1;
    for(Termino termino in terminos)
    {
      resultado += " ${termino.toString()}X$x";
      x++;
    }
    resultado += " $igualdad ${this.resultado.toString()}";
    return resultado.trim();
  }

  bool evaluarDosVariables((double,double) punto)
  {
    double a = punto.$1;
    double b = punto.$2;

    double x = terminos[0].valor*a;
    double y = terminos[1].valor*b;
    double s = resultado.valor;

    switch(igualdad)
    {
      case "=": return(x+y == s);
      case ">=": return(x+y >= s);
      case "<=":return(x+y <= s);
      default: return false;
    }
  }
  
  @override
  double obtenerSolucion() {
    return resultado.valor;
  }
  
  @override
  List<double> obtenerVariables() {
    List<double> coeficientes = [];
    for(Termino termino in terminos)
    {
      coeficientes.add(termino.valor);
    }
    return coeficientes;
  }
  
  @override
  double obtenerZ() {
    return 0.0;
  }

  @override
  String obtenerTipo()
  {
    return igualdad;
  }
}