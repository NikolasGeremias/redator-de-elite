import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class NotificadorAuth extends ChangeNotifier {
  late final StreamSubscription<User?> _assinatura;

  NotificadorAuth(Stream<User?> stream) {
    notifyListeners();
    _assinatura = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  @override
  void dispose() {
    _assinatura.cancel();
    super.dispose();
  }
}
