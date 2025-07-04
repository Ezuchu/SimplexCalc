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

  void resolver()
  {
    estandarizar();
    while (!esOptimo()) {
      int columnaPivote = encontrarColumnaPivote();
      int filaPivote = encontrarFilaPivote(columnaPivote);
      
      if (filaPivote == -1) {
        print("\nEl problema no tiene solución acotada.");
        return;
      }
      
      // Registrar variables antes de actualizar
      String variableEntrante = variables[columnaPivote];
      String variableSaliente = variables[variablesBasicas[filaPivote - 1]];
      double valorPivote = estandar[filaPivote][columnaPivote];
      
      actualizarVariablesBasicas(filaPivote, columnaPivote);
      pivotear(filaPivote, columnaPivote);
      
      // Guardar tabla en el historial con información del pivote
      guardarTablaEnHistorial(
        filaPivote: filaPivote,
        columnaPivote: columnaPivote,
        variableEntrante: variableEntrante,
        variableSaliente: variableSaliente,
        valorPivote: valorPivote,
      );
    }
    mostrarSolucion();
    mostrarHistorial();
  }

  bool esOptimo() {
    // Verificar si todos los coeficientes en la fila Z son no negativos (para maximización)
    for (int j = 0; j < estandar[0].length - 1; j++) {
      if (estandar[0][j] < 0) return false;
    }
    return true;
  }

  int encontrarColumnaPivote() {
    // Encontrar la columna con el coeficiente más negativo en la fila Z
    double minValor = 0;
    int columnaPivote = 0;
    
    for (int j = 0; j < estandar[0].length - 1; j++) {
      if (estandar[0][j] < minValor) {
        minValor = estandar[0][j];
        columnaPivote = j;
      }
    }
    
    return columnaPivote;
  }

  int encontrarFilaPivote(int columnaPivote) {
    // Encontrar la fila con la menor razón positiva (columna solución / columna pivote)
    double minRazon = double.infinity;
    int filaPivote = -1;
    
    for (int i = 1; i < estandar.length; i++) {
      if (estandar[i][columnaPivote] > 0) {
        double razon = estandar[i].last / estandar[i][columnaPivote];
        if (razon < minRazon) {
          minRazon = razon;
          filaPivote = i;
        }
      }
    }
    
    return filaPivote;
  }

  void pivotear(int filaPivote, int columnaPivote) {
    // Normalizar la fila pivote
    double pivote = estandar[filaPivote][columnaPivote];
    for (int j = 0; j < estandar[filaPivote].length; j++) {
      estandar[filaPivote][j] /= pivote;
    }
    
    // Actualizar las demás filas
    for (int i = 0; i < estandar.length; i++) {
      if (i != filaPivote) {
        double factor = estandar[i][columnaPivote];
        for (int j = 0; j < estandar[i].length; j++) {
          estandar[i][j] -= factor * estandar[filaPivote][j];
        }
      }
    }
  }

  void actualizarVariablesBasicas(int filaPivote, int columnaPivote) {
    // Reemplazar la variable básica en la fila pivote con la variable de la columna pivote
    variablesBasicas[filaPivote - 1] = columnaPivote;
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

  void mostrarSolucion() {
    print("\nSolución óptima encontrada:");
    print("Valor de Z: ${estandar[0].last.toStringAsFixed(2)}");
    
    // Mostrar valores de variables básicas
    for (int i = 0; i < variablesBasicas.length; i++) {
      int varIndex = variablesBasicas[i];
      print("${variables[varIndex]} = ${estandar[i + 1].last.toStringAsFixed(2)}");
    }
    
    // Mostrar variables no básicas (iguales a 0)
    for (int j = 0; j < numeroVariables; j++) {
      if (!variablesBasicas.contains(j)) {
        print("${variables[j]} = 0.00");
      }
    }
  }

  void mostrarHistorial() {
    print("\nHistorial completo de tablas:");
    for (int i = 0; i < historialTablas.length; i++) {
      print("\nIteración ${i + 1}:");
      print(historialTablas[i].toString());
    }
  }

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
  simplex.resolver();
}