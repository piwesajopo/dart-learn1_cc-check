# Análisis del Código Fuente de cc-check

## Punto de entrada del programa

Un programa Dart tiene la función `main()`como punto de entrada. Esto significa que la aplicación comenzará ejecutando la función `main()`. En este caso, el programa es un ejecutable de línea de comandos y utiliza un parámetro de entrada, por lo que la función principal tiene la siguiente definición:

```dart
// Una función principal que recibe parámetros de línea de comandos
void main(List<string> args) {
}
```

Notarás que `main()` tiene un tipo de retorno void. Los programas de línea de comandos siempre devuelven un código de resultado, y en muchos lenguajes, `main()` especificará un valor de retorno de tipo `int`. Dart es diferente, no se hace un `return` al final del programa. Los programas terminarán con el código de salida 0 a menos que llames a la función `exit()` con otro valor.

Cuando defines `main` de esta manera, los parámetros de entrada se recibirán en la variable `args`, que es de tipo `List<string>`. Esto facilita validar cuántos parámetros recibiste, así como acceder a los parámetros individualmente. Veremos cómo se hace esto en la siguiente sección.

## Manejo de parámetros de línea de comandos

En el programa cc-check puedes ver cómo la aplicación accede a los parámetros usando la variable `args` definida en `main()`. Por ejemplo, verificamos si no se suministró ningún parámetro de la siguiente manera:

```dart
if (args.length == 0) {
    print('Uso: cc-check tarjeta-de-crédito');
    exit(1);
}
```

Cuando llamas a un programa, los parámetros se separan por espacios. Dart cargará cada parámetro como un elemento en `args`, que es de tipo `List<string>`. Entonces, si no se proporcionó ningún parámetro, `args.length`será cero.

También nota que salimos del programa con la función `exit()` proporcionando un valor de retorno diferente de cero para indicar un error. Esto es útil en caso de que tu programa CLI se use en scripts que necesiten manejar errores.

También puedes ver cómo usamos el primer parámetro especificado por el usuario pasando `args[0]` a la función `ccIsValid()`:

```dart
try {
    if (ccIsValid(args[0])) {
        print('¡Es un número de tarjeta de crédito válido!');
    } else {
        print('¡Número de tarjeta de crédito NO VÁLIDO!');
    }
}
```

## Manejo de Excepciones

El manejo de excepciones en Dart es realmente sencillo y similar a otros lenguajes. Usas try-catch de la misma manera que otros lenguajes. El formato general es:

```dart
try {
    // Bloque de código
} catch(e) {
    // Manejar la excepción e aquí.
}
```

El código en este programa también ilustra la sintaxis para manejar tipos específicos de excepciones:

```dart
try {
    if (ccIsValid(args[0])) {
        print('¡Es un número de tarjeta de crédito válido!');
    } else {
        print('¡Número de tarjeta de crédito NO VÁLIDO!');
    }
} on FormatException catch(e) {
    print('Error: ${e.message}');
    exit(2);
} catch(e) {
    print('Ocurrió un error inesperado.');
    exit(3);
}
```

En nuestro programa usamos una `FormatException` cuando la entrada no está en el formato esperado. Cuando ocurre una excepción, si la excepción es de tipo `FormatException`, se ejecutará el bloque de código dentro de `on FormatException catch(e)`.

Si la excepción no coincide con ningún tipo especificado individualmente, entonces se ejecutará el bloque de código `catch(e)`.

Se desencadena una excepción cuando ocurre un error en tu programa, pero puedes generar manualmente una excepción. Por ejemplo, podemos generar una `FormatException` así:

```dart
throw FormatException('No se encontraron números válidos en la entrada.');
```

En el código anterior, la cadena utilizada al lanzar una `FormatException` se puede acceder en la variable de mensaje. Es por eso que ves código como este en el bloque de código `catch(e)`:

```dart
print('Error: ${e.message}');
```

## La función ccIsValid()

El corazón de este programa es la función llamada `ccIsValid()`. Esta función recibirá un número de tarjeta de crédito y nos dirá si es válido.

### Definición de la Función

La función `ccIsValid()` se define de la siguiente manera:

```dart
bool ccIsValid(String creditCard)
```

Este formato indica lo siguiente:

- El nombre de la función es `ccIsValid`que debe comenzar en minúscula.
- La función devuelve un valor de tipo bool. Este es un tipo incorporado y, como tal, comienza en minúscula.
- La función recibe un parámetro de tipo `String` llamado `creditCard`. Esta es una clase que forma parte de la biblioteca central de Dart. Los nombres de las clases comienzan con una letra mayúscula.
- También ten en cuenta que la variable `creditCard` comienza con minúscula, este es el estándar para los nombres de variables.

### Cuerpo de la Función

Ahora veamos el código de la función:

```dart
bool ccIsValid(String creditCard) {
    var ccNumbers = ccStrToList(creditCard);
    if (ccNumbers.isEmpty) {
        throw FormatException('No se encontraron números válidos en la entrada.');
    }
    if (ccNumbers.length != 16) {
        throw FormatException('El número de tarjeta de crédito debe tener 16 dígitos.');
    }
    int sum = 0;
    for (int i = 0; i < ccNumbers.length; i++) {
        if (i%2 == 0) { // Es Par (i~/2*2 == i)
            //ccNumbers[i] = ccNumbers[i] * 2;
            ccNumbers[i] *= 2;
            if (ccNumbers[i] > 9) {
                // SUMA el primer y segundo dígito
                ccNumbers[i] = ccNumbers[i]~/10 + ccNumbers[i]%10;
            }
        }
        sum += ccNumbers[i];
    }
    var isValid = (sum%10 == 0);
    return isValid;
}
```

Podemos aprender mucho de esa simple función. Veamos:

#### Definiciones de Variables

Podemos ver varias variables siendo definidas, por ejemplo `sum` que es de tipo `int`:

```dart
// Declaración de variable con tipo explícito
int sum = 0;
```

En esta declaración, el tipo se expresa explícitamente, pero hay otras formas de hacer lo mismo:

```dart
// El tipo es inferido por el compilador como int, ya que 0 es un valor int.
var sum = 0;
```

Puedes usar el estilo que prefieras. Si estás seguro de que el tipo es poco probable que cambie, usar el tipo explícito puede ser mejor. Pero generalmente, si la variable se está inicializando en el acto, se recomienda usar `var`.

#### Seguridad de Nulos (Null Safety)

Dart soporta lo que conocemos como Null Safety. Esto significa que el compilador verificará que no uses una variable que no esté inicializada. Por ejemplo:

```dart
int i;
bool isEven;
//... algún código que debe establecer i en algún valor ...
isEven = (i%2 == 0);
if(isEven) {
    print("El valor de i es par")
}
```

A menos que tengas algún código que establezca la variable i en un valor específico, obtendrás un error en tiempo de compilación. Si Dart no proporcionara esta característica, podrías compilar y ejecutar código inseguro.

El código inseguro puede ser una molestia, ya que el error solo será evidente si tu programa realmente ejecuta el código inseguro (lo que hará que tu programa se aborte), dejando al programador con la responsabilidad de realizar una verificación rigurosa de las variables para asegurarse de que no sean nulas antes de usarlas, lo que a menudo lleva a una complejidad no deseada del código fuente.

Aunque este fuera  del alcance de este programa de ejemplo, hay mucho más que aprender sobre la Seguridad de Nulos, incluyendo el soporte para variables anulables (nullable variables) y la palabra clave late para decirle al compilador que sea indulgente con una variable no inicializada.

### Variables Dinámicas

Hemos visto que puedes declarar una variable tanto explícitamente (usando el nombre del tipo), como explícitamente (usando la palabra clave `var`). Si estás familiarizado con otros lenguajes, puedes asumir que solo puedes usar la palabra clave `var` al inicializar la variable u objeto al momento de definirla, sin embargo Dart tiene otro uso para esta sintaxis.

Cuando declaras una variable usando `var` sin inicializarla, se convierte en una Variable Dinámica, que puede cambiar su tipo a lo largo de la vida del programa:

```dart
var v; // v es una Variable Dinámica
v = "Algún Texto"; // v ahora es una String
print("v es un ${v.runtimeType} que contiene: $v");
v = 3; // v ahora es un int
print("v es un ${v.runtimeType} que contiene: $v");
```

