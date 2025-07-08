import 'package:simplex_calc/ecuacionLineal.dart';
import 'package:simplex_calc/termino.dart';


//Clase que representa a la funcion objetivo
class FuncObjetivo implements EcuacionLineal
{
  late int numVariables;
  List<Termino> terminos=[];
  late String optimizacion;

  FuncObjetivo(this.numVariables,this.optimizacion,this.terminos);

  @override
  String toString() {
    String resultado = optimizacion + " Z = ";
    int x = 1;
    for(Termino termino in terminos)
    {
      resultado += " ${termino.toString()}X$x";
      x++;
    }
    return resultado.trim();
  }

  //Calcula la solución de la funcion dadas dos variables en una lista(Solo método gráfico)
  double calcularSolucion(List<double> variables)
  {
    double solucion = 0;
    
    for(int i = 0; i < terminos.length;i++)
    {
      solucion += variables[i]*terminos[i].valor;
    }
    return solucion;
  }

  @override
  double obtenerZ()
  {
    return 1.0;
  }

  @override
  List<double> obtenerVariables()
  {
    List<double> coeficientes = [];
    for(Termino termino in terminos)
    {
      coeficientes.add(-termino.valor);
    }
    return coeficientes;
  }

  @override
  double obtenerSolucion()
  {
    return 0.0;
  }

  @override
  String obtenerTipo()
  {
    return "func";
  }
}