class AuthInterceptor {
  // Placeholder for attaching tokens to outgoing requests
  Future<void> onRequest() async {}
}

class LoggingInterceptor {
  // Placeholder for request/response logging
  void onResponse() {}
  void onError() {}
}
