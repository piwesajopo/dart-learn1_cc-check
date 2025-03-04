import 'dart:io';

void main(List<String> args) {

	if (args.length == 0) {
		print('Usage: cc-check credit-card');
		exit(1);
	}

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
}

List<int> ccStrToList(String str) {

	List<int?> numbers = str.split('').map((char) {
		int? number = int.tryParse(char);
		if (number == null) {
			if (char != '-') {
				throw FormatException('"$char" is not a number!');
			}
		}
		return number;
	}).toList();

	numbers.removeWhere((element) => element == null);
	return numbers.cast<int>();
}

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
