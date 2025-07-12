import 'package:simplex_calc/ecuacionLineal.dart';
import 'package:simplex_calc/termino.dart';


//Clase para representar restricciones
class Restriccion implements EcuacionLineal
{
  static const double TOLERANCIA = 0.01;
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

  //Evalua si se cumple la restriccion en un punto dado del plano cartesiano(Solo método gráfico)
  bool evaluarDosVariables((double,double) punto)
  {
    
    String a = punto.$1.toStringAsFixed(2);
    String b = punto.$2.toStringAsFixed(2);
    

    double x = terminos[0].valor*double.parse(a);
    double y = terminos[1].valor*double.parse(b);
    double s = resultado.valor;

    
    
    switch(igualdad)
    {
      case "=": return(x+y == s || (s+TOLERANCIA>= x+y && s-TOLERANCIA <= x+y));
      case ">=": return(x+y >= s-TOLERANCIA);
      case "<=":return(x+y <= s+TOLERANCIA);
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