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

  Widget _buildTabla(List<List<double>> tabla, List<String> variables) {
    
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
                child: Text(i == 0 ? 'Z' : 'F${i}'),
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
              _buildTabla(tabla.datos, simplex.variables),
              const SizedBox(height: 12),
            ],
          );
        }),
      ],
    );
  }

  Widget _buildSolucion() {
    List<Widget> resultados = [];
    resultados.add(Text('Valor óptimo de Z: ${simplex.estandar[0].last.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)));
    for (int i = 0; i < simplex.variablesBasicas.length; i++) {
      int varIndex = simplex.variablesBasicas[i];
      resultados.add(Text('${simplex.variables[varIndex]} = ${simplex.estandar[i + 1].last.toStringAsFixed(2)}'));
    }
    for (int j = 0; j < simplex.numeroVariables; j++) {
      if (!simplex.variablesBasicas.contains(j)) {
        resultados.add(Text('${simplex.variables[j]} = 0.00'));
      }
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
            const Text('Tabla Estandarizada:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            _buildTabla(simplex.estandar, simplex.variables),
            const SizedBox(height: 24),
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