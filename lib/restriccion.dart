import 'package:simplex_calc/termino.dart';

class Restriccion 
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
}