class InputTermino
{
  String signo = "+";
  String valor = "";

  InputTermino();

  void cambiarSigno()
  {
    signo == "+"? signo = "-" : signo = "+"; 
  }

  void cambiarValor(String nuevoValor)
  {
    print("valor: $valor, nuevoValor: $nuevoValor");
    valor = nuevoValor;
  }
}