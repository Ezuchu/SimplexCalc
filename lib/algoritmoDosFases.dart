
import 'package:simplex_calc/algoritmoSimplex.dart';
import 'package:simplex_calc/estandarizador.dart';
import 'package:simplex_calc/funcObjetivo.dart';
import 'package:simplex_calc/restriccion.dart';
import 'package:simplex_calc/tablaSimplex.dart';
import 'package:simplex_calc/termino.dart';

class AlgoritmoDosFases 
{
  late FuncObjetivo funcionOriginal;
  late List<Restriccion> restriccionesOriginales;
  late List<Restriccion> restriccionesArtificiales;
  late int numeroVariables;
  late AlgoritmoSimplex simplexFase1;
  late AlgoritmoSimplex simplexFase2;

  late List<TablaSimplex> tablasFase1;
  late List<TablaSimplex> tablasFase2;

  late List<List<double>> estandarInicial;
  late List<List<double>> estandarDosFases;

  late int numeroHolguras;
  late int numeroArtificiales;
  late List<int> indicesArtificiales = [];
  late List<int> indicesHolguras = [];

  late List<String> variablesFase1 = [];
  late List<String> variablesFase2 = [];

  List<int> variablesBasicasFase1 = [];
  List<int> variablesNoBasicasFase1 = [];

  List<int> variablesBasicasFase2 = [];
  List<int> variablesNoBasicasFase2 = [];

  bool esFactible = true;


  AlgoritmoDosFases(this.funcionOriginal, this.restriccionesOriginales)
  {
    this.numeroVariables = funcionOriginal.numVariables;
    this.restriccionesArtificiales = [];
    this.numeroHolguras = obtenerHolguras();
    this.numeroArtificiales = obtenerArtificiales();
    this.variablesFase1 = [];

    this.estandarInicial = [];
    this.estandarDosFases = [];

    crearVariables();
  }

  //Guarda el indice de las holguras en una lista
  int obtenerHolguras()
  {
    int cont = 0;

    for(Restriccion restriccion in restriccionesOriginales)
    {
      String igualdad = restriccion.obtenerTipo();
      if(igualdad == ">=" || igualdad == "<=")
      {
        cont++;
        indicesHolguras.add(numeroVariables+cont);
      }
    }
    return cont;
  }

  //Guarda el indice de las variables artificiales en una lista
  int obtenerArtificiales()
  {
    int cont = 0;
    int sumaHolguraVariables = numeroHolguras+numeroVariables;

    for(Restriccion restriccion in restriccionesOriginales)
    {
      String igualdad = restriccion.obtenerTipo();
      if(igualdad == ">=" || igualdad == "=")
      {
        cont++;
        indicesArtificiales.add(sumaHolguraVariables+cont);
        restriccionesArtificiales.add(restriccion);
      }
    }
    return cont;
  }

  //Guarda el nombre de las variables de la fase 1 en una lista
  void crearVariables()
  {
    for(int i = 1; i <= numeroVariables;i++)
    {
      variablesFase1.add("x$i");
    }
    for(int i = 1; i<= numeroHolguras;i++)
    {
      variablesFase1.add("S$i");
    }
    for(int i = 1; i<= numeroArtificiales;i++)
    {
      variablesFase1.add("R$i");
    }
  }

  void estandarizar()
  {
    int totalVariables = numeroVariables +numeroHolguras +numeroArtificiales;

    estandarInicial.clear();
    variablesNoBasicasFase1 = List.generate(numeroVariables,(i)=>i);

    int holgura = numeroHolguras<1? 0 : indicesHolguras.first-1;
    int artificial = numeroArtificiales<1?0 : indicesArtificiales.first-1;

    List<List<double>> rRestricciones = [];
    
    for(Restriccion restriccion in restriccionesOriginales)
    {
      switch(restriccion.obtenerTipo())
      {
        case "<=": estandarInicial.add(Estandarizador.estandarizar(restriccion, totalVariables, holgura));
            variablesBasicasFase1.add(holgura);
            holgura++;break;

        case "=": estandarInicial.add(Estandarizador.estandarizar(restriccion, totalVariables, holgura,artificial: artificial));
            variablesBasicasFase1.add(artificial);
            artificial++;
            rRestricciones.add(estandarInicial.last);break;

        case ">=": estandarInicial.add(Estandarizador.estandarizar(restriccion, totalVariables, holgura,artificial: artificial));
            variablesBasicasFase1.add(artificial);
            variablesNoBasicasFase1.add(holgura);
            holgura++;artificial++;
            rRestricciones.add(estandarInicial.last);break;
        default:
      }
    }
    //Obten la fila 1 de la suma de restricciones artificiales
    List<double> fila1 = sumarRestricciones(estandarInicial[0].length, rRestricciones);
    estandarInicial.insert(0, fila1);
  }

  List<double> sumarRestricciones(int largoEstandar, List<List<double>> r)
  {
    List<double> fila = List.generate(largoEstandar, (i)=>0);
    for(List<double> restriccion in r)
    {
      for(int i = 1; i < largoEstandar-numeroArtificiales-1; i++)
      {
        fila[i] = restriccion[i] + fila[i];
      }
      fila.last = restriccion.last+fila.last;
    }
    fila[0] = 1;
    return fila;
  }

  void resolver() {
    estandarizar();
    ejecutarFase1();

    
    if(simplexFase1.soluciones.isEmpty || existenArtificialesBasicas())
    {
      esFactible = false;
      return;
    }
    
    estandarizarFase2();
    actualizarNoBasicas();
    actualizarVariables();
    variablesBasicasFase2 = variablesBasicasFase1.map((variable)=>variable)
                                              .whereType<int>()
                                              .toList();
    
    
    ejecutarFase2();
    
  }

  bool existenArtificialesBasicas()
  {
    bool valido = false;
    bool salida = false;
    int conteo = 0;
    do
    {
      valido = false;
      for(int variable in variablesBasicasFase1)
      {
        if(indicesArtificiales.contains(variable+1))
        {
          valido = true;
        }
      }
      if(valido)
      {
        if(simplexFase1.tieneSolucionesMultiples() && conteo < simplexFase1.numeroSoluciones)
        {
          simplexFase1.resolverMultiple();
          conteo++;
        }else
        {
          return true;
        }
      }
    }while(valido != false);

    return valido;
  }
  
  void actualizarNoBasicas()
  {
    variablesNoBasicasFase2 = variablesNoBasicasFase1
        .map((variable) {
          if (!indicesArtificiales.contains(variable+1)) {
            return variable;
          }
          return null;
        })
        .whereType<int>()
        .toList();
  }

  void actualizarVariables()
  {
    variablesFase2 = variablesFase1.map((variable)
                          {
                            if(variable[0] != "R")
                            {
                              return variable;
                            }
                            return null;
                          })
                      .whereType<String>()
                      .toList();
  }

  

  void ejecutarFase1()
  {
    simplexFase1 = crearSimplexAuxiliarFase1("min",false);
    simplexFase1.resolver();
  }

  void ejecutarFase2()
  {
    simplexFase2 = crearSimplexAuxiliarFase2(funcionOriginal.optimizacion, true);
    corregirFila1();

    simplexFase2.estandar = estandarDosFases;
    simplexFase2.guardarTablaEnHistorial();

    simplexFase2.resolver();
  }

  //Genera el estandar para la tabla inicial de la fase 2
  void estandarizarFase2()
  {
    estandarDosFases.clear();
    estandarDosFases.add(Estandarizador.estandarizar(funcionOriginal,numeroVariables+numeroHolguras,0));
   
    for(int i = 1; i < estandarInicial.length; i++)
    {
      estandarDosFases.add(List.generate(numeroVariables+numeroHolguras+1, (v)=>
                estandarInicial[i][v]
              ));
      estandarDosFases.last.add(estandarInicial[i].last);
    }
  }

  //Corrige la primera fila si las variables basicas no tienen coeficiente 0 en Z
  void corregirFila1()
  {
    for(int i = 0; i < variablesBasicasFase2.length;i++)
    {
      int indiceVariable = variablesBasicasFase2[i]+1;
      if(estandarDosFases[0][indiceVariable] != 0)
      {
        restarFilas(estandarDosFases[0],estandarDosFases[i+1],estandarDosFases[0][indiceVariable]);
      }
    }
  }

  void restarFilas(List<double>fila1,List<double>filaI,double mult)
  {
    for(int i = 1; i < fila1.length;i++)
    {
      fila1[i] -= mult * filaI[i];
    }
  }

  AlgoritmoSimplex crearSimplexAuxiliarFase1(String modo, bool buscarMultiples)
  {
    AlgoritmoSimplex simplex = AlgoritmoSimplex(this.funcionOriginal, this.restriccionesOriginales);
    simplex.modo = modo;
    simplex.estandar = this.estandarInicial;
    simplex.variables = this.variablesFase1;
    simplex.estandarinicial = [];
    simplex.copiarEstandar(simplex.estandar, simplex.estandarinicial);
    simplex.variablesNoBasicas = this.variablesNoBasicasFase1;
    simplex.variablesBasicas = this.variablesBasicasFase1;
    simplex.guardarTablaEnHistorial();
    simplex.buscarMultiples = buscarMultiples;
    return simplex;
  }

  AlgoritmoSimplex crearSimplexAuxiliarFase2(String modo, bool buscarMultiples)
  {
    AlgoritmoSimplex simplex = AlgoritmoSimplex(this.funcionOriginal, this.restriccionesOriginales);
    simplex.modo = modo;
    simplex.estandar = this.estandarDosFases;
    simplex.variables = this.variablesFase2;
    simplex.estandarinicial = [];
    simplex.copiarEstandar(simplex.estandar, simplex.estandarinicial);
    simplex.variablesNoBasicas = this.variablesNoBasicasFase2;
    simplex.variablesBasicas = this.variablesBasicasFase2;
    simplex.guardarTablaEnHistorial();
    simplex.buscarMultiples = buscarMultiples;
    return simplex;
  }
}

void main()
{
  // Crear función objetivo: Maximizar Z = 3x1 + 2x2
  var terminosObj = [Termino(5), Termino(6)];
  var funcionObjetivo = FuncObjetivo(2, "max", terminosObj);
  
  // Crear restricciones:
  // x1 + x2 <= 4
  // 2x1 + x2 <= 5
  var terminosR1 = [Termino(1), Termino(2)];
  var restriccion1 = Restriccion(terminosR1, "<=", Termino(10));
  

  var terminosR2 = [Termino(3), Termino(4)];
  var restriccion2 = Restriccion(terminosR2, ">=", Termino(20));
  
  var simplex = AlgoritmoDosFases(funcionObjetivo, [restriccion1, restriccion2]);
  simplex.resolver();
  
}