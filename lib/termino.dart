class Termino
{
  late double valor;
  late double m = 0;

  Termino(this.valor, {this.m = 0});

  @override
  String toString() {
    String resultado = "";
    if (valor >= 0) {
      resultado += "+ ${valor.toStringAsFixed(2)}";
    } else {
      resultado += "- ${valor.abs().toStringAsFixed(2)}";
    }
    return resultado.trim();
  }
}