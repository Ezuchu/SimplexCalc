import 'package:flutter/material.dart';
import 'package:simplex_calc/algoritmoSimplex.dart';
import 'package:simplex_calc/tablaSimplex.dart';

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

  Widget _buildTabla(List<List<double>> tabla, List<String> variables,List<String> variablesBasicas) {
    
    int numCols = tabla.isNotEmpty ? tabla[0].length : variables.length + 1;
    
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
        ...List.generate(tabla.length, (i) {
          return TableRow(
            children: [
              TableCell(child: Padding(
                padding: EdgeInsets.all(4.0),
                child: Text(variablesBasicas[i]),
              )),
              ...tabla[i].map((v) => TableCell(child: Padding(
                padding: EdgeInsets.all(4.0),
                child: Text(v.toStringAsFixed(2)),
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
              _buildTabla(tabla.datos, simplex.variables,tabla.variablesBasicas),
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
      resultados.add(Text('Valor óptimo de Z: ${simplex.estandar[0].last.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)));
      for (int j = 0; j < tablas[i].variablesBasicas.length; j++) {
        
        resultados.add(Text('${tablas[i].variablesBasicas[j]} = ${soluciones[i][j].last.toStringAsFixed(2)}'));
      }
      
      resultados.add(SizedBox(height: 24,));
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: resultados,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Simplex - Desarrollo')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /*const Text('Tabla Estandarizada:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            _buildTabla(simplex.estandar, simplex.variables),
            const SizedBox(height: 24),*/
            _buildHistorial(),
            const SizedBox(height: 24),
            const Text('Solución:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            _buildSolucion(),
          ],
        ),
      ),
    );
  }
}

