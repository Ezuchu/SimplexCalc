import 'package:simplex_calc/termino.dart';

class FuncObjetivo
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

  double calcularSolucion(List<double> variables)
  {
    double solucion = 0;
    
    for(int i = 0; i < terminos.length;i++)
    {
      print(i);
      solucion += variables[i]*terminos[i].valor;
    }
    return solucion;
  }
}