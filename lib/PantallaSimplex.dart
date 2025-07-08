import 'package:flutter/material.dart';
import 'package:simplex_calc/algoritmoSimplex.dart';
import 'package:simplex_calc/tablaSimplex.dart';

//Pantalla del método simplex
class PantallaSimplex extends StatelessWidget {
  final AlgoritmoSimplex simplex;
  late List<String> filaSuperior;

  PantallaSimplex({super.key, required this.simplex})
  {
    this.filaSuperior = [];
    crearFilaSuperior();
  }

  void crearFilaSuperior()
  {
    filaSuperior.add("Z");
    filaSuperior.addAll(simplex.variables);
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

  Widget _buildTabla(TablaSimplex tabla, List<String> variables,List<String> variablesBasicas) {

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
                child: Text(filaSuperior[i],
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

  Widget _buildHistorial() {
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
              _buildTabla(tabla, simplex.variables,tabla.variablesBasicas),
              const SizedBox(height: 12),
            ],
          );
        }),
      ],
    );
  }

  Widget _buildSolucion() {
    if(simplex.noAcotado)
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

  Widget mostrarEstandar(int iFila)
  {
    String estandar = "";
    List<double> fila = simplex.estandarinicial[iFila];
    
    for(int i = 0; i < simplex.estandarinicial[0].length-1;i++)
    {
      estandar+= fila[i] < 0? "${fila[i].toStringAsFixed(2)}" : "+${fila[i].toStringAsFixed(2)}"; 
      estandar+="${filaSuperior[i]} ";

    }
    estandar += " = ${fila.last.toStringAsFixed(2)}";
    return Text(estandar, style: TextStyle(fontSize: 16));
  }

  //Constructor de pantalla
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Simplex - Desarrollo')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Función Objetivo:", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  Text(simplex.funcion.toString(), style: TextStyle(fontSize: 16)),
                  
            Text("Restricciones:", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  ...simplex.restricciones.map((r) =>
                    Text(r.toString(), style: TextStyle(fontSize: 16))).toList(),

            Text("Estandar:", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  ...List.generate(simplex.estandarinicial.length, (e)=>
                    mostrarEstandar(e)
                  ),

            _buildHistorial(),
            const SizedBox(height: 24),
            const Text('Solución:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
            _buildSolucion(),
          ],
        ),
      ),
    );
  }
}

