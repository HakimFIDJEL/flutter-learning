class Pair<A, B> {
  final A value1;
  final B value2;
  Pair(this.value1, this.value2);
}

void test() {
  final names = Pair("Foo", "Bar");
  print(names.value1);

  final namesAndNumbers = Pair("Foo", 42);
  print(namesAndNumbers.value2);
}
