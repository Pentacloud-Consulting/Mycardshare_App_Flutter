class Helpers {
  static void printLog(String message) {
    // Helper function for logging
    assert(() {
      // ignore: avoid_print
      print('[MyCardShare] $message');
      return true;
    }());
  }
}
