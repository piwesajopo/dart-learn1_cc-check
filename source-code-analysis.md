# Source Code Analysis for cc-check

## Program entry point

A Dart program has the function `main()` as an entry point. This means the app will start by executing the `main()` function. In this case the program is a command line executable and it uses an input parameter, so the main function has the following definition:

```dart
// A main function that receives command line parameters
void main(List<string> args) {

}
```

You will notice main() has a void return type. Command line programs always return a result code, and in many languages, `main()` will specify a return value of type `int` . Dart is different, you don't issue a `return` at the end of the program. Programs will end with exit code 0 unless you call the `exit()` function with another value.

When you define main this way, the input parameters will be received in the args variable, which is of type `List<string>`. This makes easy to check how many parameters you received as well as accessing parameters individually. We will see how this is done in the following section.

## Handling command-line parameters

In the cc-check program you can see how the app access parameters using the `args` variable defined in `main()`.  For example we check if no parameter was supplied in the following way:

```dart
if (args.length == 0) {
	print('Usage: cc-check credit-card');
	exit(1);
}
```

When you call a program parameters are separated by spaces. Dart will load each parameter as an item on args, which is of type `List<string>`. So, if there was no parameter provided, `args.length` will be zero.

Also notice we exit the program with the `exit()` function providing a return value different than zero to indicate an error. This is useful in case your CLI program is used on scripts that need to handle errors.

You can also see how we use the first parameter specified by the user by passing `args[0]` to the `ccIsValid()` function:

```dart
try {
	if (ccIsValid (args[0])) {
		print('Is a valid Credit Card number!');
	} else {
		print('NOT VALID Credit Card number!');
	}
}
```

## Handling Exceptions

Dart's exception handling is really straightforward and similar to other languages. You use try-catch in much the same way as other languages. The general format is:

```dart
try {
	// Code block
} catch(e) {
	// Handle exception e here.
}
```

The code in this program also illustrates the syntax for handling specific types of exceptions:

```dart
try {
	if (ccIsValid (args[0])) {
		print('Is a valid Credit Card number!');
	} else {
		print('NOT VALID Credit Card number!');
	}
} on FormatException catch(e) {
	print('Error: ${e.message}');
	exit(2);
} catch(e) {
	print('An unexpected error occurred.');
	exit(3);
}
```

In our program we use a `FormatException` when the input is not in the expected format. When an exception occurs, if the exception if of type `FormatException` the code block inside the `on FormatException catch(e)` code block will be executed.

If the exception doesn't matches any individually specified type, then the `catch(e)` code block will be executed.

An exception is triggered when an error occurs in your program, but you can manually generate an exception. For example we can generate a `FormatException` like this:

```dart
throw FormatException('No valid numbers found in the input.');
```

In the code above, the string used when throwing a `FormatException` can be accessed on the message variable. That's why you see code like  this in the `catch(e)` code block:

```dart
print('Error: ${e.message}');
```

## The ccIsValid() function

The heart of this program is the function called `ccIsValid()`. This function will receive a credit card number and tell us if it's a valid one.

### Function Definition

Function `ccIsValid()` is defined as follows:

```dart
bool ccIsValid(String creditCard)
```

This format indicates the following:

* The function name is `ccIsValid` which must start in lowercase.
* The function returns a value of type bool. This is a built-in type and as such starts as lowercase.
* The function receives a parameter of type `String` called `creditCard`. This is a class that is part of the Dart core library. Classes names start with a capital letter.
* Also please note that the variable `creditCard` starts with lowercase, this is the standard for variable names.

### Function Body

Now let's see the code for the function:

```dart
bool ccIsValid(String creditCard) {
    var  ccNumbers = ccStrToList(creditCard);
    if (ccNumbers.isEmpty) {
        throw FormatException('No valid numbers found in the input.');
    }

    Set<int> validLengths = {13,14,15,16,19};
    if (!validLengths.contains(ccNumbers.length)) {
        throw FormatException('Credit Card number has an invalid length.');
    }

    var doubleIt = false;
    int sum = 0;
    for (int i = ccNumbers.length-1; i >=0; i--) {
        if (doubleIt) {
            ccNumbers[i] *= 2;
            if (ccNumbers[i] > 9) {
                // SUM first and second digit
                // ccNumbers[i] = ccNumbers[i]~/10 + ccNumbers[i]%10;
                ccNumbers[i] -= 9; // Equivalent to the sum of the digits
            }
        }
        sum += ccNumbers[i];
        doubleIt = !doubleIt; // Double the value each 2nd digits
    }

    var isValid = (sum%10 == 0);
    return isValid;
}
```

We can learn a lot from that simple function. Let's see:

#### Variable definitions

We can see several variables being defined, for example `sum` which is of type `int`:

```dart
// Variable declaration with explicit type
int sum = 0;
```

In this declaration the type is explicitly expressed, but there are other ways we can do the same:

```dart
// Type is inferred by the compiler as int, since 0 is an int value.
var sum = 0;
```

You can use whichever style you prefer. If you are sure the type is unlikely to be changed in a future version of your program, using explicit type may be better. But usually, if the variable is being initialized on the spot you, it is recommended to use `var`.

#### Null Safety

Dart supports Null Safety. This means the compiler will check that you don't use a variable that's not initialized. For example:

```dart
int  i;
bool isEven;

//... some code that must set i to some value ...

isEven = (i%2 == 0);
if(isEven ) {
	print("Value of i is even")
}
```

Unless you have some code that sets variable i to an specific value, you will get an error at compile time. If Dart didn't provide this feature, you would be able to compile and run unsafe code.

Unsafe code can be a nuisance, since the error will only be evident if your program actually executes the unsafe code (which will make your program abort), leaving the programmer with the responsibility of performing rigorous checking of variables to make sure they are not null before using them, often leading to unwanted complexity of the source code.

While not in the scope of this example program, there is much more to learn about Null Safety, including the support for nullable variables and the late keyword for telling the compiler to lenient about an uninitialized variable.

### Dynamic variables

We've seen that you can declare a variable both explicitly (using the type name), or implicitly (using the `var` keyword). If you are familiar with other languages you may assume you can only use the `var` keyword when initializing the variable or object on the spot, however Dart has other use for this syntax.

When you declare a variable using `var` without initializing it, it becomes a Dynamic Variable, which can change it's type over the course of the program's life:

```dart
var v; // v is a Dynamic Variable

v = "Some Text"; // v is now a String
print("v is a ${v.runtimeType} that contains: $v");
v = 3; // v is now an int
print("v is a ${v.runtimeType} that contains: $v");
```

### The `List<T>` object

The first line of `ccIsValid()` is as follows:

```dart
var ccNumbers = ccStrToList(creditCard);
```

We normally use var to define objects that are initialized on the spot, but since ccStrToList() returns `List<int>` we could also define ccNumber as:

```dart
List<int> ccNumbers = ccStrToList(creditCard);
```

In this code we define a `List<int>` variable called `ccNumber`. It will contain a list of numbers (int values). As you can see this list is created by calling another function called `ccStrToList()` which receives a String. We will see later how `ccStrToList()` works, but for now we can learn three things from this line.

* While we can do some tasks directly in `ccIsValid()`, if it seems likely that we would later want to perform that task elsewhere, a good practice is to put the code in another function. In this case, we might want to convert strings of numbers into a `List<int>` so, we created `ccStrToList()` as a separate function. Also, even if the task will only be performed inside `ccIsValid()` like in this case, it makes the code cleaner and easier to understand.

* ccNumbers is not just a variable. We are using what is commonly called an _object_. Which is a variable that not only contains data, but also code that we can call to make things with the data.

* `List<int>` is not just an object, is a special type of object called a _generic_. This means the part between `<` and  `>` can be any type we wish, in this case an `int`.

#### Properties of `List<T>`:

We said objects contain data, we call each specific type of data inside an object a `property`. Let's see how we use some of those properties:

```dart
if (ccNumbers.isEmpty) {
  //...
}

if (ccNumbers.length != 16) {
//...
}
```

In the code above, we are checking properties like `isEmpty` and `lenght`. As their name implies, `isEmpty` is a boolean that contains weather the list is empty or not, and `lenght` is an int that contains the length of the list.

As you can see, objects can contain several bits of data. This data could be some information you want about the object as we just saw. You made a list of numbers; this data was loaded into the object, but you also could request information about that list, like how many numbers are in it.

#### Indexing a `List <T>`

`List<T>` is not just a generic object, it's an _indexable, ordered collection_. For now we will just say List is a very rich object that leverages several language features like _abstract classes, generics, interfaces, and operator overloading (for indexing using brackets)_.

In the scope of this example we will just use ccNumbers as we would use an array in other languages, by indexing the list. For example we can access the first element of ccNumbers like this:

```dart
var ccNumbers = ccStrToList(creditCard);
var firstNumber = ccNumbers[0];
print("The first number is $firstNumber");
```

Or the last:

```dart
var ccNumbers = ccStrToList(creditCard);
var lastNumber = ccNumbers[ccNumbers.lenght-1;
print("The first number is $lastNumber");
```

If you are familiar with other languages you are probably familiar with the concept of _arrays_. Turns out that there's no native array support in dart. When you initialize an object with _list literals_, the compiler will generate a `List<T>` object:

```dart
// This is a List<int> object
var firstFourPrimes = [2,3,5,7];
```

The reason for not having an array type on Dart is that one of the core principles of the language is to provide _Flexibility and Simplicity_. The `List<T>` object is designed so it performs all the task you would need an array for, while using the same syntax and allowing additional operations. Also the compiler is smart enough to create efficient code as good as other compilers generate when using native arrays.


### Lists vs Sets

Look at the following line of code:

```dart
var validLengths = {13,14,15,16,19};
```

It is very similar to how we initialize a `List<T>` object. But we are using curly brackets instead of square ones. This sintax is used when we want to create a `Set<T>` object instead of a List, it is thus equivalent to:

```dart
Set<int> validLengths = {13,14,15,16,19};
```

A Set object is similar to a List object, but the elements can't be repeated. If you add the same item several times, it will not be inserted more than once.

In the ccIsValid() function, we use a set to check the length of the `ccNumbers` List. We want to see if the length is not inside the set and give an error. That is to say, we want only to allow these specific lengths:

```dart
Set<int> validLengths = {13,14,15,16,19};
if (!validLengths.contains(ccNumbers.length)) {
	throw FormatException('Credit Card number has an invalid length.');
}
```

We could very well do this instead:

```dart
// Clumsier and Slower
if (
	ccNumbers.length != 13 &&
	ccNumbers.length != 14 &&
	ccNumbers.length != 15 &&
	ccNumbers.length != 16 &&
	ccNumbers.length != 19
) {
	throw FormatException('Credit Card number has an invalid length.');
}
```

Or this:

```dart
// A good alternative on other languages
if ((ccNumbers.length<=13 || ccNumbers.length>=16) && ccNumbers.length!=19) {
	throw FormatException('Credit Card number has an invalid length.');
}
```

We used a Set in this example not just to show how sets are used, but also because is a more efficient way to perform the task. The code also looks cleaner:

```dart
if (!validLengths.contains(ccNumbers.length)) {
// ....
}
```

Here we see the expression `validLengths.contains(ccNumbers.length)`. We previously said that objects are variables that not only contain data, but algo allows you to do things with them, like we are now doing by asking the object if it contains an specific element. For this we call a method of the object which in this case is called `contains()`. We pass information to the method just like we do when calling functions, with parameters.

In this case we are asking if the length of the List ccNumbers, is one of the numbers contained in the set. We then apply the `!` operator to the question which means "not" so the full expression inside the if is:

```dart
!validLengths.contains(ccNumbers.length)
```

Which can be read as "Is the length of ccNumbers not part of the set `validLengths`?". When we use this expression inside the `if` sentence the program will execute the specified code only if the expression is true.
