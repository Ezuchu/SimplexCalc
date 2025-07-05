class TablaSimplex 
{
  List<List<double>> datos;
  int filaPivote;
  int columnaPivote;
  String variableEntrante;
  String variableSaliente;
  double valorPivote;
  List<String> variablesBasicas;

  TablaSimplex({
    required this.datos,
    this.filaPivote = -1,
    this.columnaPivote = -1,
    this.variableEntrante = '',
    this.variableSaliente = '',
    this.valorPivote = 0.0,
    required this.variablesBasicas
  });

  String toString() {
    String result = '';
    for (var fila in datos) {
      result += fila.map((e) => e.toStringAsFixed(2)).join('\t') + '\n';
    }
    if (filaPivote != -1) {
      result += '\nPivote: [$filaPivote][$columnaPivote] = $valorPivote\n';
      result += 'Variable entrante: $variableEntrante\n';
      result += 'Variable saliente: $variableSaliente\n';
    }
    return result;
  }

}