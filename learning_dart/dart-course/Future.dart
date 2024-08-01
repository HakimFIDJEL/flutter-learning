Future<int> heavyFuture(int a) async {
  return Future.delayed(const Duration(seconds: 1), () {
    return a * 2;
  });
}

void test() async {
  final result = await heavyFuture(2);
  print(result);
}
