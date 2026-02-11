import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

/// Network connectivity status
enum NetworkStatus {
  connected,
  disconnected,
  unknown,
}

/// Network awareness service
///
/// Monitors network connectivity status using connectivity_plus.
class NetworkNotifier extends StateNotifier<NetworkStatus> {
  NetworkNotifier() : super(NetworkStatus.unknown) {
    _init();
  }

  final Connectivity _connectivity = Connectivity();

  Future<void> _init() async {
    // Check initial status
    final result = await _connectivity.checkConnectivity();
    _updateStatus(result);

    // Listen for connectivity changes
    _connectivity.onConnectivityChanged.listen(_updateStatus);
  }

  void _updateStatus(List results) {
    if (results.contains(ConnectivityResult.none) || results.isEmpty) {
      state = NetworkStatus.disconnected;
    } else {
      state = NetworkStatus.connected;
    }
  }

  /// Check if currently connected
  bool get isConnected => state == NetworkStatus.connected;

  /// Check if currently disconnected
  bool get isDisconnected => state == NetworkStatus.disconnected;
}

/// Network status provider
///
/// Watch this provider to get current network status.
final networkProvider = StateNotifierProvider<NetworkNotifier, NetworkStatus>((ref) {
  return NetworkNotifier();
});

/// Convenience provider to check if connected
final isConnectedProvider = Provider<bool>((ref) {
  return ref.watch(networkProvider) == NetworkStatus.connected;
});
