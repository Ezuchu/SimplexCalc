
import 'package:flutter/material.dart';
import 'package:simplex_calc/algoritmoDosFases.dart';
import 'package:simplex_calc/algoritmoSimplex.dart';
import 'package:simplex_calc/tablaSimplex.dart';

//Pantalla del método Dos fases
class PantallaDosFases extends StatelessWidget
{
  final AlgoritmoDosFases dosFases;
  late List<List<String>> listaFilasSuperiores =[[],[]];
  

  PantallaDosFases({super.key,required this.dosFases})
  {
    //Crea un encabezado para cada fase
    crearFilaSuperior(listaFilasSuperiores[0], dosFases.variablesFase1);
    if(dosFases.variablesFase2.isNotEmpty)
    {
      crearFilaSuperior(listaFilasSuperiores[1], dosFases.variablesFase2);
    }
  }

  void crearFilaSuperior(List<String> filaSuperior,List<String>? variables)
  {
    filaSuperior.clear();
    filaSuperior.add("Z");
    filaSuperior.addAll(variables!);
    filaSuperior.add("Sol");
  }

  Color colorCelda(TablaSimplex tabla, int fila, int columna)
  {
    if(fila == tabla.filaPivote && columna == tabla.columnaPivote)
    {
      return Colors.cyan;
    }
    if(fila == tabla.filaPivote || columna == tabla.columnaPivote)
    {
      return Colors.lightGreen;
    }
    return Colors.white;
  }

  Widget _buildTabla(TablaSimplex tabla, List<String> variables,List<String> variablesBasicas,int fase) {
    List<List<double>> datos = tabla.datos;
    int numCols = datos.isNotEmpty ? datos[0].length : variables.length + 1;
    
    return Table(
      border: TableBorder.all(),
      children: [
        TableRow(
          children: [
            const TableCell(child: Padding(
              padding: EdgeInsets.all(4.0),
              child: Text(''),
            )),
            ...List.generate(numCols, (i) => TableCell(
              child: Padding(
                padding: EdgeInsets.all(4.0),
                child: Text(listaFilasSuperiores[fase][i],
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            )),
          ],
        ),
        ...List.generate(datos.length, (i) {
          return TableRow(
            children: [
              TableCell(child: Padding(
                padding: EdgeInsets.all(4.0),
                child: Text(variablesBasicas[i]),
              )),
              ...List.generate(datos[i].length, (int v) =>
              TableCell(child: Padding(
                padding: EdgeInsets.all(4.0),
                child: Container(decoration: BoxDecoration(color:colorCelda(tabla, i, v)),child: Text(datos[i][v].toStringAsFixed(2))),
              ))),
            ],
          );
        }),
      ],
    );
}

  Widget _buildHistorial(AlgoritmoSimplex simplex,int fase) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Iteraciones:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        ...List.generate(simplex.historialTablas.length, (i) {
          final tabla = simplex.historialTablas[i];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Iteración ${i + 1}'),
              _buildTabla(tabla, simplex.variables,tabla.variablesBasicas,fase),
              const SizedBox(height: 12),
            ],
          );
        }),
      ],
    );
  }

  Widget _buildSolucion(AlgoritmoSimplex simplex) {
    if(simplex.noAcotado && simplex.modo == "max")
    {
      return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [Text('El problema no tiene solución acotada', style: const TextStyle(fontWeight: FontWeight.bold))],
    );
    }
    List<Widget> resultados = [];
    List<List<List<double>>> soluciones = simplex.soluciones;
    List<TablaSimplex> tablas = simplex.historialOptimas;
    for(int i = 0; i < soluciones.length;i++)
    {
      resultados.add(Text('Valor óptimo de Z: ${simplex.estandar[0].last.toStringAsFixed(2)}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24)));
      for (int j = 0; j < tablas[i].variablesBasicas.length; j++) {
        
        resultados.add(Text('${tablas[i].variablesBasicas[j]} = ${soluciones[i][j].last.toStringAsFixed(2)}', style: TextStyle(fontSize: 24)));
      }
      
      resultados.add(SizedBox(height: 24,));
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: resultados,
    );
  }

  Widget mostrarEstandar(AlgoritmoSimplex simplex, int iFila)
  {
    String estandar = "";
    List<double> fila = simplex.estandarinicial[iFila];
    
    for(int i = 0; i < simplex.estandarinicial[0].length-1;i++)
    {
      estandar+= fila[i] < 0? "${fila[i].toStringAsFixed(2)}" : "+${fila[i].toStringAsFixed(2)}"; 
      estandar+="${listaFilasSuperiores[0][i]} ";

    }
    estandar += " = ${fila.last.toStringAsFixed(2)}";
    return Text(estandar, style: TextStyle(fontSize: 16));
  }

  List<Widget> generarFase2()
  {
    if(!dosFases.esFactible)//Corta el ejercicio si no es factible
    {
      return [Text("No existe solución factible", style: TextStyle(fontSize: 18),)];
    }else
    {
      List<Widget> widgets = [];
      widgets.addAll(
              [const SizedBox(height: 24),
              const Text('Fase 2:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
              ...List.generate(dosFases.simplexFase2.estandarinicial.length, (e)=>
                      mostrarEstandar(dosFases.simplexFase2, e)
                    ),

              _buildHistorial(dosFases.simplexFase2,1),
              const SizedBox(height: 24),
              
              const Text('Solución:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              _buildSolucion(dosFases.simplexFase2)]);
      return widgets;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dos Fases - Desarrollo')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Función Objetivo:", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  Text(dosFases.funcionOriginal.toString(), style: TextStyle(fontSize: 16)),

            Text("Restricciones:", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  ...dosFases.restriccionesOriginales.map((r) =>
                    Text(r.toString(), style: TextStyle(fontSize: 16))).toList(),

            Text("Estandar:", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  ...List.generate(dosFases.simplexFase1.estandarinicial.length, (e)=>
                    mostrarEstandar(dosFases.simplexFase1, e)
                  ),

            const Text('Fase 1:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
            ...List.generate(dosFases.simplexFase1.estandarinicial.length, (e)=>
                      mostrarEstandar(dosFases.simplexFase1, e)
                    ),

              _buildHistorial(dosFases.simplexFase1,0),
            ...generarFase2()
          ],
        ),
      ),
    );
  }
}