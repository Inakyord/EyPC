public  class Automata{

  //Autores: Ordiales Caballero, Iñaky

  static void procesaCadena(String cadena){
    // q = δ*(q0,w)
    System.out.println("\n");
    int q = delta_extendida(0,cadena);
    if(q==5){
      System.out.println("\n Cadena aceptada");
    }else{
      System.out.println("\n Cadena rechazada");
    }
    if(q==-1){
      System.out.println(" La cadena contiene simbolos que no son del abecedario.");
    }
  }

  /** Implementación de la función δ* */
  private static int delta_extendida(int estado_actual,String cadena){
    // Si ya no hay símbolos en la entrada
    // Caso base: δ*(q,λ) = q
    if(cadena=="") {
      System.out.println("δ*("+estado_actual+",λ)");
      return estado_actual;
    }

    // Si aún hay símbolos en la entrada
    // Se lee el siguiente símbolo
    char siguiente_simbolo = cadena.charAt(0);
    String resto_cadena = null;
    if(cadena.length()==1) //ya no hay más símbolos
      resto_cadena = "";
    else // el resto de la cadena es la sucadena a partir de la segunda posición
      resto_cadena = cadena.substring(1);
    // Caso recursivo:
    // δ*(q,σw) = δ*(δ(q,σ), w)
    System.out.println("δ*(δ("+estado_actual+","+siguiente_simbolo+"),"+(resto_cadena==""?"λ":resto_cadena)+")");
    return delta_extendida(delta(estado_actual,siguiente_simbolo),resto_cadena);
  }

  /** Implementación de la función δ (transiciones entre estados)
   * @param estado actual
   * @param simbolo leido
   * @return el estado siguiente */
  private static int delta(int estado,char simbolo){
    
    switch(estado){
      case 0:
        if(simbolo=='/')
          return 1;
        else if(simbolo=='a')
          return -2;
        else if(simbolo=='b')
          return -2;
        else if(simbolo=='*')
          return -2;
        return -1;

      case 1:
        if(simbolo=='*')
          return 2;
        else if(simbolo=='a')
          return -2;
        else if(simbolo=='b')
          return -2;
        else if(simbolo=='/')
          return -2;
        return -1;

      case 2:
        if(simbolo=='a')
          return 2;
        else if(simbolo=='b')
          return 2;
        else if(simbolo=='/')
          return 3;
        else if(simbolo=='*')
          return 4;
        return -1;

      case 3:
        if(simbolo=='a')
          return 2;
        else if(simbolo=='b')
          return 2;
        else if(simbolo=='/')
          return 3;
        else if(simbolo=='*')
          return -2;
        return -1;

      case 4:
        if(simbolo=='a')
          return 2;
        else if(simbolo=='b')
          return 2;
        else if(simbolo=='*')
          return 4;
        else if(simbolo=='/')
          return 5;
        return -1;

      case 5:
        if(simbolo=='/')
          return 6;
        else if(simbolo=='a')
          return -2;
        else if(simbolo=='b')
          return -2;
        else if(simbolo=='*')
          return -2;
        return -1;

      case 6:
        if(simbolo=='*')
          return 2;
        else if(simbolo=='a')
          return -2;
        else if(simbolo=='b')
          return -2;
        else if(simbolo=='/')
          return -2;
        return -1;

      case -2:
        return -2;

      default:
        return -1;
    }
  }

  public static void main(String[] args){
    if(args.length==1){
      Automata.procesaCadena(args[0]);
    }else{
      System.out.println("Uso: java Automata <cadena de entrada>");
    }

  }

}