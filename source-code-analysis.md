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
