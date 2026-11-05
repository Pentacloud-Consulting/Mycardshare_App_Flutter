// Native (Android / iOS / desktop) implementation using dart:io.
import 'dart:io';

/// Performs a DNS lookup to check real internet connectivity.
/// Returns true if connected, false otherwise.
Future<bool> checkNativeConnectivity() async {
  try {
    final res = await InternetAddress.lookup('google.com')
        .timeout(const Duration(seconds: 3));
    if (res.isNotEmpty && res[0].rawAddress.isNotEmpty) return true;
  } catch (_) {}
  try {
    final res2 = await InternetAddress.lookup('1.1.1.1')
        .timeout(const Duration(seconds: 3));
    if (res2.isNotEmpty && res2[0].rawAddress.isNotEmpty) return true;
  } catch (_) {}
  return false;
}
