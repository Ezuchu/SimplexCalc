import 'package:simplex_calc/ecuacionLineal.dart';

class Estandarizador 
{
  static List<double> estandarizar(EcuacionLineal ecuacion,int totalVariables,int holgura, {int artificial = 0})
  {
    List<double> estandar = [];
    estandar.add(ecuacion.obtenerZ());
    estandar.addAll(ecuacion.obtenerVariables());
    //3
    switch(ecuacion.obtenerTipo())
    {
      case "<=": for(int i = estandar.length-1; i < totalVariables;i++)//4
                {
                  
                  double coeficiente = i == holgura? 1.0 : 0.0;    
                  estandar.add(coeficiente);
                }break;
      case "==": for(int i = estandar.length-1;i < totalVariables;i++)
              {
                 double coeficiente = i == artificial? 1.0: 0.0;
                 estandar.add(coeficiente);
              }break;
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
      default:
        estandar.addAll(List.filled(totalVariables-estandar.length+1, 0.0));
    }
    estandar.add(ecuacion.obtenerSolucion());
    return estandar;
  }
}