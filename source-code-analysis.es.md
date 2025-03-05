# Análisis del Código Fuente de cc-check

## Punto de entrada del programa

Un programa Dart tiene la función `main()`como punto de entrada. Esto significa que la aplicación comenzará ejecutando la función `main()`. En este caso, el programa es un ejecutable de línea de comandos y utiliza un parámetro de entrada, por lo que la función principal tiene la siguiente definición:

```dart
// Una función principal que recibe parámetros de línea de comandos
void main(List<string> args) {
}
```

Notarás que `main()` tiene un tipo de retorno void. Los programas de línea de comandos siempre devuelven un código de resultado, y en muchos lenguajes, `main()` especificará un valor de retorno de tipo `int`. Dart es diferente, no se hace un `return` al final del programa. Los programas terminarán con el código de salida 0 a menos que llames a la función `exit()` con otro valor.

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

En el código anterior, la cadena utilizada al lanzar una `FormatException` se puede acceder en la variable message. Es por eso que ves código como este en el bloque de código `catch(e)`:

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
    Set<int> validLengths = {13,14,15,16,19};
    if (!validLengths.contains(ccNumbers.length)) {
        throw FormatException('El número de tarjeta de crédito tiene una longitud no válida.');
    }
    var doubleIt = false;
    int sum = 0;
    for (int i = ccNumbers.length-1; i >=0; i--) {
        if (doubleIt) {
            ccNumbers[i] *= 2;
            if (ccNumbers[i] > 9) {
                // SUMA el primer y segundo dígito
                // ccNumbers[i] = ccNumbers[i]~/10 + ccNumbers[i]%10;
                ccNumbers[i] -= 9; // Equivalente a la suma de los dígitos
            }
        }
        sum += ccNumbers[i];
        doubleIt = !doubleIt; // Duplica el valor de cada 2º dígito
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
    print("El valor de i es par");
}
```

A menos que tengas algún código que establezca la variable i en un valor específico, obtendrás un error en tiempo de compilación. Si Dart no proporcionara esta característica, podrías compilar y ejecutar código inseguro.

El código inseguro puede ser una molestia, ya que el error solo será evidente si tu programa realmente ejecuta el código inseguro (lo que hará que tu programa aborte), dejando al programador con la responsabilidad de realizar una verificación rigurosa de las variables para asegurarse de que no sean nulas antes de usarlas, a menudo llevando a una complejidad no deseada del código fuente.

Aunque no estaremos abundando mas sobre ello aquí, hay mucho más que aprender sobre la Seguridad de Nulos, incluyendo el soporte para variables anulables y la palabra clave late para decirle al compilador que sea indulgente con una variable no inicializada.

### Variables Dinámicas

Hemos visto que puedes declarar una variable tanto explícitamente (usando el nombre del tipo), como implícitamente (usando la palabra clave `var`). Si estás familiarizado con otros lenguajes, puedes asumir que solo puedes usar la palabra clave `var` al inicializar la variable u objeto en el acto, sin embargo, Dart tiene otro uso para esta sintaxis.

Cuando declaras una variable usando `var` sin inicializarla, se convierte en una Variable Dinámica, que puede cambiar su tipo a lo largo de la vida del programa:

```dart
var v; // v es una Variable Dinámica
v = "Algún Texto"; // v ahora es una String
print("v es un ${v.runtimeType} que contiene: $v");
v = 3; // v ahora es un int
print("v es un ${v.runtimeType} que contiene: $v");
```

### El objeto `List<T>`

La primera línea de `ccIsValid()` es la siguiente:

```dart
var ccNumbers = ccStrToList(creditCard);
```

Normalmente usamos var para definir objetos que se inicializan en el acto, pero como `ccStrToList()` devuelve `List<int>`, también podríamos definir `ccNumber` como:

```dart
List<int> ccNumbers = ccStrToList(creditCard);
```

En este código definimos una variable `List<int>` llamada `ccNumber`. Contendrá una lista de números (valores int). Como puedes ver, esta lista se crea llamando a otra función llamada `ccStrToList()` que recibe una String. Veremos cómo funciona `ccStrToList()`, pero por ahora podemos aprender tres cosas de esta línea.

- Aunque podemos hacer algunas tareas directamente en `ccIsValid()`, si parece probable que más tarde queramos realizar esa tarea en otro lugar, una buena práctica es poner el código en otra función. En este caso, podríamos querer convertir cadenas de números en una `List<int>`, por lo que creamos `ccStrToList()` como una función separada. Además, incluso si la tarea solo se realizará dentro de `ccIsValid()` como en este caso, hace que el código sea más limpio y fácil de entender.
- ccNumbers no es solo una variable. Estamos usando lo que comúnmente se llama un _objeto_. Que es una variable que no solo contiene datos, sino también código que podemos llamar para hacer cosas con los datos.
- `List<int>` no es solo un objeto, es un tipo especial de objeto llamado _genérico_. Esto significa que la parte entre `<` y `>` puede ser cualquier tipo que deseemos, en este caso un `int`.

#### Propiedades de `List<T>`:

Dijimos que los objetos contienen datos, llamamos a cada tipo específico de datos dentro de un objeto una `propiedad`. Veamos cómo usamos algunas de esas propiedades:

```dart
if (ccNumbers.isEmpty) {
  //...
}
if (ccNumbers.length != 16) {
//...
}
```

En el código anterior, estamos verificando propiedades como `isEmpty` y `length`. Como su nombre lo indica, `isEmpty` es un booleano que contiene si la lista está vacía o no, y `length` es un int que contiene la longitud de la lista.

Como puedes ver, los objetos pueden contener diferentes datos. Estos datos podrían ser alguna información que desees sobre el objeto, como acabamos de ver. Hiciste una lista de números; estos datos se cargaron en el objeto, pero también podrías solicitar información sobre esa lista, como cuántos números hay en ella.

#### Indexación de una `List<T>`

`List<T>` no es solo cualquier objeto genérico, es una _colección ordenada e indexable_. Por ahora solo diremos que List es un objeto muy util que aprovecha varias características del lenguaje como _objetos abstractos, interfaces y sobrecarga de operadores (para indexación usando corchetes)_.

En el alcance de este ejemplo, usaremos `ccNumbers` como usaríamos una matriz en otros lenguajes, indexando la lista. Por ejemplo, podemos acceder al primer elemento de `ccNumbers` así:

```dart
var ccNumbers = ccStrToList(creditCard);
var firstNumber = ccNumbers[0];
print("El primer número es $firstNumber");
```

O el último:

```dart
var ccNumbers = ccStrToList(creditCard);
var lastNumber = ccNumbers[ccNumbers.length-1];
print("El último número es $lastNumber");
```

Si estás familiarizado con otros lenguajes, probablemente estés familiarizado con el concepto de _matrices_. Resulta que no hay soporte nativo de matrices en Dart. Cuando inicializas un objeto con _literales de lista_, el compilador generará un objeto `List<T>`:

```dart
// Esto es un objeto List<int>
var firstFourPrimes = [2,3,5,7];
```

La razón para no tener un tipo de matriz en Dart es que uno de los principios fundamentales del lenguaje es proporcionar _Flexibilidad y Simplicidad_. El objeto `List<T>`está diseñado para realizar todas las tareas que necesitarías para una matriz, mientras usas la misma sintaxis y permitiendo operaciones adicionales. Además, el compilador es lo suficientemente inteligente como para crear código eficiente tan bueno como otros compiladores generan al usar matrices nativas.

### Listas vs Conjuntos

Mira la siguiente línea de código:

```dart
var validLengths = {13,14,15,16,19};
```

Es muy similar a cómo inicializamos un objeto `List<T>`. Pero estamos usando llaves en lugar de corchetes. Esta sintaxis se usa cuando queremos crear un objeto `Set<T>` en lugar de una Lista, por lo tanto, es equivalente a:

```dart
Set<int> validLengths = {13,14,15,16,19};
```

Un objeto Set es similar a un objeto List, pero los elementos no pueden repetirse. Si agregas el mismo elemento varias veces, no se insertará más de una vez.

En la función `ccIsValid()`, usamos un conjunto para verificar la longitud de la lista `ccNumbers`. Queremos ver si la longitud no está dentro del conjunto y dar un error. Es decir, solo queremos permitir estas longitudes específicas:

```dart
Set<int> validLengths = {13,14,15,16,19};
if (!validLengths.contains(ccNumbers.length)) {
    throw FormatException('El número de tarjeta de crédito tiene una longitud no válida.');
}
```

Podríamos hacer esto en su lugar:

```dart
// Más torpe y más lento
if (
    ccNumbers.length != 13 &&
    ccNumbers.length != 14 &&
    ccNumbers.length != 15 &&
    ccNumbers.length != 16 &&
    ccNumbers.length != 19
) {
    throw FormatException('El número de tarjeta de crédito tiene una longitud no válida.');
}
```

O esto:

```dart
// Una buena alternativa en otros lenguajes
if ((ccNumbers.length<=13 || ccNumbers.length>=16) && ccNumbers.length!=19) {
    throw FormatException('El número de tarjeta de crédito tiene una longitud no válida.');
}
```

Usamos un conjunto en este ejemplo no solo para mostrar cómo se usan los conjuntos, sino también porque es una forma más eficiente de realizar la tarea. El código también se ve más limpio:

```dart
if (!validLengths.contains(ccNumbers.length)) {
// ....
}
```

Aquí vemos la expresión `validLengths.contains(ccNumbers.length)`. Anteriormente dijimos que los objetos son variables que no solo contienen datos, sino que también te permiten hacer cosas con ellos, como estamos haciendo ahora al preguntar al objeto si contiene un elemento específico. Para esto llamamos a un método del objeto que en este caso se llama `contains()`. Pasamos información al método como lo hacemos al llamar a funciones, con parámetros.

En este caso, estamos preguntando si la longitud de la lista `ccNumbers` es uno de los números contenidos en el conjunto. Luego aplicamos el operador `!` a la pregunta, lo que significa "no", por lo que la expresión completa dentro del if es:

```dart
!validLengths.contains(ccNumbers.length)
```

Lo que se puede leer como "¿La longitud de `ccNumbers` no es parte del conjunto `validLengths`?". Cuando usamos esta expresión dentro de la sentencia `if`, el programa ejecutará el código especificado solo si la expresión es verdadera.

