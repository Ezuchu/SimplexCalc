import 'package:simplex_calc/ecuacionLineal.dart';


//Clase para estandarizar funciones y restricciones
class Estandarizador 
{
  static List<double> estandarizar(EcuacionLineal ecuacion,int totalVariables,int holgura, {int artificial = 0})
  {
    List<double> estandar = [];
    estandar.add(ecuacion.obtenerZ());
    estandar.addAll(ecuacion.obtenerVariables());

    //Estandariza deacuerdo al tipo de ecuacion
    switch(ecuacion.obtenerTipo())
    {
      //Contiene una holgura
      case "<=": for(int i = estandar.length-1; i < totalVariables;i++)
                {
                  
                  double coeficiente = i == holgura? 1.0 : 0.0;    
                  estandar.add(coeficiente);
                }break;
      //Contiene una variable artificial
      case "==": for(int i = estandar.length-1;i < totalVariables;i++)
              {
                 double coeficiente = i == artificial? 1.0: 0.0;
                 estandar.add(coeficiente);
              }break;
      //Contiene una variable artificial menos una holgura
      case ">=": for(int i = estandar.length-1;i < totalVariables;i++)
              {
                 double coeficiente = 0.0;
                 if(i == holgura)
                 {
                    coeficiente = -1.0;
                 }else if(i == artificial)
                 {
                    coeficiente = 1.0;
                 }
                 estandar.add(coeficiente);
              }break;
      //Función Objetivo
      default:
        estandar.addAll(List.filled(totalVariables-estandar.length+1, 0.0));
    }
    
    estandar.add(ecuacion.obtenerSolucion());
    return estandar;
  }
}