import 'package:simplex_calc/inputTermino.dart';

class InputRestriccion 
{
  List<InputTermino> terminos=[];
  String igualdad = "=";
  late InputTermino resultado;

  InputRestriccion(int numVariables,InputTermino resultado)
  {
    terminos = List.generate(numVariables, (int index){return InputTermino();});
    this.resultado = resultado;
  }

  void cambiarLista(int numVariables)
  {
    terminos.clear();
    terminos = List.generate(numVariables, (int index){return InputTermino();});
  }

  void cambiarVariables(int nVariables)
  {
    while(terminos.length < nVariables)
    {
      terminos.add(InputTermino());
    }
    while(terminos.length > nVariables)
    {
      terminos.removeLast();
    }
  }

  @override
  String toString() {
    String resultado = "";
    int x = 1;
    for(InputTermino termino in terminos)
    {
      resultado += " ${termino.signo} ${termino.valor}X$x";
      x++;
    }
    resultado += " $igualdad ${this.resultado.signo} ${this.resultado.valor}";
    return resultado.trim();
  }
}

