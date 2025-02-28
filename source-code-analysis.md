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
	if (ccNumbers.length != 16) {
		throw FormatException('Credit Card number must have 16 digits.');
	}

	int sum = 0;
	for (int i = 0; i < ccNumbers.length; i++) {
		if (i%2 == 0) { // Is Even (i~/2*2 == i)
			//ccNumbers[i] = ccNumbers[i] * 2;
			ccNumbers[i] *= 2;
			if (ccNumbers[i] > 9) {
				// SUM first and second digit
				ccNumbers[i] = ccNumbers[i]~/10 + ccNumbers[i]%10;
			}
		}
		sum += ccNumbers[i];
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

You can use whichever style you prefer. If you are sure the type is unlikely to be changed using explicit type may be better. But usually, if the variable is being initialized on the spot you, it is recommended to use `var`.

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

We've seen that you can declare a variable both explicitly (using the type name), or explicitly (using the `var` keyword). If you are familiar with other languages you may assume you can only use the `var` keyword when initializing the variable or object on the spot, however Dart has other use for this syntax.

When you declare a variable using `var` without initializing it, it becomes a Dynamic Variable, which can change it's type over the course of the program's life:

```dart
var v; // v is a Dynamic Variable

v = "Some Text"; // v is now a String
print("v is a ${v.runtimeType} that contains: $v");
v = 3; // v is now an int
print("v is a ${v.runtimeType} that contains: $v");
```
