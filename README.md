# Credit Card Checker

A simple program to illustrate how to make a single-file dart console program.

## Running it from source

Just type `dart main.dart`

## Compile Native Binary

Use this:
```shell
dart compile exe main.dart -o cc-check
```

## Some test credit card numbers:

In case you want to test the program with valid credit card numbers
that are not real credit cards, here we provide 3 examples:

> 9137-2058-4619-3748
> 7469-1823-5074-6199
> 8391-6343-9583-5933
> 9023-5848-0715-6366
> 7612-1237-0360-8096

To test them run these commands:
```shell
dart main.dart 9137-2058-4619-3748
dart main.dart 7469-1823-5074-6199
dart main.dart 8391-6343-9583-5933
dart main.dart 9023-5848-0715-6366
dart main.dart 7612-1237-0360-8096
```
