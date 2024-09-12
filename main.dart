void main(List<String> args) {

	if (args.length == 0) {
		print('Usage: cc-check credit-card');
		return;
	}

	try {
		if (ccIsValid (args[0])) {
			print('Is a valid Credit Card number!');
		} else {
			print('NOT VALID Credit Card number!');
		}
	} catch(e) {
		if( e is FormatException) {
			print('Error: ${e.message}');
		} else {
			print('An unexpected error occurred.');
			rethrow;
		}
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

bool ccIsValid(String CreditCard) {
	var  ccNumbers = ccStrToList(CreditCard);
	if (ccNumbers.isEmpty) {
		throw FormatException('No valid numbers found in the input.');
	} 
	if (ccNumbers.length != 16) {
		throw FormatException('Credit Card number must have 16 digits.');
	} 

	int sum = 0;
	for (int i = 0; i < ccNumbers.length; i++) {
		if (i~/2*2 == i) { // Is Even 
			ccNumbers[i] = ccNumbers[i] * 2;
			//ccNumbers[i] *= 2;
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

