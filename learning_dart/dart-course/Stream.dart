Stream<String> getName() {
  return Stream.periodic(const Duration(seconds: 1), (value) {
    return 'Foo';
  });
}

void test() async {
  await for (final value in getName()) {
    print(value);
  }
}
