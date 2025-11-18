import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:fluttertoast/fluttertoast.dart';

class NetworkService {
  static final NetworkService _instance = NetworkService._internal();
  factory NetworkService() => _instance;
  NetworkService._internal();

  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  void initialize() {
    _subscription = _connectivity.onConnectivityChanged.listen((List<ConnectivityResult> results) {
      final result = results.isNotEmpty ? results.first : ConnectivityResult.none;

      if (result == ConnectivityResult.none) {
        _showToast("No Internet Connection");
      } else {
        _checkInternetSpeed();
      }
    });
  }

  Future<void> _checkInternetSpeed() async {
    final stopwatch = Stopwatch()..start();
    try {
      final result = await InternetAddress.lookup("example.com").timeout(const Duration(seconds: 3));
      stopwatch.stop();

      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        final ping = stopwatch.elapsedMilliseconds;
        if (ping > 1000) {
          _showToast("Network is slow");
        } else {
          _showToast("Internet Connected");
        }
      } else {
        _showToast("No Internet Connection");
      }
    } on SocketException catch (_) {
      _showToast("No Internet Connection");
    } on TimeoutException catch (_) {
      _showToast("Network is slow");
    }
  }

  void _showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
    );
  }

  void dispose() {
    _subscription?.cancel();
  }
}
