import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/widgets.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../firebase_options.dart';

class InicializadorFirebase {
  InicializadorFirebase._();

  static Future<void> inicializar() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    await _validarSessao();
  }

  static Future<void> _validarSessao() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    try {
      await user.reload();
      await user.getIdToken(true);
    } catch (_) {
      try {
        await GoogleSignIn().signOut();
      } catch (_) {}
      await FirebaseAuth.instance.signOut();
    }
  }
}
