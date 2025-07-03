import 'package:simplex_calc/estandarizador.dart';
import 'package:simplex_calc/funcObjetivo.dart';
import 'package:simplex_calc/restriccion.dart';
import 'package:simplex_calc/tablaSimplex.dart';
import 'package:simplex_calc/termino.dart';

class AlgoritmoSimplex 
{
  late FuncObjetivo funcion;
  late List<Restriccion> restricciones;
  late List<List<double>> estandar;
  late List<String> variables;
  
  late int numeroHolguras;
  late int numeroVariables;
  late List<int> indicesHolguras;
  late List<int> variablesBasicas;
  late List<int> variablesNoBasicas;

  late List<TablaSimplex> historialTablas;

  AlgoritmoSimplex(this.funcion,this.restricciones)
  {
    this.numeroHolguras = this.restricciones.length;
    this.numeroVariables = funcion.numVariables;
    this.estandar = [];
    this.indicesHolguras = [];
    this.variablesBasicas = [];
    this.variablesNoBasicas = [];
    this.variables = [];
    this.historialTablas = [];

    this.crearVariables();
  }

  void crearVariables()
  {
    for(int i = 1; i <= numeroVariables;i++)
    {
      variables.add("x$i");
    }
    for(int i = 1; i <= numeroHolguras; i++)
    {
      variables.add("S$i");
    }
  }

  void estandarizar()
  {
    estandar.clear();
    estandar.add(Estandarizador.estandarizar(funcion,numeroVariables+numeroHolguras,0));

    variablesBasicas = List.generate(numeroHolguras, (i) => numeroVariables + i);
    variablesNoBasicas = List.generate(numeroVariables, (i) => i);

    for(int s = 0; s < numeroHolguras; s++)
    {
      indicesHolguras.add(s + 1 + numeroVariables);
      print(s+1+numeroVariables);
      estandar.add(Estandarizador.estandarizar(restricciones[s],numeroVariables+numeroHolguras,s+numeroVariables));
    }
    
    

    guardarTablaEnHistorial();
  }

  void guardarTablaEnHistorial({
    int filaPivote = -1,
    int columnaPivote = -1,
    String variableEntrante = '',
    String variableSaliente = '',
    double valorPivote = 0.0,
  }) {
    // Hacer una copia profunda de la tabla actual
    List<List<double>> copiaTabla = [];
    for (var fila in estandar) {
      copiaTabla.add(List.from(fila));
    }
    
    historialTablas.add(TablaSimplex(
      datos: copiaTabla,
      filaPivote: filaPivote,
      columnaPivote: columnaPivote,
      variableEntrante: variableEntrante,
      variableSaliente: variableSaliente,
      valorPivote: valorPivote,
    ));
  }

  // Ejemplo de uso

}

void main() {
  // Crear función objetivo: Maximizar Z = 3x1 + 2x2
  var terminosObj = [Termino(3), Termino(2)];
  var funcionObjetivo = FuncObjetivo(2, "Maximizar", terminosObj);
  
  // Crear restricciones:
  // x1 + x2 <= 4
  // 2x1 + x2 <= 5
  var terminosR1 = [Termino(1), Termino(1)];
  var restriccion1 = Restriccion(terminosR1, "<=", Termino(4));
  

  var terminosR2 = [Termino(2), Termino(1)];
  var restriccion2 = Restriccion(terminosR2, "<=", Termino(5));
  
  var simplex = AlgoritmoSimplex(funcionObjetivo, [restriccion1, restriccion2]);
  simplex.estandarizar();
  print(simplex.historialTablas[0]);
}