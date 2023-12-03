import 'dart:math';

void main() {
  List<int> existingNumbers = [12345, 23456, 34567];
  int uniqueNumber = generateUniqueFiveDigitNumber(existingNumbers);

  print('重複しない数字: $uniqueNumber');
  existingNumbers.add(uniqueNumber);
}

int generateFiveDigitNumber() {
  var rng = Random();
  return rng.nextInt(90000) + 10000;
}

int generateUniqueFiveDigitNumber(List<int> existingNumbers) {
  int newNumber;
  do {
    newNumber = generateFiveDigitNumber();
  } while (isDuplicate(existingNumbers, newNumber));

  return newNumber;
}

bool isDuplicate(List<int> list, int number) {
  return list.contains(number);
}
