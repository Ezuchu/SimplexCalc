import 'package:simplex_calc/termino.dart';

class Restriccion 
{
  List<Termino> terminos=[];
  String igualdad = "=";
  late Termino resultado;

  Restriccion(int numVariables,Termino resultado)
  {
    terminos = List.generate(numVariables, (int index){return Termino();});
    this.resultado = resultado;
  }

  void cambiarLista(int numVariables)
  {
    terminos.clear();
    terminos = List.generate(numVariables, (int index){return Termino();});
  }
}