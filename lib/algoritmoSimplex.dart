import 'package:simplex_calc/estandarizador.dart';
import 'package:simplex_calc/funcObjetivo.dart';
import 'package:simplex_calc/restriccion.dart';
import 'package:simplex_calc/tablaSimplex.dart';
import 'package:simplex_calc/termino.dart';


class AlgoritmoSimplex 
{
  static const double TOLERANCIA = 1e-10;

  late FuncObjetivo funcion;
  late List<Restriccion> restricciones;
  late String modo;
  late List<List<double>> estandarinicial;
  late List<List<double>> estandar;
  late List<String> variables;

  
  late int numeroHolguras;
  late int numeroVariables;
  late List<int> indicesHolguras;
  late List<int> variablesBasicas;
  late List<int> variablesNoBasicas;

  late List<TablaSimplex> historialTablas;
  bool noAcotado = false;
  late List<TablaSimplex> historialOptimas;
  late List<List<List<double>>> soluciones;
  int numeroSoluciones = 0;

  bool buscarMultiples = true;

  AlgoritmoSimplex(this.funcion,this.restricciones)
  {
    this.numeroHolguras = this.restricciones.length;
    this.numeroVariables = funcion.numVariables;
    this.modo = funcion.optimizacion;
    this.estandar = [];
    this.estandarinicial = [];
    this.indicesHolguras = [];
    this.variablesBasicas = [];
    this.variablesNoBasicas = [];
    this.variables = [];
    this.historialTablas = [];
    this.historialOptimas = [];
    this.soluciones = [];

    this.crearVariables();
  }

  //Guarda el nombre de las variables en una lista
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
      
      estandar.add(Estandarizador.estandarizar(restricciones[s],numeroVariables+numeroHolguras,s+numeroVariables));
    }
    //Guarda el primer estandarizado
    copiarEstandar(estandar, estandarinicial);
    guardarTablaEnHistorial();
  }

  void copiarEstandar(List<List<double>> lInicial, List<List<double>> lFinal)
  {
    for(List<double> fila in lInicial)
    {
      lFinal.add(List<double>.empty(growable: true));
      for(double coeficiente in fila)
      {
        lFinal.last.add(coeficiente);
      }
    }
  }

  void resolver()
  {
    if(estandar.isEmpty)
    {
      estandarizar();
    }

    while (!esOptimo()) {
      int columnaPivote = encontrarColumnaPivote();
      int filaPivote = encontrarFilaPivote(columnaPivote);

      if (filaPivote == -1) {
        noAcotado = true;
        print("\nEl problema no tiene solución acotada.");
        mostrarHistorial();
        print(estandar[0]);
        return;
      }

      generarTabla(columnaPivote, filaPivote);
    }
    while(tieneSolucionesMultiples() && buscarMultiples)
    {
      resolverMultiple();
    }

    mostrarHistorial();
  }

  void resolverMultiple()
  {
    int columnaPivote = encontrarColumnaPivoteMultiple();
    int filaPivote = encontrarFilaPivote(columnaPivote);
    if (filaPivote == -1) {
        noAcotado = true;
        print("\nEl problema no tiene solución acotada.");
        return;
    }

    generarTabla(columnaPivote, filaPivote);
    esOptimo();
  }

  void generarTabla(int columnaPivote, int filaPivote)
  {
    // Registrar variables antes de actualizar
    String variableEntrante = variables[columnaPivote-1];
    String variableSaliente = variables[variablesBasicas[filaPivote - 1]];
    double valorPivote = estandar[filaPivote][columnaPivote];
    TablaSimplex tablaAnterior = historialTablas.last;    
      

    actualizarVariablesBasicas(filaPivote, columnaPivote);
    pivotear(filaPivote, columnaPivote);

    tablaAnterior.variableEntrante = variableEntrante;
    tablaAnterior.variableSaliente = variableSaliente;
    tablaAnterior.valorPivote = valorPivote;
    tablaAnterior.columnaPivote = columnaPivote;
    tablaAnterior.filaPivote = filaPivote;
      
    // Guardar tabla en el historial con información del pivote
    guardarTablaEnHistorial();
  }


  bool esOptimo() {
    bool esOptimo = true;
    //Verifica si es optimo segun la optimizacion
    switch(modo)
    {
      case "max": esOptimo = esOptimoMax();break;
      case "min": esOptimo = esOptimoMin();break;
      default:
    }

    if(!esOptimo){return false;}

    historialOptimas.add(historialTablas.last);

    numeroSoluciones++;
    List<List<double>> solucion = [];

    copiarEstandar(estandar, solucion);
    soluciones.add(solucion);

    return true;
  }

  bool esOptimoMax()
  {
    for (int j = 1; j < estandar[0].length - 1; j++) {
      if (_esNegativo(estandar[0][j])&& !_esCero(estandar[0][j])) return false;
    }
    return true;
  }

  bool esOptimoMin()
  {
    for (int j = 1; j < estandar[0].length - 1; j++) {
      if (_esPositivo(estandar[0][j]) && !_esCero(estandar[0][j])) return false;
    }
    return true;
  }

  int encontrarColumnaPivote() {
    // Encontrar la columna con el coeficiente más negativo o positivo en la fila Z
    int columnaPivote = 0;
    switch(modo)
    {
      case "max": columnaPivote = encontrarColumnaMax();break;
      case "min": columnaPivote = encontrarColumnaMin();break;
    }
    return columnaPivote;
    
  }

  int encontrarColumnaMax()
  {
    double minValor = 0;
    int columnaPivote = 0;
    
    for (int j = 1; j < estandar[0].length - 1; j++) {
      if (estandar[0][j] < minValor && _esNegativo(estandar[0][j])) {
        minValor = estandar[0][j];
        columnaPivote = j;
      }
    }
    return columnaPivote;
  }

  int encontrarColumnaMin()
  {
    double maxValor = 0;
    int columnaPivote = 0;
    
    for (int j = 1; j < estandar[0].length - 1; j++) {
      if (estandar[0][j] > maxValor && _esPositivo(estandar[0][j])) {
        maxValor = estandar[0][j];
        columnaPivote = j;
      }
    }
    return columnaPivote;
  }

  int encontrarFilaPivote(int columnaPivote) {
    
    double minRazon = double.infinity;
    int filaPivote = -1;
    
    for (int i = 1; i < estandar.length; i++) {
      if (_esPositivo(estandar[i][columnaPivote])) {
        double razon = estandar[i].last / estandar[i][columnaPivote];
        if (razon < minRazon && razon > -TOLERANCIA) {
          minRazon = razon;
          filaPivote = i;
        }
      }
    }
    
    return filaPivote;
  }

  int encontrarColumnaPivoteMultiple() {
    // Encontrar la columna con el coeficiente más negativo en la fila Z
    double minValor = 0;
    int columnaPivote = 0;
    
    for (int j = 0; j < estandar[0].length - 1; j++) {
      if (estandar[0][j] <= minValor && variablesNoBasicas.contains(j-1)) {
        minValor = estandar[0][j];
        columnaPivote = j;
      }
    }
    
    return columnaPivote;
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
    int idx = filaPivote -1;
    int variableSaliente = variablesBasicas[idx];
    variablesBasicas[idx] = columnaPivote-1; 

    int idxNoBasica = variablesNoBasicas.indexOf(columnaPivote-1);
    if(idxNoBasica != -1)
    {
      variablesNoBasicas[idxNoBasica] = variableSaliente;
    }
  }

  bool tieneSolucionesMultiples()
  {
    int conteo = 0;
    //Busca si alguna variable no basica tiene coeficiente 0 en Z
    for(int j = 0; j < estandar[0].length;j++)
    {
      if (variablesNoBasicas.contains(j-1) && _esCero(estandar[0][j])) {
        conteo++;
      }
    }

    if(numeroSoluciones == 0)
    {
      return false;
    }
    
    if(numeroSoluciones <= conteo)
    {
      return true;
    }
    
    return false;
  }

  void guardarTablaEnHistorial({
    int filaPivote = -1,
    int columnaPivote = -1,
    String variableEntrante = '',
    String variableSaliente = '',
    double valorPivote = 0.0,
    }) {
    List<List<double>> copiaTabla = [];
    for (var fila in estandar) {
      copiaTabla.add(List.from(fila));
    }
    // Copia los nombres de las variables básicas actuales
    List<String> nombresBasicas = ['Z'];
    for (var idx in variablesBasicas) {
      nombresBasicas.add(variables[idx]);
    }

    historialTablas.add(TablaSimplex(
      datos: copiaTabla,
      filaPivote: filaPivote,
      columnaPivote: columnaPivote,
      variableEntrante: variableEntrante,
      variableSaliente: variableSaliente,
      valorPivote: valorPivote,
      variablesBasicas: nombresBasicas, // <-- NUEVO
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

    bool _esCero(double valor) => valor.abs() < TOLERANCIA;
    bool _esPositivo(double valor) => valor > -TOLERANCIA;
    bool _esNegativo(double valor) => valor < TOLERANCIA;

  

}

void main() {

  var terminosObj = [Termino(3), Termino(2)];
  var funcionObjetivo = FuncObjetivo(2, "Maximizar", terminosObj);
  

  var terminosR1 = [Termino(1), Termino(1)];
  var restriccion1 = Restriccion(terminosR1, "<=", Termino(4));
  

  var terminosR2 = [Termino(2), Termino(1)];
  var restriccion2 = Restriccion(terminosR2, "<=", Termino(5));
  
  var simplex = AlgoritmoSimplex(funcionObjetivo, [restriccion1, restriccion2]);
  simplex.resolver();
}